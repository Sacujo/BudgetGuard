//
//  HistoryListView.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 20.06.2025.
//

import SwiftUI

struct HistoryListView: View {
    
    let direction: Direction
    
    @State var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State var endDate: Date = Date()
    
    @State var transactions: [Transaction] = []
    @State var totalAmount: Decimal = 0
    @State private var isLoading = false
    @State private var hasMore = true
    
    @State private var selectedSorting: SortingType = .forDate
    @State private var showSortingMenu = false
    
    private let transactionService = TransactionsService()
    private let categoriesService = CategoriesService()
    private let pageSize = 5
    
    var body: some View {
        ZStack {
            Color(.background).ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("Моя История")
                    .font(.largeTitle).bold()
                    .padding(.leading)
                    .padding(8)
                
                List {
                    Section{
                        HStack {
                            Text("Начало")
                            Spacer()
                            DatePicker("", selection: $startDate, displayedComponents: [.date])
                                .background(Color.accentColor.opacity(0.12))
                                .labelsHidden()
                                .onChange(of: startDate) {
                                    if startDate > endDate { endDate = startDate }
                                    Task { await loadTransactions() }
                                }
                        }
                        HStack {
                            Text("Конец")
                            Spacer()
                            DatePicker("", selection: $endDate, in: ...Date(), displayedComponents: [.date])
                                .background(Color.accentColor.opacity(0.12))
                                .labelsHidden()
                                .onChange(of: startDate) {
                                    if endDate < endDate { startDate = endDate }
                                    Task { await loadTransactions() }
                                }
                        }
                        HStack {
                            HStack {
                                Text("Сумма")
                                Spacer()
                                Text("\(totalAmount.formatted()) ₽")
                            }
                        }
                    }
                    
                    Section(header: Text("Операции").font(.caption)) {
                        ForEach(transactions.indices, id: \.self) { index in
                            let transaction = transactions[index]
                            
                            TransactionRow(transaction: transaction)
                                .listRowBackground(Color.white)
                                .onAppear {
                                    if index == transactions.count - 1, hasMore {
                                        Task { await loadTransactions()}
                                    }
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
                        Button(action: {}) {
                            Image(systemName: "doc")
                                .foregroundColor(Color(.toolBarItem))
                        }
                    }
                }
            }
            .confirmationDialog("Сортировать по:", isPresented: $showSortingMenu, titleVisibility: .visible) {
                ForEach(SortingType.allCases) { option in
                    Button(option.rawValue) {
                        selectedSorting = option
                        applySort()
                    }
                }
                Button("Отмена", role: .cancel) {}
            }
        }
        .onAppear { Task { await loadTransactions() } }
    }
    
    func loadTransactions() async {
        let dayStart = Calendar.current.startOfDay(for: startDate)
        let dayEnd = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        
        do {
            let allTransactions = try await transactionService.fetchTransactions(from: dayStart, to: dayEnd)
            let allCategories = try await categoriesService.fetchCategories(direction: direction)
            let categoriesIds = allCategories.map{ $0.id }
            
            let transactionsByDirection = allTransactions.filter {
                categoriesIds.contains($0.categoryId)
            }
            
            DispatchQueue.main.async {
                transactions = transactionsByDirection
                totalAmount = transactionsByDirection.reduce(0) { $0 + $1.amount }
            }
            
            
        } catch {
            print("Error: \(error)")
            isLoading = false
        }
    }
    
    private func applySort() {
        switch selectedSorting {
        case .forDate:
            transactions.sort { $0.transactionDate > $1.transactionDate }
        case .forAmount:
            transactions.sort { $0.amount > $1.amount }
        }
    }
}

#Preview {
    ContentView()
}
