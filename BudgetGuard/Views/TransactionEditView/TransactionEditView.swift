//
//  TransactionEditView.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 12.07.2025.
//
import SwiftUI

 struct TransactionEditView: View {
     @Environment(\.dismiss) private var dismiss
     var direction: Direction
     @FocusState private var isAmountFocused: Bool
     @StateObject var viewModel: TransactionEditViewModel
     @State private var showValidationAlert = false
     @State private var showDeleteConfirmation = false

     init(_ transaction: Transaction?, direction: Direction) {
         self.direction = direction
         _viewModel = StateObject(wrappedValue: TransactionEditViewModel(transaction, direction: direction))
     }
     var body: some View {
         NavigationStack {
             editList
                 .navigationTitle(
                     direction == .income ? "Мои Доходы" : "Мои Расходы"
                 )
                 .navigationBarBackButtonHidden(true)
                 .toolbar {
                     ToolbarItem(placement: .navigationBarLeading) {
                         Button(action: {
                             dismiss()
                         }) {
                             HStack {
                                 Text("Отменить")
                             }
                             .foregroundStyle(.toolBarItem)
                         }
                     }
                     ToolbarItem(placement: .navigationBarTrailing) {
                         Button(action: {
                             if viewModel.category == nil || viewModel.amount == nil {
                                 showValidationAlert = true
                             } else {
                                 viewModel.saveTransaction()
                                 dismiss()
                             }
                         }) {
                             HStack {
                                 Text(viewModel.state == .editing ? "Сохранить" : "Создать")
                             }
                             .foregroundStyle(Color.toolBarItem)
                         }
                     }
                 }
         }
         .alert("Заполните все поля", isPresented: $showValidationAlert) {
             Button("Ок", role: .cancel) {}
         }
         .alert("Удалить запись?", isPresented: $showDeleteConfirmation) {
             Button("Удалить", role: .destructive) {
                 viewModel.deleteTransaction()
                 dismiss()
             }
             Button("Отмена", role: .cancel) {}
         } message: {
             Text("Вы уверены, что хотите удалить этот \(direction == .income ? "доход" : "расход")?")
         }
         .task { await viewModel.loadData() }
     }
     @ViewBuilder
     var editList: some View {
         List {
             Section {
                 HStack {
                     Text("Статья")
                     Spacer()
                     Menu {
                         ForEach(viewModel.categories, id: \.id) { category in
                             Button(action: { viewModel.category = category }) {
                                 Text(category.name)
                             }
                         }
                     } label: {
                         HStack {
                             Text(viewModel.category?.name ?? "Не выбрано")
                                 .foregroundStyle(Color.gray)
                             Image("Drill-in")
                                 .foregroundStyle(.secondary)
                         }
                     }
                 }
                 HStack {
                     Text("Сумма")
                     Spacer()
                     TextField("Пусто", text: $viewModel.amountString)
                         .keyboardType(.decimalPad)
                         .multilineTextAlignment(.trailing)
                         .foregroundStyle(.secondary)
                         .focused($isAmountFocused)
                         .onChange(of: isAmountFocused) {
                             if !isAmountFocused {
                                 viewModel.updateBalance()
                             }
                         }
                     Text(viewModel.currency.symbol)
                         .foregroundStyle(.secondary)
                 }
                 HStack {
                     Text("Дата")
                     Spacer()
                     DatePicker(
                         "",
                         selection: $viewModel.transactionDate,
                         in: ...Date(),
                         displayedComponents: .date
                     )
                     .labelsHidden()
                     .background(.emojiBackground)
                 }
                 HStack {
                     Text("Время")
                     Spacer()
                     DatePicker("", selection: $viewModel.transactionDate, displayedComponents: .hourAndMinute)
                         .labelsHidden()
                         .background(.emojiBackground)
                 }
                 TextField("Комментарий", text: $viewModel.comment)
                     .multilineTextAlignment(.leading)
             }
             if viewModel.state == .editing {
                 Section {
                     Button(action: {
                         showDeleteConfirmation = true
                     }) {
                         Text("Удалить \(direction == .income ? "доход" : "расход")")
                             .foregroundStyle(.red)
                     }
                 }
             }
         }
     }
 }

 // MARK: - Preview

// #Preview {
//     TransactionEditView(TransactionsServicetransactions[5], direction: .outcome)
// }
