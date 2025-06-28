//
//  Untitled.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 28.06.2025.
//

import SwiftUI

struct BalanceCardVIew: View {
    
    let balance: Decimal
    let currency: String
    @Binding var isBalanceHidden: Bool
    
    private var currencySymbol: String {
            Currency(rawValue: currency)?.symbol ?? currency
        }
    
    var body: some View {
        HStack {
            Text("💰   Баланс")
                .font(.system(size: 17, weight: .regular))
            Spacer()
            
            Text("\(balance) \(currencySymbol)")
                .font(.system(size: 17, weight: .regular))
                .spoiler(isOn: $isBalanceHidden)
                                             .onShake {
                                                 withAnimation(.easeIn(duration: 0.4)) {
                                                     isBalanceHidden.toggle()
                                                 }
                                             }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 44, idealHeight: 44)
        .background(Color.accent)
        .cornerRadius(10)
    }
}


