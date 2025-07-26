//
//  BankAccountView.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 26.06.2025.
//

import SwiftUI
import Charts

struct BankAccountView: View {
    
    @StateObject private var viewModel: BankAccountViewModel
    
    
    init() {
        _viewModel = StateObject(wrappedValue: BankAccountViewModel())
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        if let account = viewModel.account {
                            VStack(spacing: 16) {
                                if viewModel.isEditing {
                                    EditableBalanceCardView(balanceText: $viewModel.balanceInput)
                                    CurrencyCheckerView(selected: $viewModel.selectedCurrency)
                                } else {
                                    BalanceCardVIew(balance: account.balance, currency: account.currency.symbol, isBalanceHidden: $viewModel.isBalanceHidden)
                                    CurrencyCardView(currencyCode: account.currency.symbol)
                                    Spacer(minLength: 16) // добавлен отступ между элементами и графиком
                                    // График истории баланса
                                    if !viewModel.balanceHistory.isEmpty {
                                        BalanceHistoryChart(data: viewModel.balanceHistory)
                                            .frame(height: 240)
                                            .padding(.horizontal, 8)
                                            .padding(.top, 0)
                                    }
                                }
                            }.padding(.horizontal)
                        } else {
                            ProgressView()
                        }
                    }
                    .padding(.vertical)
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle(Text("Мой счет"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { [ self] in viewModel.togleEditing() }) {
                            Group {
                                if viewModel.isEditing {
                                    Text("Save")
                                } else {
                                    Text("Edit")
                                }
                            }.foregroundStyle(Color.toolBarItem)
                        }
                    }
                }
                .refreshable{Task {
                    await viewModel.loadAccount()
                    await viewModel.loadBalanceHistory()
                }}
                .task{
                    await viewModel.loadAccount()
                    await viewModel.loadBalanceHistory()
                }
            }
        }
    }
}

struct BalanceHistoryChart: View {
    let data: [(date: Date, balance: Decimal)]
    @State private var selectedDate: Date?
    
    var body: some View {
        let count = data.count
        let labelIndices: Set<Int> = [0, count / 2, count - 1]
        Chart(data.enumerated().map { $0 }, id: \ .element.date) { idxItem in
            let item = idxItem.element
            BarMark(
                x: .value("Дата", item.date, unit: .day),
                y: .value("Баланс", abs(NSDecimalNumber(decimal: item.balance).doubleValue))
            )
            .foregroundStyle(NSDecimalNumber(decimal: item.balance).doubleValue < 0 ? .red : .green)
            .clipShape(Capsule()) // скругление и сверху, и снизу
            
            if let selectedDate = selectedDate, selectedDate == item.date {
                RuleMark(x: .value("Выбранная дата", selectedDate))
                    .foregroundStyle(.gray.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 2))
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let plotFrame = proxy.plotFrame {
                                    let origin = geometry[plotFrame].origin
                                    let locationX = value.location.x - origin.x
                                    if let date: Date = proxy.value(atX: locationX) {
                                        selectedDate = date
                                    }
                                }
                            }
                            .onEnded { _ in
                                selectedDate = nil
                            }
                    )
                
                if let selectedDate = selectedDate,
                   let selectedData = data.first(where: { 
                       Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                   }) {
                    // Вычисляем позицию столбца по X
                    let xPosition = proxy.position(forX: selectedDate) ?? 0
                    
                    // Вычисляем позицию верха столбца по Y
                    let barTopY = proxy.position(forY: abs(NSDecimalNumber(decimal: selectedData.balance).doubleValue)) ?? 0
                    
                    // Позиционируем всплывающее окно над столбцом
                    let popupY = barTopY - 30 // Отступ от верха столбца
                    
                    Text("\(selectedData.balance)")
                        .font(.caption)
                        .padding(4)
                        .background(Color(.systemBackground))
                        .cornerRadius(4)
                        .shadow(radius: 1)
                        .position(x: xPosition, y: popupY)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: data.enumerated().compactMap { idx, item in
                labelIndices.contains(idx) ? item.date : nil
            }) { value in
                if let date = value.as(Date.self), let idx = data.firstIndex(where: { $0.date == date }) {
                    if idx == data.count - 1 {
                        AxisValueLabel(format: .dateTime.day().month(.twoDigits))
                            .offset(x: -28)
                    } else {
                        AxisValueLabel(format: .dateTime.day().month(.twoDigits))
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .frame(height: 240)
        .padding(.horizontal, 8)
        .padding(.top, 0)
    }
}

#Preview {
    BankAccountView()
}

