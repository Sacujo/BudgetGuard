//
//  Untitled.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 20.06.2025.
//

import Foundation

enum SortingType: String, CaseIterable, Identifiable {
    case forDate = "По дате"
    case forAmount = "По сумме"
    
    var id: Self { self }
}
