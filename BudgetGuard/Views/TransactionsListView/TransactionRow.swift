//
//  TransactionRow.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 20.06.2025.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    let category: Category
    
    var body: some View {
        HStack(spacing: 12) {
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
            
            Spacer()
            
            Text("\(transaction.amount.formatted()) ₽")
        }
    }
}
