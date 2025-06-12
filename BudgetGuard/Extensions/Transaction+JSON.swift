//
//  Transaction+JSON.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 13.06.2025.
//
import Foundation

extension Transaction {
    var jsonObject: Any {
        var dictionary: [String: Any] = [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": amount.description,
            "transactionDate": ISO8601DateFormatter().string(from: transactionDate),
            "createdAt": ISO8601DateFormatter().string(from: createdAt),
            "updatedAt": ISO8601DateFormatter().string(from: updatedAt)
        ]
        
        // Добавляем comment только если он не nil
        if let comment = comment {
            dictionary["comment"] = comment
        }
        
        return dictionary
    }
    
    static func parse(jsonObject: Any) -> Transaction? {
        guard let jsonDict = jsonObject as? [String: Any] else { return nil }
        
        guard let id = jsonDict["id"] as? Int,
              let accountId = jsonDict["accountId"] as? Int,
              let categoryId = jsonDict["categoryId"] as? Int,
              let amountString = jsonDict["amount"] as? String,
              let amount = Decimal(string: amountString),
              let dateString = jsonDict["transactionDate"] as? String,
              let date = ISO8601DateFormatter().date(from: dateString),
              let comment = jsonDict["comment"] as? String,
              let createdAtString = jsonDict["createdAt"] as? String,
              let createdAt = ISO8601DateFormatter().date(from: createdAtString),
              let updatedAtString = jsonDict["updatedAt"] as? String,
              let updatedAt = ISO8601DateFormatter().date(from: updatedAtString)
        else
        
        {
            return nil
        }
        
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: date,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
