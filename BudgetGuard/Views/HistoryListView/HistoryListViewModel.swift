//
//  HistoryListViewModel.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 25.06.2025.
//

import Foundation

final class HistoryListViewModel: ObservableObject {
    
    private let categoriesService: CategoriesService = CategoriesService()
    private let transactionsService: TransactionsService = TransactionsService()
    
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var categories: [Category] = []
    @Published var fromDate: Date
    @Published var toDate: Date
    @Published var isLoading = false
    @Published var sortingType: SortingType = .forDate
    
    var totalAmount: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    private var startOfDay: Date {
        calendar.startOfDay(for: fromDate)
    }
    
    private var endOfDay: Date {
        let start = calendar.startOfDay(for: toDate)
        return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? Date()
    }
    
    let direction: Direction
    let calendar: Calendar = Calendar.current
    
    
    init(direction: Direction) {
        self.direction = direction
        self.toDate = Date()
        self.fromDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    }
    
    func reloadTransactions() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let categories = try await categoriesService.fetchCategories(direction: direction)
            self.categories = categories
            let categoriesIds = categories.map{ $0.id }
            
            let transactionsByPeriod = try await transactionsService.fetchTransactions(from: startOfDay, to: endOfDay)
            
            transactions = transactionsByPeriod.filter {
                categoriesIds.contains($0.categoryId)
            }
            
            switch sortingType {
            case .forDate:
                transactions = transactions.sorted { $0.transactionDate > $1.transactionDate }
            case .forAmount:
                transactions = transactions.sorted { $0.amount > $1.amount }
            }
            
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func category(for transaction: Transaction) -> Category {
        categories.first(where: { $0.id == transaction.categoryId }) ?? Category(id: 58, name: "Образование", emoji: "📚", isIncome: false)
    }
}
