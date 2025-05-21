//
//  CashUpApp.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 08/05/25.
//

import SwiftUI

@main
struct CashUpApp: App {
    @StateObject var expensesViewModel = ExpensesViewModel()
    @StateObject var planningViewModel = PlanningViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(expensesViewModel)
                .environmentObject(planningViewModel)
        }
    }
}

