//
//  TransactionsViewModel.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 22.06.2025.
//

import Foundation

final class TransactionsListViewModel: ObservableObject {
    
    private let categoriesService = CategoriesService()
    private let transactionsService = TransactionsService()
    
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var categories: [Category] = []
    @Published var isLoading = false
    @Published var sortingType: SortingType = .forDate
    
    var totalAmount: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    func reloadTransactions() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let categories = try await categoriesService.fetchCategories(direction: direction)
            self.categories = categories
            let categoriesIds = categories.map{ $0.id }
            
            let calendar = Calendar.current
            let startDate = calendar.startOfDay(for: Date())
            guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return }
            
            let todayTransactions = try await transactionsService.fetchTransactions(from: startDate, to: endDate)
            
            transactions = todayTransactions.filter {
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
        categories.first(where: { $0.id == transaction.categoryId }) ?? Category(id: 58, name: "Образование", emoji: "📚", direction: .outcome)
    }

}
