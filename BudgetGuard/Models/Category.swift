//
//  Category.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 12.06.2025.
//
import Foundation

struct Category: Identifiable, Codable, Hashable {

    let id: Int
    let name: String
    let emoji: String
    let direction: Direction

    private enum CodingKeys: String, CodingKey {
        case id, name, emoji, isIncome
    }

    init(from decoder: Decoder) throws {
        let coder = try decoder.container(keyedBy: CodingKeys.self)

        id = try coder.decode(Int.self, forKey: .id)
        name  = try coder.decode(String.self, forKey: .name)
        emoji = try coder.decode(String.self, forKey: .emoji)

        let isIncome = try coder.decode(Bool.self, forKey: .isIncome)
        direction = isIncome ? .income : .outcome
    }

    func encode(to encoder: Encoder) throws {
        var coder = encoder.container(keyedBy: CodingKeys.self)

        try coder.encode(id, forKey: .id)
        try coder.encode(name, forKey: .name)
        try coder.encode(emoji, forKey: .emoji)

        try coder.encode(direction == .income, forKey: .isIncome)
    }
}

extension Category {
    init(id: Int, name: String, emoji: String, direction: Direction) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.direction = direction
    }
}
