//
//  CurrencyChecker.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 28.06.2025.
//

import SwiftUI

struct CurrencyCheckerView: View {
    @Binding var selected: String
    @State var showCurrencyDialog: Bool = false
    
    private var selectedCurrency: Currency? {
        Currency(rawValue: selected)
    }
    
    var body: some View {
        
        HStack {
            Text("Валюта")
                .font(.system(size: 17, weight: .regular))
            Spacer()
            
            HStack(spacing: 4) {
                if let currency = selectedCurrency {
                    Text(currency.symbol)
                        .font(.system(size: 17, weight: .regular))
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 44, idealHeight: 44)
        .background(Color(.white))
        .cornerRadius(10)
        .contentShape(Rectangle())
        .onTapGesture {
            showCurrencyDialog.toggle()
        }
        .confirmationDialog("Валюты", isPresented: $showCurrencyDialog, titleVisibility: .visible) {
            ForEach(Currency.allCases) { currency in
                Button("\(currency.fullName)") {
                    if selected != currency.rawValue {
                        selected = currency.rawValue
                    }
                }
            }
        }.tint(Color.toolBarItem)
    }
}

