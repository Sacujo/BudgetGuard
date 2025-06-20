//
//  ContentView.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 12.06.2025.
//

import SwiftUI

struct ContentView: View {
    // Устанавливаем акцентный цвет
    init() {
        // Активная вкладка
        UITabBar.appearance().tintColor = UIColor(.accentColor)
        
        // Неактивные вкладки
        UITabBar.appearance().unselectedItemTintColor = .gray
    }
    
    var body: some View {
        TabView {
            // Вкладка "Расходы"
            TransactionsListView(direction: .outcome)
                .tabItem {
                    Image("downtrend")
                    Text("Расходы")
                }
            
            // Вкладка "Доходы"
            TransactionsListView(direction: .income)
                .tabItem {
                    Image("uptrend")
                    Text("Доходы")
                }
            
            // Вкладка "Счет"
            AccountView()
                .tabItem {
                    Image("calculator")
                    Text("Счет")
                }
            
            // Вкладка "Статьи"
            CategoriesView()
                .tabItem {
                    Image("bar-chart-side")
                    Text("Статьи")
                }
            
            // Вкладка "Настройки"
            SettingsView()
                .tabItem {
                    Image("gear")
                    Text("Настройки")
                }
        }
        .accentColor(Color(.accent))
    }
}

// Заглушки для экранов
struct AccountView: View { var body: some View { Text("Экран счета") } }
struct CategoriesView: View { var body: some View { Text("Экран статей") } }
struct SettingsView: View { var body: some View { Text("Экран настроек") }
}



#Preview {
    ContentView()
}
