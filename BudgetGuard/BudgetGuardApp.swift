//
//  BudgetGuardApp.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 12.06.2025.
//

import SwiftUI

@main
struct BudgetGuardApp: App {
    init() {
        navBar()
    }
    
    private func navBar () {
         let navBarAppearance = UINavigationBarAppearance()
         navBarAppearance.configureWithOpaqueBackground()
         navBarAppearance.backgroundColor = .systemGroupedBackground
         navBarAppearance.shadowColor = .clear
         UINavigationBar.appearance().standardAppearance = navBarAppearance
         if #available (iOS 15.0, *) {
             UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
         }

     }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
