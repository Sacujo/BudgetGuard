//
//  CategoriesService.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 13.06.2025.
//

import Foundation

final class CategoriesService {
    
//MARK: - Mock Data
    
    private let mockCategories: [Category] = [
        // Доходы (id: 1-50)
        Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true),
        Category(id: 2, name: "Фриланс", emoji: "💻", isIncome: true),
        Category(id: 3, name: "Инвестиции", emoji: "📈", isIncome: true),
        Category(id: 4, name: "Подарки", emoji: "🎁", isIncome: true),
        Category(id: 5, name: "Возврат долга", emoji: "↩️", isIncome: true),
        
        // Расходы (id: 51-100)
        Category(id: 51, name: "Продукты", emoji: "🛒", isIncome: false),
        Category(id: 52, name: "Кафе", emoji: "☕", isIncome: false),
        Category(id: 53, name: "Транспорт", emoji: "🚗", isIncome: false),
        Category(id: 54, name: "Жильё", emoji: "🏠", isIncome: false),
        Category(id: 55, name: "Развлечения", emoji: "🎭", isIncome: false),
        Category(id: 56, name: "Одежда", emoji: "👕", isIncome: false),
        Category(id: 57, name: "Здоровье", emoji: "🏥", isIncome: false),
        Category(id: 58, name: "Образование", emoji: "📚", isIncome: false),
        Category(id: 59, name: "Подарки", emoji: "🎁", isIncome: false),
        Category(id: 60, name: "Путешествия", emoji: "✈️", isIncome: false)
    ]
    
    //MARK: - Fetch All Categories
    
    func fetchCategories() async throws -> [Category] {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
        
        return mockCategories
    }
    
    //MARK: - Fetch Categories for Direction
    
    func fetchCategories(direction: Direction) async throws -> [Category] {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
        
        // Фильтрация по направлению
        let filteredCategories = mockCategories.filter { $0.direction == direction }
        
        return filteredCategories
    }
}
