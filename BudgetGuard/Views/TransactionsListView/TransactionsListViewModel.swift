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
    private let bankAccountService = BankAccountsService()
    
    @Published var transactions: [Transaction] = []
    @Published private(set) var categories: [Category] = []
    @Published var isLoading = false
    @Published var sortingType: SortingType = .forDate
    @Published var bankAccount: BankAccount?
    
    var totalAmount: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    func reloadTransactions() {
        
        isLoading = true
        defer { isLoading = false }
        Task {
            do {
                await fetchAccount()
                
                let categories = try await categoriesService.fetchCategories(direction: direction)
                await MainActor.run {
                    self.categories = categories
                }
                let calendar = Calendar.current
                let startDate = calendar.startOfDay(for: Date())
                guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return }
                
                let todayTransactions = try await transactionsService.fetchTransactions(from: startDate, to: endDate)
                
                await MainActor.run {
                    transactions = todayTransactions.filter { $0.category.direction == direction }
                }
                switch sortingType {
                case .forDate:
                    await MainActor.run {
                        self.transactions = transactions.sorted { $0.transactionDate > $1.transactionDate }
                    }
                   
                case .forAmount:
                    await MainActor.run {
                        transactions = transactions.sorted { $0.amount > $1.amount }
                    }
                }
                
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    private func fetchAccount() async {
        Task {
            do {
                bankAccount = try await bankAccountService.fetchPrimaryAccount()
            } catch {
                print("Ошибка загрузки счета: \(error.localizedDescription)")
            }
            
        }
    }
}
