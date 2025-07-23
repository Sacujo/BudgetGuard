//
//  BankAccountsService.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 13.06.2025.
//

import Foundation

final class BankAccountsService {
    
    private var client = NetworkClient.shared
    
    
    //MARK: - Fetch First Account
    func fetchPrimaryAccount() async throws -> BankAccount {
        // Имитация сетевой задержки
        let response: [BankAccountDTO] = try await client.request(.accounts)
        let accounts = response.map{$0.toDomain()}
        guard let firstAccount = accounts.first else {
            throw BankAccountError.noAccountsAvailable
        }
        return firstAccount
    }
    
    //MARK: - Update Account
    func updateAccount(_ account: BankAccount) async throws {
        do {
            try await sendUpdateFor(account)
        } catch {
            throw error
        }
   
    }
    
    
    func sendUpdateFor(_ account: BankAccount) async throws {
        let body = UpdateAccountRequest(from: account)
        _ = try await client.request(.updateAccount(id: account.id), body: body, responseType: EmptyBody.self)
    }
    
    
    
    //MARK: - BankAccountError
    
    enum BankAccountError: Error {
        case noAccountsAvailable
        case accountNotFound
    }
}
