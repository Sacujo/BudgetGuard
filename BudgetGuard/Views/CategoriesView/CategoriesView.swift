//
//  CategoriesView.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 04.07.2025.
//

import SwiftUI

struct CategoriesView: View {
    // MARK: - Properties
    @StateObject private var viewModel: CategoriesViewModel
    
    // MARK: - Lifecycle
    init() {
        _viewModel = StateObject(wrappedValue: CategoriesViewModel())
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(String.categoriesSectionTitle) {
                    ForEach(viewModel.filteredCategories) { category in
                        CategoryRow(
                            category: category
                        )
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(String.categoriesTitle)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Поиск статей"
            ) {
                // Подсказки при поиске
                ForEach(viewModel.suggestions, id: \.self) { suggestion in
                    Text(suggestion).searchCompletion(suggestion)
                        .tint(Color.toolBarItem)
                }
            }
            .task {
                await viewModel.fetchCategories()
            }
        }
    }
}

// MARK: - Constants
fileprivate extension String {
    static let categoriesTitle: String = "Мои статьи"
    static let categoriesSectionTitle: String = "СТАТЬИ"
}

#Preview {
    CategoriesView()
}
