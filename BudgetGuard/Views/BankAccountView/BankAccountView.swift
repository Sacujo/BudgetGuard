//
//  BankAccountView.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 26.06.2025.
//

import SwiftUI

struct BankAccountView: View {
    
    @StateObject private var viewModel: BankAccountViewModel
    
    
    init() {
        _viewModel = StateObject(wrappedValue: BankAccountViewModel())
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        if let account = viewModel.account {
                            VStack(spacing: 16) {
                                if viewModel.isEditing {
                                    EditableBalanceCardView(balanceText: $viewModel.balanceInput)
                                    CurrencyCheckerView(selected: $viewModel.selectedCurrency)
                                } else {
                                    BalanceCardVIew(balance: account.balance, currency: account.currency, isBalanceHidden: $viewModel.isBalanceHidden)
                                    CurrencyCardView(currencyCode: account.currency)
                                }
                            }.padding(.horizontal)
                        } else {
                            ProgressView()
                        }
                    }
                    .padding(.vertical)
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle(Text("Мой счет"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { [ self] in viewModel.togleEditing() }) {
                            Group {
                                if viewModel.isEditing {
                                    Text("Save")
                                } else {
                                    Text("Edit")
                                }
                            }.foregroundStyle(Color.toolBarItem)
                        }
                    }
                }
                .refreshable{Task {
                    await viewModel.loadAccount()}
                }
                .task{await viewModel.loadAccount()}
            }
        }
    }
}

#Preview {
    BankAccountView()
}
