//
//  Currencies.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 26.06.2025.
//

enum Currency: String, CaseIterable, Identifiable {
    case usd = "USD"
    case rub = "RUB"
    case eur = "EUR"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .usd:
            return "$"
        case .rub:
            return "₽"
        case .eur:
            return "€"
        }
    }
    
    var name: String {
        switch self {
        case .usd:
            return "Американский доллар"
        case .rub:
            return "Российский рубль"
        case .eur:
            return "Евро"
        }
    }
    
    var fullName: String {
        return "\(name) \(symbol)"
    }
    
}
