//
//  Transaction.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 12.06.2025.
//
import Foundation

struct Transaction: Identifiable, Codable, Hashable {
    let id: Int
    let account: AccountBrief
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case account
        case category
        case amount
        case transactionDate
        case comment
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.account = try container.decode(AccountBrief.self, forKey: .account)
        self.category = try container.decode(Category.self, forKey: .category)
        self.amount = try container.decodeDecimalString(forKey: .amount)
        self.transactionDate = try container.decode(Date.self, forKey: .transactionDate)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    init(id: Int, account: AccountBrief, category: Category, amount: Decimal,
         transactionDate: Date, comment: String?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.account = account
        self.category = category
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.account, forKey: .account)
        try container.encode(self.category, forKey: .category)
        try container.encodeDecimalString(self.amount, forKey: .amount)
        try container.encode(self.transactionDate, forKey: .transactionDate)
        try container.encodeIfPresent(self.comment, forKey: .comment)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encode(self.updatedAt, forKey: .updatedAt)
    }
}
