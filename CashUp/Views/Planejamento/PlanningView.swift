// Arquivo: CashUp/Views/Planejamento/PlanningView.swift
// Refatorado para receber ViewModels via EnvironmentObject

import SwiftUI
import SwiftData

struct PlanningView: View {
    // Remove @Environment(\.modelContext) daqui, pois os ViewModels já virão configurados.
    @Environment(\.sizeCategory) var sizeCategory

    // ViewModels agora são injetados via @EnvironmentObject pela HomeView.
    @EnvironmentObject var planningViewModel: PlanningViewModel
    @EnvironmentObject var expensesViewModel: ExpensesViewModel // Necessário para PlanningRestanteView

    @State private var isEditing: Bool = false
    // Armazena IDs de SubcategoriaPlanejadaModel para deleção
    @State private var subcategoriasPlanejadasSelecionadasParaDelecao: Set<UUID> = []
    
    // O init() que tentava criar os @StateObjects foi removido.
    // A View agora é mais simples e espera que os ViewModels sejam fornecidos.

    var body: some View {
        let _ = Self._printChanges() // Para depuração

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    MonthSelector(
                        viewModel: MonthSelectorViewModel(selectedMonth: planningViewModel.currentMonth),
                        onMonthChanged: { selectedDate in
                            let newMonth = selectedDate.startOfMonth()
                            // Atualiza o mês em AMBOS os ViewModels injetados
                            planningViewModel.currentMonth = newMonth
                            expensesViewModel.currentMonth = newMonth
                        }
                    )
                    .padding(.horizontal)

                    PlanningSummarySection(planningViewModel: planningViewModel) // Passa o @EnvironmentObject
                        .padding(.horizontal) // Adicionado padding aqui também

                    Picker("Modo", selection: $planningViewModel.selectedTab) {
                        Text("Planejar").tag(0)
                        Text("Restante").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if planningViewModel.selectedTab == 0 {
                        PlanningPlanejarView(
                            viewModel: planningViewModel, // Passa o @EnvironmentObject
                            isEditing: $isEditing,
                            subcategoriasSelecionadas: $subcategoriasPlanejadasSelecionadasParaDelecao
                        )
                        .id("PlanejarView-\(planningViewModel.currentMonth.timeIntervalSince1970)")
                        .padding(.horizontal)
                    } else {
                        PlanningRestanteView(
                            planningViewModel: planningViewModel, // Passa o @EnvironmentObject
                            expensesViewModel: expensesViewModel  // Passa o @EnvironmentObject
                        )
                        .id("RestanteView-\(planningViewModel.currentMonth.timeIntervalSince1970)")
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Planejamento")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if planningViewModel.selectedTab == 0 {
                        if isEditing {
                            Button("Apagar Selecionados") {
                                planningViewModel.removerSubcategoriasPlanejadasSelecionadas(idsSubcategoriasPlanejadas: subcategoriasPlanejadasSelecionadasParaDelecao)
                                subcategoriasPlanejadasSelecionadasParaDelecao.removeAll()
                                isEditing = false
                            }
                            .foregroundStyle(.red)
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
        // O .task para reconfigurar ViewModels foi removido,
        // pois eles agora são injetados e já devem estar configurados.
    }
}

// PlanningSummarySection permanece como estava, recebendo o PlanningViewModel
// (que agora é um @EnvironmentObject na PlanningView).
struct PlanningSummarySection: View { //
    @ObservedObject var planningViewModel: PlanningViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Resumo do Planejamento do Mês")
                .font(.headline)
                .padding(.bottom, 4)
            
            let totalPlanejado = planningViewModel.valorTotalPlanejadoParaMesAtual()
            
            if totalPlanejado > 0 {
                HStack {
                    Text("Total Planejado:")
                        .font(.subheadline)
                    Spacer()
                    Text(totalPlanejado, format: .currency(code: "BRL"))
                        .font(.subheadline.bold())
                }
            } else {
                Text("Nenhum valor planejado para este mês ainda.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        // Removido padding horizontal aqui, pois a PlanningView já aplica padding ao container do VStack.
    }
}


#Preview {
    // Preview de PlanningView agora precisa simular a injeção dos EnvironmentObjects
    // e do ModelContainer.
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container: ModelContainer
    do {
        container = try ModelContainer(for: Schema([
            CategoriaModel.self, SubcategoriaModel.self, ExpenseModel.self,
            CategoriaPlanejadaModel.self, SubcategoriaPlanejadaModel.self
        ]), configurations: [config])
        
        let modelContext = container.mainContext
        
        // Criar ViewModels para o preview
        let planningVM = PlanningViewModel(modelContext: modelContext)
        let expensesVM = ExpensesViewModel(modelContext: modelContext)

        // Definir um mês para consistência no preview
        let testMonth = Date().startOfMonth()
        planningVM.currentMonth = testMonth
        expensesVM.currentMonth = testMonth
        
        // Opcional: popular dados de seed ou exemplos aqui para o preview
        // Task { @MainActor popularDadosIniciaisSeNecessario(modelContext: modelContext) }

        return PlanningView()
            .modelContainer(container) // Essencial para qualquer @Query ou @Environment(\.modelContext) nas subviews
            .environmentObject(planningVM)
            .environmentObject(expensesVM)

    } catch {
        return Text("Erro ao configurar preview para PlanningView: \(error.localizedDescription)")
    }
}
