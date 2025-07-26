//
//  TransactionsService.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 13.06.2025.
//

import Foundation

final class TransactionsService {
    
//MARK: - MockData
    private let client = NetworkClient.shared
    
    private var mockTransactions: [Transaction] = [
        
//        Transaction(
//            id: 1,
//            accountId: 1,
//            categoryId: 51,
//            amount: 1500.00,
//            transactionDate: Date(), // 3 дня назад
//            comment: "Покупка продуктов",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 2,
//            accountId: 1,
//            categoryId: 51,
//            amount: 1500.00,
//            transactionDate: Date(), // 3 дня назад
//            comment: "Покупка продуктов",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 3,
//            accountId: 1,
//            categoryId: 51,
//            amount: 1500.00,
//            transactionDate: Date(), // 3 дня назад
//            comment: "Покупка продуктов",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 4,
//            accountId: 1,
//            categoryId: 51,
//            amount: 1500.00,
//            transactionDate: Date().addingTimeInterval(-86400 * 3), // 3 дня назад
//            comment: "Покупка продуктов",
//            createdAt: Date().addingTimeInterval(-86400 * 3),
//            updatedAt: Date().addingTimeInterval(-86400 * 3)
//        ),
//        Transaction(
//            id: 5,
//            accountId: 1,
//            categoryId: 52,
//            amount: 350.50,
//            transactionDate: Date().addingTimeInterval(-86400 * 1), // 1 день назад
//            comment: "Кофе с коллегой",
//            createdAt: Date().addingTimeInterval(-86400 * 1),
//            updatedAt: Date().addingTimeInterval(-86400 * 1)
//        ),
//        Transaction(
//            id: 7,
//            accountId: 1,
//            categoryId: 1,
//            amount: 50000.00,
//            transactionDate: Date().addingTimeInterval(-86400 * 5), // 5 дней назад
//            comment: "Зарплата за март",
//            createdAt: Date().addingTimeInterval(-86400 * 5),
//            updatedAt: Date().addingTimeInterval(-86400 * 5)
//        ),
//        Transaction(
//            id: 6,
//            accountId: 1,
//            categoryId: 52,
//            amount: 350.50,
//            transactionDate: Date(),
//            comment: "Кофе с коллегой",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 8,
//            accountId: 1,
//            categoryId: 52,
//            amount: 350.50,
//            transactionDate: Date(),
//            comment: "Кофе с коллегой",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 9,
//            accountId: 1,
//            categoryId: 52,
//            amount: 350.50,
//            transactionDate: Date(),
//            comment: "Кофе с коллегой",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 10,
//            accountId: 1,
//            categoryId: 52,
//            amount: 350.50,
//            transactionDate: Date(),
//            comment: "Кофе с коллегой",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 11,
//            accountId: 1,
//            categoryId: 52,
//            amount: 350.50,
//            transactionDate: Date(),
//            comment: "Кофе с коллегой",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 12,
//            accountId: 1,
//            categoryId: 52,
//            amount: 350.50,
//            transactionDate: Date(),
//            comment: "Кофе с коллегой",
//            createdAt: Date(),
//            updatedAt: Date()
//        )
    ]
    
//MARK: - Fetch Transaction For Period
    
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
//        try await Task.sleep(nanoseconds: 700_000_000) // Имитация задержки
        let response: [TransactionResponseDTO] = try await client.request(.transactionsPeriod(accountId: 86, startDate: startDate, endDate: endDate))
        print("🔹 Response: \(response)")
        let transactions = response.map { $0.toDomain()}
        print("🔹 Transactions: \(transactions)")
        return transactions.filter {
            $0.transactionDate >= startDate && $0.transactionDate <= endDate
        }.sorted {
            $0.transactionDate > $1.transactionDate // Сортировка по дате (новые сначала)
        }
    }
    
    // Новый метод для получения транзакций по accountId
    func fetchTransactions(accountId: Int, from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        let response: [TransactionResponseDTO] = try await client.request(.transactionsPeriod(accountId: accountId, startDate: startDate, endDate: endDate))
        let transactions = response.map { $0.toDomain() }
        return transactions.filter {
            $0.transactionDate >= startDate && $0.transactionDate <= endDate
        }.sorted {
            $0.transactionDate > $1.transactionDate
        }
    }
    
//MARK: - Create Transaction
    func createTransaction(_ transaction: Transaction) async throws {
        let body = CreateTransactionRequest(from: transaction)
        _ = try await client.request(.createTransaction, body: body, responseType: EmptyBody.self)
    }
    
    
//MARK: - Update Transaction
    func updateTransaction(_ transaction: Transaction) async throws {
        
        let body = UpdateTransactionRequest(from: transaction)
        _ = try await client.request(.updateTransaction(id: transaction.id), body: body, responseType: EmptyBody.self)
        
        
//        try await Task.sleep(nanoseconds: 600_000_000)
//        
//        guard let index = mockTransactions.firstIndex(where: { $0.id == transaction.id }) else {
//            throw TransactionError.transactionNotFound
//        }
//        
//        let updatedTransaction = Transaction(
//            id: transaction.id,
//            account: transaction.account,
//            category: transaction.category,
//            amount: transaction.amount,
//            transactionDate: transaction.transactionDate,
//            comment: transaction.comment,
//            createdAt: mockTransactions[index].createdAt, // Сохраняем оригинальную дату создания
//            updatedAt: Date() // Обновляем дату изменения
//        )
//        
//        mockTransactions[index] = updatedTransaction
//        return updatedTransaction
    }
    
//MARK: - Delete Transaction
    func deleteTransaction(withId id: Int) async throws {
        try await client.request(.deleteTransaction(id: id), responseType: EmptyBody.self)
        
//        try await Task.sleep(nanoseconds: 500_000_000)
//        
//        guard let index = mockTransactions.firstIndex(where: { $0.id == id }) else {
//            throw TransactionError.transactionNotFound
//        }
//        
//        mockTransactions.remove(at: index)
    }
    
//MARK: - TransactionError
    enum TransactionError: Error {
        case transactionNotFound
        case invalidPeriod
    }
}
