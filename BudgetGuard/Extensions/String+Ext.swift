//
//  String+Ext.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 12.07.2025.
//


extension String {
    var currencySymbol: String? {
        Currency(rawValue: self.uppercased())?.symbol
    }
}
