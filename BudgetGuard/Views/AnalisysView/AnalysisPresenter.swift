//
//  AnalysisPresenter.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 11.07.2025.
//

import Foundation

protocol AnalysisPresenterProtocol: AnyObject {
    var view: AnalysisViewProtocol? { get set }
    var fromDate: Date { get set }
    var toDate: Date { get set }
    var sortingType: SortingType { get set }
    var transactions: [Transaction] { get }
    var categories: [Category] { get }
    var bankAccount: BankAccount? { get }
    var totalAmount: Decimal { get }
    func loadData()
}

final class AnalysisPresenter: AnalysisPresenterProtocol {
    
    var view: AnalysisViewProtocol?
    var fromDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date() {
        didSet {
            if fromDate > toDate {
                toDate = fromDate
            }
        }
    }
    var toDate: Date = Date() {
        didSet {
            if fromDate > toDate {
                fromDate = toDate
            }
        }
    }
    var sortingType: SortingType = .forDate
    var transactions: [Transaction] = []
    var categories: [Category] = []
    
    
    private(set) var totalAmount: Decimal = 0
    private(set) var bankAccount: BankAccount?
    
    private let direction: Direction
    private let transactionsService = TransactionsService()
    private let bankAccountService = BankAccountsService()
    private let categoriesService = CategoriesService()
 
    init(direction: Direction) {
        self.direction = direction
    }
    
    func loadData() {
        Task {
            await fetchTransactions()
            await fetchBankAccount()
            await MainActor.run {
                self.applySorting()
                self.recalculateTotalAmount()
                self.view?.reloadPickerTableView()
                self.view?.reloadTransactionTableView()
            }
        }
    }
    
    func fetchBankAccount() async {
        do {
            bankAccount = try await bankAccountService.fetchPrimaryAccount()
        } catch {
            print("Error fetching bank account: \(error.localizedDescription)")
        }
    }
    
    func fetchTransactions() async {
        
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: fromDate)
        let end = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: toDate) ?? Date()
        
        do {
            let categories = try await categoriesService.fetchCategories(direction: direction)
            self.categories = categories
            
            let transactionsByPeriod = try await transactionsService.fetchTransactions(from: start, to: end)
            transactions = transactionsByPeriod.filter { $0.category.direction == direction }
        } catch {
            print(error.localizedDescription)
        }
            
    }
    
    func recalculateTotalAmount() {
        totalAmount = transactions.reduce(0) { $0 + $1.amount }
    }
    
    func applySorting() {
        switch sortingType {
        case .forDate:
            transactions = transactions.sorted { $0.transactionDate > $1.transactionDate }
        case .forAmount:
            transactions = transactions.sorted { $0.amount > $1.amount }
        }
        
    }
}
