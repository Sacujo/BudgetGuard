//
//  TransactionsListView.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 19.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    
    @StateObject private var viewModel: TransactionsListViewModel
    
    init(direction: Direction) {
        _viewModel = StateObject(wrappedValue: TransactionsListViewModel(direction: direction))
    }
    
    private var selectedSorting: Binding<SortingType> {
        Binding<SortingType>(
            get: { viewModel.sortingType },
            set: { newOption in
                viewModel.sortingType = newOption
                Task { await viewModel.reloadTransactions() }
                
            }
        )
    }
    
    @State private var showSortingMenu = false
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            NavigationView {
                VStack(alignment: .leading) {
                    Text(viewModel.direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                        .font(.largeTitle).bold()
                        .padding(.leading)
                        .padding(8)
                    
                    List {
                        Section {
                            HStack {
                                Text("Всего")
                                Spacer()
                                Text("\(viewModel.totalAmount.formatted()) ₽")
                                    .foregroundStyle(Color(.text))
                            }
                        }
                        
                        Section(header: Text("Операции").font(.caption)) {
                            ForEach(viewModel.transactions) { transaction in
                                NavigationLink(destination: EmptyView()) {
                                    TransactionRow(transaction: transaction, category: viewModel.category(for: transaction))
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                .background(Color(.background))
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
            .accentColor(Color(.toolBarItem))
            
        }
        .confirmationDialog("Сортировать по:", isPresented: $showSortingMenu, titleVisibility: .visible) {
            ForEach(SortingType.allCases) { newOption in
                Button(newOption.rawValue) {
                    selectedSorting.wrappedValue = newOption
                }
            }
            Button("Отмена", role: .cancel) {}
        }
        .task {
            await viewModel.reloadTransactions()
        }
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}
