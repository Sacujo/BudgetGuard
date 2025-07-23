//
//  KeyedEncodingContainer+Decimal.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 21.07.2025.
//

import Foundation

extension KeyedEncodingContainer {
    mutating func encodeDecimalString(_ value: Decimal,
                                      forKey key: KeyedEncodingContainer<K>.Key) throws {
        try encode(NSDecimalNumber(decimal: value).stringValue, forKey: key)
    }
}
