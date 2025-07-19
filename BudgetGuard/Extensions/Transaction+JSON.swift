//
//  Transaction+JSON.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 13.06.2025.
//
import Foundation

extension Transaction {
    static func parse(jsonObject: Any) -> Transaction? {

        guard let dict = jsonObject as? [String: Any] else {
            return nil
        }

        guard let data = try? JSONSerialization.data(withJSONObject: dict) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try? decoder.decode(Transaction.self, from: data)
    }

    var jsonObject: Any {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(self) else {
            return [:]
        }

        return (try? JSONSerialization.jsonObject(with: data)) ?? [:]
    }
}
