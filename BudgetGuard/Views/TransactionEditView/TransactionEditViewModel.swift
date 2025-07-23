//
//  TransactionEditViewModel.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 12.07.2025.
//

import Foundation

enum TransactionEditState {
    case editing
    case adding
}

final class TransactionEditViewModel: ObservableObject {
    
    let state: TransactionEditState
    
    @Published var category: Category?
    @Published var amount: Decimal?
    @Published var transactionDate =  Date()
    @Published var comment: String = ""
    @Published private(set) var categories: [Category] = []
    @Published var amountString: String = ""
    @Published private(set) var currency: Currency = .rub
    
    
    private var transaction: Transaction?
    private let direction: Direction
    private var bankAccount: BankAccount?
    
    private let categoriesService = CategoriesService()
    private let bankAccountService = BankAccountsService()
    private let transactionsService = TransactionsService()
    
    init(_ transaction: Transaction?, direction: Direction) {
        self.direction = direction
        
        if let transaction {
            self.state = .editing
            self.transaction = transaction
        } else {
            self.state = .adding
        }
    }
    
    func loadData() async {
        await fetchCategories()
        await fetchAccount()
        if let transaction {
            category = transaction.category
        }
    }
    
    func saveTransaction() {
            guard
                let category,
                let amount,
                let bankAccount
            else {
                return
            }
            switch state {
            case .adding:
                Task {
                    do {
                        try await transactionsService.createTransaction(
                            Transaction(
                                id: 1,
                                account: bankAccount,
                                category: category,
                                amount: amount,
                                transactionDate: transactionDate,
                                comment: comment == "" ? nil : comment
                            )
                        )
                        print("Операция создана")
                    } catch {
                        print("Ошибка создания операции: \(error.localizedDescription)")
                    }
                }
            case .editing:
                guard let transaction else {
                    return
                }
                Task {
                    do {
                        let updated = Transaction(
                            id: transaction.id,
                            account: bankAccount,
                            category: category,
                            amount: amount,
                            transactionDate: transactionDate,
                            comment: comment == "" ? nil : comment,
                        )
                       try await transactionsService.updateTransaction(updated)
                        print("Операция обновлена: \(updated)")
                    } catch {
                        print("Ошибка обновлении операции: \(error.localizedDescription)")
                    }
                }
            }
        }
    
    func deleteTransaction()  {
        guard let transaction else { return }
        Task {
            do {
                try await transactionsService.deleteTransaction(withId: transaction.id)
            } catch {
                print("Ошибка удаления операции: \(error.localizedDescription)")
            }
        }
    }
    
    func updateBalance() {
            let normalized = amountString
                .components(separatedBy: .whitespacesAndNewlines).joined()
                .replacingOccurrences(of: ",", with: ".")
            if let value = Decimal(string: normalized) {
                amountString = value.formatted()
                amount = value
            } else {
                amountString = ""
                amount = nil
            }
        }
    
    private func fetchCategories() async {
        do {
            categories = try await categoriesService.fetchCategories(direction: direction)
        } catch {
            print("Ошибка загрузки категорий: \(error.localizedDescription)")
        }
    }
    
    private func fetchAccount() async {
        do {
            bankAccount = try await bankAccountService.fetchPrimaryAccount()
            guard let accountCurrency = bankAccount?.currency else { return }
            self.currency = accountCurrency
        } catch {
            print("Ошибка загрузки счета: \(error.localizedDescription)")
        }
    }
    
    
}
