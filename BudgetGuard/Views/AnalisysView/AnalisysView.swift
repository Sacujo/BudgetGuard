//
//  AnalisysView.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 11.07.2025.
//

import SwiftUI

 struct AnalysisView: UIViewControllerRepresentable {
     var direction: Direction

     func makeUIViewController(context: Context) -> AnalysisViewController {
         return AnalysisViewController(presenter: AnalysisPresenter(direction: direction))
     }

     func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) { }
 }
