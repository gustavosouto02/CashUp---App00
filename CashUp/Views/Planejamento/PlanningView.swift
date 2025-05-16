//
//  PlanningView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 12/05/25.
//

import SwiftUI

struct PlanningView: View {
    @Environment(\.sizeCategory) var sizeCategory
    @ObservedObject var viewModel = PlanningViewModel()

    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Header
                    MonthSelector(
                        viewModel: MonthSelectorViewModel(selectedMonth: viewModel.currentMonth),
                        onMonthChanged: { selectedDate in
                            viewModel.currentMonth = selectedDate
                        }
                    )

                    List {
                        ForEach(viewModel.planejamentoDoMes) { item in
                            VStack(alignment: .leading) {
                                Text(item.descricao)
                                Text("Data: \(item.data, style: .date)")
                                Text("Valor Planejado: \(item.valorTotalPlanejado, format: .currency(code: "BRL"))")
                            }
                        }
                    }

                    Picker("Modo", selection: $viewModel.selectedTab) {
                        Text("Planejar").tag(0)
                        Text("Restante").tag(1)
                    }
                    .pickerStyle(.segmented)

                    if viewModel.selectedTab == 0 {
                        PlanningPlanejarView(viewModel: viewModel) // Passando a mesma instância
                    } else {
                        PlanningRestanteView()
                    }
                }
                .padding()
                .onAppear {
                }
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
