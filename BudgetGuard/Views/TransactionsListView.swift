//
//  TransactionsListView.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 19.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    let direction: Direction
    
    @State private var transactions: [Transaction] = []
    @State private var totalAmount: Decimal = 0
    @State private var isLoading = false
    @State private var hasMore = true
    
    @State private var selectedSorting: SortingType = .forDate
    @State private var showSortingMenu = false

    private let transactionService = TransactionsService()
    private let categoriesService = CategoriesService()
    
    
    
    var body: some View {
        ZStack {
            Color(.background).ignoresSafeArea()
            
            NavigationView {
                VStack(alignment: .leading) {
                    Text(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                        .font(.largeTitle).bold()
                        .padding(.horizontal)
                        .padding(8)
                    
                    List {
                        Section {
                            HStack {
                                Text("Всего")
                                Spacer()
                                Text("\(totalAmount.formatted()) ₽")
                                    .foregroundStyle(Color(.text))
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
                    .listStyle(.insetGrouped)
                }
            }
            .background(Color(.background))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showSortingMenu = true }) {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(Color(.toolBarItem))
                        }
                        NavigationLink(destination: HistoryListView(direction: direction)) {
                            Image(systemName: "clock")
                                .foregroundColor(Color(.toolBarItem))
                        }
                    }
                }
            }
        }.task {
            if transactions.isEmpty { await loadTransactions() }
        }
    }
    
    func loadTransactions() async {
        guard !isLoading else { return }
        isLoading = true
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        do {
            let allTransactions = try await transactionService.fetchTransactions(from: startDate, to: endDate)
            let allCategories = try await categoriesService.fetchCategories(direction: direction)
            let categoriesIds = allCategories.map{ $0.id }
            let transactionsByDirection = allTransactions.filter {
                categoriesIds.contains($0.categoryId)
            }
            DispatchQueue.main.async {
                transactions = transactionsByDirection
                totalAmount = transactions.reduce(0) { $0 + $1.amount }
                isLoading = false
                hasMore = transactionsByDirection.count > 25
            }
            
            
        } catch {
            print("Error: \(error)")
            isLoading = false
        }
    }
}

#Preview {
    ContentView()
}
