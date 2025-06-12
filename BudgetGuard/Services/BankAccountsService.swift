//
//  BankAccountsService.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 13.06.2025.
//

import Foundation

final class BankAccountsService {
//MARK: - Mock Data
    private var mockAccounts: [BankAccount] = [
        BankAccount(
            id: 1,
            userId: 123,
            name: "Основной счет",
            balance: 15000.50,
            currency: "RUB",
            createdAt: Date().addingTimeInterval(-86400 * 30), // 30 дней назад
            updatedAt: Date().addingTimeInterval(-86400 * 2)   // 2 дня назад
        ),
        BankAccount(
            id: 2,
            userId: 123,
            name: "Резервный счет",
            balance: 5000.00,
            currency: "USD",
            createdAt: Date().addingTimeInterval(-86400 * 15),
            updatedAt: Date().addingTimeInterval(-86400)
        )
    ]
    
    //MARK: - Fetch First Account
       func fetchPrimaryAccount() async throws -> BankAccount {
           // Имитация сетевой задержки
           try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
           
           guard let firstAccount = mockAccounts.first else {
               throw BankAccountError.noAccountsAvailable
           }
           
           return firstAccount
       }
    
    //MARK: - Update Account
        func updateAccount(_ account: BankAccount) async throws -> BankAccount {
            // Имитация сетевой задержки
            try await Task.sleep(nanoseconds: 800_000_000) // 0.8 секунды
            
            guard let index = mockAccounts.firstIndex(where: { $0.id == account.id }) else {
                throw BankAccountError.accountNotFound
            }
            
            // Обновляем счет и устанавливаем текущую дату как updatedAt
            var updatedAccount = account
            updatedAccount = BankAccount(
                id: account.id,
                userId: account.userId,
                name: account.name,
                balance: account.balance,
                currency: account.currency,
                createdAt: account.createdAt,
                updatedAt: Date() // Обновляем дату изменения
            )
            
            mockAccounts[index] = updatedAccount
            return updatedAccount
        }
    
    
    //MARK: - BankAccountError

       enum BankAccountError: Error {
           case noAccountsAvailable
           case accountNotFound
       }
}
