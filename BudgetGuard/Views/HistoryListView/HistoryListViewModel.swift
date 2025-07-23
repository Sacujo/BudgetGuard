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
    private let accountService: BankAccountsService = BankAccountsService()
    
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var categories: [Category] = []
    @Published var fromDate: Date
    @Published var toDate: Date
    @Published var isLoading = false
    @Published var sortingType: SortingType = .forDate
    @Published var bankAccount: BankAccount?
    
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
        await MainActor.run {
            isLoading = true
        }
        Task {
            do {
                
                await fetchAccount()
                
                let categories = try await categoriesService.fetchCategories(direction: direction)
                await MainActor.run {
                    self.categories = categories
                }
                let transactionsByPeriod = try await transactionsService.fetchTransactions(from: startOfDay, to: endOfDay)
                await MainActor.run {
                    transactions = transactionsByPeriod.filter { $0.category.direction == direction }
                }
                switch sortingType {
                case .forDate:
                    await MainActor.run {
                        transactions = transactions.sorted { $0.transactionDate > $1.transactionDate }
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
        await MainActor.run {
            isLoading = false
        }
    }
    
    private func fetchAccount() async {
        Task {
            do {
                bankAccount = try await accountService.fetchPrimaryAccount()
            } catch {
                print("Ошибка загрузки счета: \(error.localizedDescription)")
            }
            
        }
    }
}
