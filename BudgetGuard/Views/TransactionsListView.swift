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
    @State private var page = 0
    
    @State private var selectedSorting: SortingType = .forDate
    @State private var showSortingMenu = false
    
    private let transactionService = TransactionsService()
    private let categoriesService = CategoriesService()
    
    private let pageSize = 20
    
    
    
    var body: some View {
        ZStack {
            Color(.background).ignoresSafeArea()
            
            NavigationView {
                VStack(alignment: .leading) {
                    Text(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                        .font(.largeTitle).bold()
                        .padding(.leading)
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
                                        if index == transactions.count - 1 {
                                            Task { await loadTransactions(page: page)}
                                        }
                                    }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
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
            }
            .accentColor(Color(.toolBarItem))
            
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
        .task {
            if transactions.isEmpty { await loadTransactions(page: 0) }
        }
    }
    
    func loadTransactions(page: Int) async {
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
            
            let startIndex = page * pageSize
            let endIndex = min(startIndex + pageSize, transactionsByDirection.count)
            
            if startIndex >= transactionsByDirection.count {
                hasMore = false
                isLoading = false
                return
            }
            
            let transactionsToAdd = transactionsByDirection[startIndex..<endIndex]
            
            
            DispatchQueue.main.async {
                transactions += transactionsToAdd
                totalAmount = transactionsByDirection.reduce(0) { $0 + $1.amount }
                self.page += 1
                isLoading = false
                hasMore = transactionsByDirection.count > pageSize
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
