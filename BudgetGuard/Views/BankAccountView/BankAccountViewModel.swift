//
//  BankAccountViewModel.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 26.06.2025.
//

import Foundation

@MainActor
final class BankAccountViewModel: ObservableObject {
    
    private let bankAccountService: BankAccountsService = BankAccountsService()
    
    @Published var account: BankAccount?
    @Published var isEditing = false
    @Published var isBalanceHidden = false
    @Published var balanceInput = ""
    @Published var selectedCurrency: String = Currency.rub.rawValue
    @Published var balanceChanges: [(date: Date, change: Decimal)] = []
    @Published var balanceHistory: [(date: Date, balance: Decimal)] = []
    
    func loadAccount() async {
        do {
            let account = try await bankAccountService.fetchPrimaryAccount()
            self.account = account
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveChanges() async {
        guard let account else { return }
        
        let formattedInput = balanceInput
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let pattern = #"^-?\d*\.?\d*$"#
        if formattedInput.range(of: pattern, options: .regularExpression) != nil, let newBalance = Decimal(string: formattedInput ) {
            let updatedAccount = BankAccount(
                id: account.id,
                name: account.name,
                balance: newBalance,
                currency: Currency(rawValue: selectedCurrency)!, // Поправить
            )
            
            do {
                try await bankAccountService.updateAccount(updatedAccount)
                self.account = updatedAccount
                isEditing = false
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func togleEditing() {
        if isEditing {
            Task { await saveChanges() }
    } else {
        isEditing.toggle()
            if let account = account {
                balanceInput = "\(account.balance)"
            }
        }
    }
    
    // Загрузка истории баланса за 30 дней
    func loadBalanceHistory() async {
        guard let account = account else { return }
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -29, to: endDate) else { return }
        do {
            let transactions = try await TransactionsService().fetchTransactions(accountId: account.id, from: startDate, to: endDate)
            // Группируем транзакции по дню
            var dailyChanges: [Date: Decimal] = [:]
            for tx in transactions {
                let day = calendar.startOfDay(for: tx.transactionDate)
                // Прибавляем доходы, вычитаем расходы
                let change = tx.category.isIncome ? tx.amount : -tx.amount
                dailyChanges[day, default: 0] += change
            }
            // Считаем баланс на каждый день, начиная с 0 на первую дату
            var history: [(date: Date, balance: Decimal)] = []
            var currentBalance: Decimal = 0
            for offset in 0...29 {
                let day = calendar.date(byAdding: .day, value: -29 + offset, to: endDate)!
                // Сначала добавляем баланс на начало дня
                history.append((date: day, balance: currentBalance))
                // Затем прибавляем изменения за этот день
                let change = dailyChanges[day] ?? 0
                currentBalance += change
            }
            self.balanceHistory = history
        } catch {
            print(error.localizedDescription)
        }
    }
}
