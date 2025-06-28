//
//  EditableBalanceCardView.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 28.06.2025.
//

import SwiftUI

struct EditableBalanceCardView: View {
    
    @Binding var balanceText: String
    
    var body: some View {
        HStack {
            Text("💰   Баланс")
                .font(.system(size: 17, weight: .regular))
            Spacer()
            TextField("0", text: $balanceText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 17, weight: .regular))
                .onChange(of: balanceText) { newValue in
                    let replaced = newValue.replacingOccurrences(of: ",", with: ".")
                    var filtered = replaced.filter { "0123456789.-".contains($0) }
                    if filtered.contains("-") {
                        filtered.removeAll { $0 == "-" }
                        filtered.insert("-", at: filtered.startIndex)
                    }
                    var dotCount = 0
                    filtered = filtered.reduce(into: "") { result, char in
                        if char == "." {
                            dotCount += 1
                            if dotCount == 1 {
                                result.append(char)
                            }
                        } else {
                            result.append(char)
                        }
                    }
                    
                    balanceText = filtered
                }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 44, idealHeight: 44)
        .background(Color(.white))
        .cornerRadius(10)
    }
}
