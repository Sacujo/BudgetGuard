//
//  BankAccountDTO.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 23.07.2025.
//

import Foundation

struct UpdateAccountRequest: Encodable {
    let name: String
    let balance: String
    let currency: String
    
    init(from account: BankAccount) {
        name = account.name
        balance = Self.posixDecimalFormatter.string(from: account.balance as NSDecimalNumber)
        ?? "0.00"
        currency = account.currency.rawValue
        
    }
    
    static let posixDecimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // Гарантирует точку как разделитель
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2 // или сколько требует ваш бэкенд
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = "" // Без разделителей тысяч (1000, а не 1,000)
        return formatter
    }()
}


struct BankAccountDTO: Identifiable, Codable, Hashable {
    let id: Int
    let userId: Int
    let name: String
    let balance: String
    let currency: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case name
        case balance
        case currency
        case createdAt
        case updatedAt
    }

    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.userId = try container.decode(Int.self, forKey: .userId)
        self.name = try container.decode(String.self, forKey: .name)
        self.balance = try container.decode(String.self, forKey: .balance)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
    
    func toDomain() -> BankAccount {
        let decimalBalance = Decimal(string: balance)
        return BankAccount(
            id: id,
            name: name,
            balance: decimalBalance ?? -1,
            currency: Currency(rawValue: currency) ?? .rub
        )
    }
}
