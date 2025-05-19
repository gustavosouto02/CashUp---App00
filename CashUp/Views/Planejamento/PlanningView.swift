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
    @State private var isEditing: Bool = false
    @State private var subcategoriasSelecionadas: Set<UUID> = []

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Header: Navegação por mês
                    MonthSelector(
                        viewModel: MonthSelectorViewModel(selectedMonth: viewModel.currentMonth),
                        onMonthChanged: { selectedDate in
                            viewModel.currentMonth = selectedDate
                        }
                    )
                    
                    // MARK: - Resumo do Planejamento do Mês
                    if !viewModel.planejamentoDoMes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Planejamentos do Mês")
                                .font(.headline)
                            
                            ForEach(viewModel.planejamentoDoMes) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.descricao)
                                        .font(.subheadline)
                                    Text("Data: \(item.data, style: .date)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("Valor Planejado: \(item.valorTotalPlanejado, format: .currency(code: "BRL"))")
                                        .font(.caption)
                                }
                                //.padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    // MARK: - Seletor Planejar / Restante
                    Picker("Modo", selection: $viewModel.selectedTab) {
                        Text("Planejar").tag(0)
                        Text("Restante").tag(1)
                    }
                    .pickerStyle(.segmented)
                    
                    // MARK: - Conteúdo das Abas
                    if viewModel.selectedTab == 0 {
                        PlanningPlanejarView(
                            viewModel: viewModel,
                            isEditing: $isEditing,
                            subcategoriasSelecionadas: $subcategoriasSelecionadas
                        )
                    } else {
                        PlanningRestanteView()
                    }
                }
                .padding()
            }
            .navigationTitle("Planejamento")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        if isEditing {
                            Button("Apagar") {
                                viewModel.removerSubcategoriasSelecionadas(subcategoriasSelecionadas)
                                subcategoriasSelecionadas.removeAll()
                                isEditing = false
                            }
                        }

                        Button(action: {
                            isEditing.toggle()
                            if !isEditing {
                                subcategoriasSelecionadas.removeAll()
                            }
                        }) {
                            Image(systemName: isEditing ? "checkmark.circle.fill" : "ellipsis.circle")
                        }
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
