//
//  Untitled.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 12.06.2025.
//
import Foundation


struct BankAccount: Identifiable, Codable, Hashable{
    let id: Int
    let name: String
    let balance: Decimal
    let currency: Currency
}








