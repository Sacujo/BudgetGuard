//
//  TransactionRow.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 20.06.2025.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    @State private var category: Category?
    private let categoriesService = CategoriesService()

    var body: some View {
        HStack(spacing: 12) {
            if let category = category {
                ZStack {
                    Circle()
                        .fill(Color(.emojiBackground))
                        .frame(width: 22, height: 22)

                    Text(String(category.emoji))
                        .font(.system(size: 12))
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.body)

                    if let comment = transaction.comment {
                        Text(comment)
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundColor(.gray)
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    Text(transaction.comment ?? "")
                        .font(.body)
                }
            }

            Spacer()

            HStack(spacing: 14) {
                Text("\(transaction.amount.formatted()) ₽")

                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.text))
                    .font(.system(size: 13, weight: .semibold))
            }
        }
        .onAppear {
            Task {
                let categories = try? await categoriesService.fetchCategories()
                category = categories?.first(where: { $0.id == transaction.categoryId })
            }
        }
    }
}
