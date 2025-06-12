//
//  Transaction.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 12.06.2025.
//
import Foundation

struct Transaction: Codable, Identifiable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}
