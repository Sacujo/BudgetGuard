//
//  NetworkingService.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 18.07.2025.
//

import Foundation

protocol BankAccountServiceProtocol {
    func fetchAccount() async throws -> BankAccount
    func updateAccount(_ account: BankAccount) async throws
}


protocol CategoriesServiceProtocol {
    func fetchCategories() async throws -> [Category]
    func fetchCategories(direction: Direction) async throws -> [Category]
}


protocol TransactionsServiceProtocol {
    func fetchTransactions(from: Date, to: Date) async throws -> [Transaction]
    func createTransaction(_ transaction: Transaction) async throws
    func updateTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(by id: Int) async throws
}

