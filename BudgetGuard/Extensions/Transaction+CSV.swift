//
//  Transaction+CSV.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 13.06.2025.
//

import Foundation

extension Transaction {
    static func parseCSV(from line: String) -> Transaction? {
        let components = line
            .split(separator: ",", omittingEmptySubsequences: false)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }

        guard components.count >= 14 else { return nil }

        let isoFormatter = ISO8601DateFormatter()

        guard let id = Int(components[0]),
              let accountId = Int(components[1]),
              let accountBalance = Decimal(string: components[3]),
              let categoryId = Int(components[5]),
              let categoryEmoji = components[7].first,
              let isIncome = Bool(components[8]),
              let amount = Decimal(string: components[9]),
              let transactionDate = isoFormatter.date(from: components[10]),
              let createdAt = isoFormatter.date(from: components[12]),
              let updatedAt = isoFormatter.date(from: components[13]) else {
            return nil
        }

        let account = AccountBrief(
            id: accountId,
            name: components[2],
            balance: accountBalance,
            currency: components[4]
        )

        let category = Category(
            id: categoryId,
            name: components[6],
            emoji: String(categoryEmoji),
            direction: isIncome ? Direction.income : Direction.outcome
        )

        let comment = components[11].isEmpty ? nil : components[11]

        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
