//
//  PlanningView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 12/05/25.
//

import SwiftUI

struct PlanningView: View {
    @Environment(\.sizeCategory) var sizeCategory
    @StateObject private var monthViewModel = MonthSelectorViewModel()
    @StateObject private var planningViewModel = PlanningViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Header
                    MonthSelector(
                        displayedMonth: monthViewModel.selectedMonth,
                        onPrevious: { monthViewModel.navigateMonth(isNext: false) },
                        onNext: { monthViewModel.navigateMonth(isNext: true) }
                    )
                    
                    Picker("Modo", selection: $planningViewModel.selectedTab) {
                        Text("Planejar").tag(0)
                        Text("Restante").tag(1)
                    }
                    .pickerStyle(.segmented)
                    
                    if planningViewModel.selectedTab == 0 {
                        PlanningPlanejarView(viewModel: planningViewModel)
                    } else {
                        PlanningRestanteView()
                    }
                }
                .padding()
            }
            .navigationTitle("Planejamento")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // ação do menu
                    }) {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .overlay(
                Divider()
                    .background(Color.gray.opacity(0.6))
                    .frame(height: 1)
                    .padding(.top, 2),
                alignment: .top
            )
        }
    }
}

#Preview {
    PlanningView()
}
