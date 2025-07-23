//
//  String+Ext.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 12.07.2025.
//

import Foundation

extension String {
    var currencySymbol: String? {
        Currency(rawValue: self.uppercased())?.symbol
    }
}

extension String {
    public func convertToDecimal() -> Decimal {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let number = formatter.number(from: self) else {
            fatalError("Невозможно преобразовать \(self) в Decimal")
        }
        
        return number.decimalValue
    }
}
