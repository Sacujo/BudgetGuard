//
//  CategoryRow.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 04.07.2025.
//

import SwiftUI

struct CategoryRow: View {
    // MARK: - Properties
    let category: Category
    
    var body: some View {
        HStack(alignment: .center) {
            Text(String(category.emoji))
                .font(.system(size: .emojiFontSize))
                .padding(.emojiPadding)
                .background(Circle().fill(Color.emojiBackground))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
            }
        }
    }
}

// MARK: - Constants
fileprivate extension Int {
    static let numberOfCommentLines: Int = 1
}

fileprivate extension CGFloat {
    static let emojiFontSize: CGFloat = 20
    static let emojiPadding: CGFloat = 4
}
