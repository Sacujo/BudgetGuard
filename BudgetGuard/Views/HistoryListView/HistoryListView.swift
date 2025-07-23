//
//  HistoryListView.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 20.06.2025.
//

import SwiftUI

struct HistoryListView: View {
    
    @StateObject private var viewModel: HistoryListViewModel
    
    private var fromDateBinding: Binding<Date> {
        Binding(
            get: { viewModel.fromDate },
            set: { newFrom in
                // если выбрано позже toDate — устанавливаем toDate
                if newFrom > viewModel.toDate {
                    viewModel.toDate = newFrom
                }
                viewModel.fromDate = newFrom
                Task { await viewModel.reloadTransactions() }
            }
        )
    }
    
    private var toDateBinding: Binding<Date> {
        Binding(
            get: { viewModel.toDate },
            set: { newTo in
                // если выбрано раньше fromDate — устанавливаем fromDate
                if newTo < viewModel.fromDate {
                    viewModel.fromDate = newTo
                }
                viewModel.toDate = newTo
                Task { await viewModel.reloadTransactions() }
            }
        )
    }
    
    private var selectedSorting: Binding<SortingType> {
        Binding(
            get: { viewModel.sortingType },
            set: { newOption in
                viewModel.sortingType = newOption
                Task { await viewModel.reloadTransactions() }
                
            }
        )
    }
    
    @State private var showSortingMenu = false
    
    init(direction: Direction) {
        _viewModel = StateObject(wrappedValue: HistoryListViewModel(direction: direction))
    }
    
    var body: some View {
        ZStack {
            Color(.background).ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("Моя История")
                    .font(.largeTitle).bold()
                    .padding(.leading)
                    .padding(8)
                
                List {
                    Section {
                        HStack {
                            Text("Начало")
                            Spacer()
                            DatePicker("", selection: fromDateBinding, displayedComponents: [.date])
                                .background(Color.accentColor.opacity(0.12))
                                .labelsHidden()
                        }
                        HStack {
                            Text("Конец")
                            Spacer()
                            DatePicker("", selection: toDateBinding, in: ...Date(), displayedComponents: [.date])
                                .background(Color.accentColor.opacity(0.12))
                                .labelsHidden()
                        }
                        HStack {
                            Text("Всего")
                            Spacer()
                            Text("\(viewModel.totalAmount.formatted()) \(viewModel.bankAccount?.currency.symbol ?? "")")
                                .foregroundStyle(Color(.text))
                        }                    }
                    
                    Section(header: Text("Операции").font(.caption)) {
                        ForEach(viewModel.transactions) { transaction in
                            NavigationLink(destination: TransactionEditView(transaction, direction: viewModel.direction)) {
                                TransactionRow(transaction: transaction)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button { showSortingMenu = true } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(Color(.toolBarItem))
                        }
                        NavigationLink(destination: AnalysisView(direction: viewModel.direction)) {
                            Image(systemName: "doc")
                                .foregroundColor(Color(.toolBarItem))
                        }
                    }
                }
            }
            .confirmationDialog("Сортировать по:", isPresented: $showSortingMenu, titleVisibility: .visible) {
                ForEach(SortingType.allCases) { newOption in
                    Button(newOption.rawValue) {
                        selectedSorting.wrappedValue = newOption
                    }
                }
                Button("Отмена", role: .cancel) {}
            }
            .task {
                await viewModel.reloadTransactions()
            }
        }
    }
}

#Preview {
    ContentView()
}
