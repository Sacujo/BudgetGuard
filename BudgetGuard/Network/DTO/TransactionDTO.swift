//
//  TransactionDTO.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 23.07.2025.
//

import Foundation

struct CreateTransactionRequest: Encodable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String
    
    init(from transaction: Transaction) {
        let isoDate = ISO8601DateFormatter().string(from: transaction.transactionDate)
        accountId = transaction.account.id
        categoryId = transaction.category.id
        amount = "\(transaction.amount)"
        transactionDate = isoDate
        comment = transaction.comment ?? ""
    }
}

struct UpdateTransactionRequest: Encodable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
    
    
    init(from transaction: Transaction) {
        let isoDate = ISO8601DateFormatter().string(from: transaction.transactionDate)
        accountId = transaction.account.id
        categoryId = transaction.category.id
        amount = "\(transaction.amount)"
        transactionDate = isoDate
        comment = transaction.comment ?? ""
    }
//    static func from(_ transaction: Transaction) -> UpdateTransactionRequest {
//        UpdateTransactionRequest(
//            accountId: transaction.account.id,
//            categoryId: transaction.category.id,
//            amount: NSDecimalNumber(decimal: transaction.amount).stringValue,
//            transactionDate: iso8601Formatter.string(from: transaction.transactionDate),
//            comment: transaction.comment ?? ""
//        )
//    }
}

struct TransactionResponseDTO: Decodable, Identifiable {
    let id: Int
    let account: TransactionAccountDTO
    let category: TransactionCategoryDTO
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
    
    
    
    private static let iso8601FormatterWithMs: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    func toDomain() -> Transaction {
        let amountDecimal = Decimal(string: amount) ?? -1
        let date = Self.iso8601FormatterWithMs.date(from: transactionDate)
            ?? Self.iso8601Formatter.date(from: transactionDate)
        let parsedDate = date
        
        return Transaction(
            id: id,
            account: account.toDomain(),
            category: category.toDomain(),
            amount: amountDecimal,
            transactionDate: parsedDate ?? Date(),
            comment: comment == "" ? nil : comment
        )
    }
}

struct TransactionCategoryDTO: Decodable, Identifiable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
    
    func toDomain() -> Category {
        return Category(id: id, name: name, emoji: emoji.first ?? " ", isIncome: isIncome)
    }
}

struct TransactionAccountDTO: Decodable, Identifiable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
    
    func toDomain() -> BankAccount {
        let decimalBalance = Decimal(string: balance)
        return BankAccount(
            id: id,
            name: name,
            balance: decimalBalance ?? -1,
            currency: Currency(rawValue: currency) ?? .rub
        )
    }
    
    typealias TransactionListResponseDTO = [TransactionResponseDTO]
    
}
