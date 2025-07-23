//
//  TransactionsListView.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 19.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    
    @StateObject private var viewModel: TransactionsListViewModel
    @State var selectedTransaction: Transaction? = nil
    @State private var isCreatingTransaction = false
    
    init(direction: Direction) {
        _viewModel = StateObject(wrappedValue: TransactionsListViewModel(direction: direction))
    }
    
    private var selectedSorting: Binding<SortingType> {
        Binding<SortingType>(
            get: { viewModel.sortingType },
            set: { newOption in
                viewModel.sortingType = newOption
                viewModel.reloadTransactions()
                
            }
        )
    }
    
    @State private var showSortingMenu = false
    
    var body: some View {
        NavigationStack {
                ZStack(alignment: .bottomTrailing) {
                    List {
                        Section {
                            HStack {
                                Text("Всего")
                                Spacer()
                                Text("\(viewModel.totalAmount.formatted()) \(viewModel.bankAccount?.currency.symbol ?? "")")
                                    .foregroundStyle(Color(.text))
                            }
                        }
                        
                        Section(header: Text("Операции").font(.caption)) {
                            ForEach(viewModel.transactions) { transaction in
                                NavigationLink(destination: TransactionEditView(transaction, direction: viewModel.direction)) {
                                    TransactionRow(transaction: transaction)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    Button {
                        isCreatingTransaction = true
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 16,height: 16)
                            .padding(22)
                            .foregroundStyle(.white)
                            .background(Color.accent)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                    .background(Color(.background))
                }
                .navigationBarTitle(
                    viewModel.direction == .income ? "Доходы сегодня" : "Расходы сегодня"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: { showSortingMenu = true }) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .foregroundColor(Color(.toolBarItem))
                            }
                            NavigationLink(destination: HistoryListView(direction: viewModel.direction)) {
                                Image(systemName: "clock")
                                    .foregroundColor(Color(.toolBarItem))
                            }
                        }
                    }
                }
            }
        .sheet(isPresented: $isCreatingTransaction) {
            TransactionEditView(nil, direction: viewModel.direction)
        }
            .confirmationDialog("Сортировать по:", isPresented: $showSortingMenu, titleVisibility: .visible) {
                ForEach(SortingType.allCases) { newOption in
                    Button(newOption.rawValue) {
                        selectedSorting.wrappedValue = newOption
                    }
                }
                Button("Отмена", role: .cancel) {}
            }
            .refreshable {  viewModel.reloadTransactions()    }
            .task {
                viewModel.reloadTransactions()
            }
            .onChange(of: isCreatingTransaction) { isCreatingEnded in
                if !isCreatingEnded { viewModel.reloadTransactions() }
            }
            .onChange(of: selectedTransaction) { selected in
                if selected == nil {
                    viewModel.reloadTransactions()
                }
            }

        }
    }

#Preview {
    TransactionsListView(direction: .outcome)
}
