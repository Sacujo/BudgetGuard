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
                userId: account.userId,
                name: account.name,
                balance: newBalance,
                currency: selectedCurrency,
                createdAt: account.createdAt,
                updatedAt: Date()
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
}
