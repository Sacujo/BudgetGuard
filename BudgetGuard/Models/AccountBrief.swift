//
//  AccountBrief.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 21.07.2025.
//

import Foundation

struct AccountBrief: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case balance
        case currency
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.balance = try container.decodeDecimalString(forKey: .balance)
        self.currency = try container.decode(String.self, forKey: .currency)
    }

    init(id: Int, name: String, balance: Decimal, currency: String) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currency = currency
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encodeDecimalString(self.balance, forKey: .balance)
        try container.encode(self.currency, forKey: .currency)
    }
}
