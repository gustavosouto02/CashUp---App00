import SwiftUI

struct PlanningView: View {
    @Environment(\.sizeCategory) var sizeCategory
    @ObservedObject var viewModel = PlanningViewModel() // Seu ViewModel principal de planejamento
    @EnvironmentObject var expensesViewModel: ExpensesViewModel // Adicione o EnvironmentObject

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
                            // Sincroniza o month do expensesViewModel também
                            expensesViewModel.currentMonth = selectedDate
                        }
                    )
                    .padding()

                    // MARK: - Resumo do Planejamento do Mês
                    // Extraímos este bloco em uma sub-view se for muito grande
                    PlanningSummarySection(viewModel: viewModel)

                    // MARK: - Seletor Planejar / Restante
                    Picker("Modo", selection: $viewModel.selectedTab) {
                        Text("Planejar").tag(0)
                        Text("Restante").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal) // Adicionado padding aqui para o picker

                    // MARK: - Conteúdo das Abas
                    // Agora as abas são delegadas a ViewComponents menores
                    if viewModel.selectedTab == 0 {
                        PlanningPlanejarView(
                            viewModel: viewModel,
                            isEditing: $isEditing,
                            subcategoriasSelecionadas: $subcategoriasSelecionadas
                        )
                        .padding(.horizontal) // Adiciona padding horizontal para a sub-view
                    } else {
                        PlanningRestanteView(
                            planningViewModel: viewModel,
                            expensesViewModel: expensesViewModel // Passe o expensesViewModel aqui
                        )
                        .padding(.horizontal) // Adiciona padding horizontal para a sub-view
                    }
                }
                .padding(.top)
                .padding(.bottom, 24)
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
                            .foregroundStyle(.red)
                            .padding(.trailing, 8)
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

// MARK: - Componente para o Resumo do Planejamento
struct PlanningSummarySection: View {
    @ObservedObject var viewModel: PlanningViewModel

    var body: some View {
        Group {
            if !viewModel.planejamentoDoMesExibicao.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Planejamentos do Mês")
                        .font(.headline)

                    ForEach(viewModel.planejamentoDoMesExibicao) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.descricao)
                                .font(.subheadline)
                            Text("Data: \(item.data, style: .date)")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            Text("Valor Planejado: \(item.valorTotalPlanejado, format: .currency(code: "BRL"))")
                                .font(.caption)
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal) // Aplica padding apenas a esta seção
            }
        }
        .padding(.bottom, 24) // Espaçamento após o resumo
    }
}

#Preview {
    PlanningView()
        .environmentObject(ExpensesViewModel()) // Certifique-se de injetar no Preview também
}
