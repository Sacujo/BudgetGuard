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
            "account": account,
            "category": category,
            "amount": amount.description,
            "transactionDate": ISO8601DateFormatter().string(from: transactionDate),
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
              let account = jsonDict["account"] as? BankAccount,
              let category = jsonDict["category"] as? Category,
              let amountString = jsonDict["amount"] as? String,
              let amount = Decimal(string: amountString),
              let dateString = jsonDict["transactionDate"] as? String,
              let date = ISO8601DateFormatter().date(from: dateString),
              let comment = jsonDict["comment"] as? String
        else
        
        {
            return nil
        }
        
        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: date,
            comment: comment
        )
    }
}
