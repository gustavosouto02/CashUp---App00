// Arquivo: CashUp/Views/Planejamento/PlanningView.swift
// Refatorado para receber ViewModels via EnvironmentObject

import SwiftUI
import SwiftData

struct PlanningView: View {
    @Environment(\.sizeCategory) var sizeCategory

    @EnvironmentObject var planningViewModel: PlanningViewModel
    @EnvironmentObject var expensesViewModel: ExpensesViewModel

    @State private var isEditing: Bool = false
    // Armazena IDs de SubcategoriaPlanejadaModel para deleção
    @State private var subcategoriasPlanejadasSelecionadasParaDelecao: Set<UUID> = []

    var body: some View {
        let _ = Self._printChanges()

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    MonthSelector(
                        viewModel: MonthSelectorViewModel(selectedMonth: planningViewModel.currentMonth),
                        onMonthChanged: { selectedDate in
                            let newMonth = selectedDate.startOfMonth()
                            planningViewModel.currentMonth = newMonth
                            expensesViewModel.currentMonth = newMonth
                        }
                    )
                    .padding(.top, 20)
                    .padding(.horizontal)

                    Picker("Modo", selection: $planningViewModel.selectedTab) {
                        Text("Planejar").tag(0)
                        Text("Restante").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if planningViewModel.selectedTab == 0 {
                        PlanningPlanejarView(
                            viewModel: planningViewModel,
                            isEditing: $isEditing,
                            subcategoriasSelecionadas: $subcategoriasPlanejadasSelecionadasParaDelecao
                        )
                        .id("PlanejarView-\(planningViewModel.currentMonth.timeIntervalSince1970)")
                    } else {
                        PlanningRestanteView(
                            planningViewModel: planningViewModel,
                            expensesViewModel: expensesViewModel
                        )
                        .id("RestanteView-\(planningViewModel.currentMonth.timeIntervalSince1970)")
                    }
                }
            }
            .navigationTitle("Planejamento")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if planningViewModel.selectedTab == 0 {
                        if isEditing {
                            Button(action: {
                                planningViewModel.removerSubcategoriasPlanejadasSelecionadas(idsSubcategoriasPlanejadas: subcategoriasPlanejadasSelecionadasParaDelecao)
                                subcategoriasPlanejadasSelecionadasParaDelecao.removeAll()
                                isEditing = false
                            }) {
                                Image(systemName: "trash.fill")
                            }
                            .foregroundStyle(.red)
                            .disabled(subcategoriasPlanejadasSelecionadasParaDelecao.isEmpty)
                        }

                        Button(action: {
                            isEditing.toggle()
                            if !isEditing {
                                subcategoriasPlanejadasSelecionadasParaDelecao.removeAll()
                            }
                        }) {
                            Text(isEditing ? "Concluir" : "Editar")
                        }
                    }
                }
            }
        }
    }
}

