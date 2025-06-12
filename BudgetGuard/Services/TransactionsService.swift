//
//  TransactionsService.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 13.06.2025.
//

import Foundation

final class TransactionsService {
    
//MARK: - MockData
    private var mockTransactions: [Transaction] = [
        Transaction(
            id: 1,
            accountId: 1,
            categoryId: 51,
            amount: -1500.00,
            transactionDate: Date().addingTimeInterval(-86400 * 3), // 3 дня назад
            comment: "Покупка продуктов",
            createdAt: Date().addingTimeInterval(-86400 * 3),
            updatedAt: Date().addingTimeInterval(-86400 * 3)
        ),
        Transaction(
            id: 2,
            accountId: 1,
            categoryId: 52,
            amount: -350.50,
            transactionDate: Date().addingTimeInterval(-86400 * 1), // 1 день назад
            comment: "Кофе с коллегой",
            createdAt: Date().addingTimeInterval(-86400 * 1),
            updatedAt: Date().addingTimeInterval(-86400 * 1)
        ),
        Transaction(
            id: 3,
            accountId: 1,
            categoryId: 1,
            amount: 50000.00,
            transactionDate: Date().addingTimeInterval(-86400 * 5), // 5 дней назад
            comment: "Зарплата за март",
            createdAt: Date().addingTimeInterval(-86400 * 5),
            updatedAt: Date().addingTimeInterval(-86400 * 5)
        )
    ]
    
//MARK: - Fetch Transaction For Period
    func fetchTransactions(forPeriod period: ClosedRange<Date>) async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 700_000_000) // Имитация задержки
        
        return mockTransactions.filter {
            period.contains($0.transactionDate)
        }.sorted {
            $0.transactionDate > $1.transactionDate // Сортировка по дате (новые сначала)
        }
    }
    
//MARK: - Create Transaction
    func createTransaction(_ transaction: Transaction) async throws -> Transaction {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        var newTransaction = transaction
        // Генерируем новый ID
        let newId = (mockTransactions.map { $0.id }.max() ?? 0) + 1
        
        newTransaction = Transaction(
            id: newId,
            accountId: transaction.accountId,
            categoryId: transaction.categoryId,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment,
            createdAt: Date(), // Текущая дата создания
            updatedAt: Date()  // Текущая дата обновления
        )
        
        mockTransactions.append(newTransaction)
        return newTransaction
    }
    
    
//MARK: - Update Transaction
    func updateTransaction(_ transaction: Transaction) async throws -> Transaction {
        try await Task.sleep(nanoseconds: 600_000_000)
        
        guard let index = mockTransactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw TransactionError.transactionNotFound
        }
        
        let updatedTransaction = Transaction(
            id: transaction.id,
            accountId: transaction.accountId,
            categoryId: transaction.categoryId,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment,
            createdAt: mockTransactions[index].createdAt, // Сохраняем оригинальную дату создания
            updatedAt: Date() // Обновляем дату изменения
        )
        
        mockTransactions[index] = updatedTransaction
        return updatedTransaction
    }
    
//MARK: - Delete Transaction
    func deleteTransaction(id: Int) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        guard let index = mockTransactions.firstIndex(where: { $0.id == id }) else {
            throw TransactionError.transactionNotFound
        }
        
        mockTransactions.remove(at: index)
    }
    
//MARK: - TransactionError
    enum TransactionError: Error {
        case transactionNotFound
        case invalidPeriod
    }
}
