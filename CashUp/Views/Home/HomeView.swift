// Arquivo: CashUp/Views/Home/HomeView.swift
// Refatorado para SwiftData usando HomeViewModel corretamente
// Padding de todos os cards ajustado para consistência com o miniChartCard

import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.sizeCategory) var sizeCategory
    
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var expensesViewModel: ExpensesViewModel
    
    @State private var isAddTransactionPresented = false
    
    init(modelContext: ModelContext) {
        let planningVM = PlanningViewModel(modelContext: modelContext)
        let expensesVM = ExpensesViewModel(modelContext: modelContext)
        let homeVM = HomeViewModel(
            modelContext: modelContext,
            planningViewModel: planningVM,
            expensesViewModel: expensesVM
        )
        _homeViewModel = StateObject(wrappedValue: homeVM)
        _expensesViewModel = StateObject(wrappedValue: expensesVM)
    }
    
    var body: some View {
        let _ = Self._printChanges()
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    MonthSelector(
                        viewModel: MonthSelectorViewModel(selectedMonth: homeViewModel.currentMonth),
                        onMonthChanged: { selectedDate in
                            homeViewModel.currentMonth = selectedDate.startOfMonth()
                        }
                    )
                    .padding(.horizontal)
                    
                    miniChartCard
                        .padding(.horizontal)
                    
                    planningCard
                        .padding(.horizontal)
                    
                    expensesSummaryCombinedCard
                        .padding(.horizontal)
                    
                    Spacer(minLength: 24)
                }
                .padding(.top)
            }
            .navigationTitle("Visão Geral")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        print("Botão de Informações tocado.")
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .font(.headline)
                    }
                    
                    Button {
                        isAddTransactionPresented = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Registrar")
                        }
                        .font(.headline)
                    }
                }
            }
            .fullScreenCover(isPresented: $isAddTransactionPresented) {
                AddTransactionView()
                    .environmentObject(homeViewModel.expensesViewModel)
            }
            .onAppear {
                Task {
                    await popularDadosIniciaisSeNecessario(modelContext: modelContext)
                }
                homeViewModel.loadHomeData(for: homeViewModel.currentMonth)
            }
        }
    }
    
    // MARK: - Mini Gráfico (Cartão 1) - Gráfico Interativo de Despesas Diárias
    private var miniChartCard: some View {
        VStack(alignment: .leading) {
            Text("Gastos do Mês")
                .font(.headline)
            
            if !homeViewModel.dailyExpenseChartData.isEmpty && homeViewModel.dailyExpenseChartData.contains(where: { $0.totalExpenses > 0 }) {
                InteractiveDailyExpensesChart(dailyData: homeViewModel.dailyExpenseChartData)
                    .frame(height: 150)
            } else {
                HStack{
                    VStack(alignment: .leading){
                        Text("Nenhuma transação neste mês")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Spacer()
                    Spacer()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Planejamento (Cartão 2) - Estilo Ajustado para corresponder ao Despesas Card (com espaço vertical)
    private var planningCard: some View {
        NavigationLink {
            PlanningView()
                .environmentObject(homeViewModel.planningViewModel)
                .environmentObject(homeViewModel.expensesViewModel)
        } label: {
            VStack(alignment: .leading) { // This is the card's content view
                if homeViewModel.totalPlanejadoMes > 0 {
                    Text("Planejamento do Mês")
                        .font(.headline)
                    
                    Spacer()
                    Text("Restante do Orçamento")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Text(homeViewModel.totalRestantePlanejadoMes, format: .currency(code: "BRL"))
                            .font(.title2.bold())
                            .foregroundStyle(homeViewModel.totalRestantePlanejadoMes < 0 ? .red : .primary)
                        Text("/ \(homeViewModel.totalPlanejadoMes, format: .currency(code: "BRL"))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                    ProgressView(value: homeViewModel.totalPlanejadoMes - homeViewModel.totalRestantePlanejadoMes,
                                 total: homeViewModel.totalPlanejadoMes > 0 ? homeViewModel.totalPlanejadoMes : 1)
                    .tint(homeViewModel.totalRestantePlanejadoMes < 0 ? .red : .blue)
                } else {
                    HStack{
                        VStack(alignment: .leading){
                            Text("Planejamento do Mês")
                                .font(.headline)
                            Text("Nenhum planejamento definido para este mês.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        Spacer()
                        
                    }
                }
            }
            .padding() // 1. Inner padding
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(Color(.secondarySystemBackground)) // 3. Background
            .cornerRadius(12) // 4. Corner radius
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Despesas e Resumo Combinados (Novo Layout) - Estilo Ajustado
    private var expensesSummaryCombinedCard: some View {
        NavigationLink {
            ExpensesView()
                .environmentObject(homeViewModel.expensesViewModel)
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Despesas do Mês")
                        .font(.headline)
                        .padding(.bottom, 2)
                    
                    if homeViewModel.totalSpentMonth > 0 {
                        Text("Total Gasto:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(homeViewModel.totalSpentMonth, format: .currency(code: "BRL"))
                            .font(.title.bold())
                            .padding(.bottom, 6)
                        
                        if !homeViewModel.categoriasResumo.isEmpty {
                            Text("Categorias Principais")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 2)
                            ForEach(homeViewModel.categoriasResumo.prefix(3)) { item in
                                HStack(spacing: 6) {
                                    Rectangle()
                                        .fill(item.categoria.color)
                                        .frame(width: 10, height: 10)
                                        .cornerRadius(2)
                                    Text(item.categoria.nome)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(String(format: "%.0f%%", item.percentual * 100))
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            if homeViewModel.categoriasResumo.count > 3 {
                                HStack(spacing: 6) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.6))
                                        .frame(width: 10, height: 10)
                                        .cornerRadius(2)
                                    Text("Outras")
                                        .font(.caption)
                                        .lineLimit(1)
                                    let outrasPercent = homeViewModel.categoriasResumo.dropFirst(3).map { $0.percentual }.reduce(0, +)
                                    Text(String(format: "%.0f%%", outrasPercent * 100))
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    } else { // totalSpentMonth <= 0 (estado vazio para texto)
                        Text("Nenhuma despesa registrada este mês.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    if homeViewModel.totalSpentMonth > 0 && homeViewModel.categoriasResumo.isEmpty {
                        Text("Resumo por categoria indisponível.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
                .layoutPriority(1) // Dá prioridade de largura para o conteúdo de texto
                
                Spacer() // Este Spacer empurra o gráfico para a extremidade direita
                
                // GRÁFICO DE DESPESAS (à direita)
                if homeViewModel.totalSpentMonth > 0 && !homeViewModel.categoriasResumo.isEmpty {
                    let categoriesWithValues = homeViewModel.categoriasResumo.filter { $0.total > 0 } // Filtra para o gráfico
                    
                    if !categoriesWithValues.isEmpty { // Só mostra o gráfico se houver categorias com valores
                        Chart(categoriesWithValues) { item in
                            SectorMark(
                                angle: .value("Total Gasto", item.total),
                                innerRadius: .ratio(0.65),
                                angularInset: 1.5
                            )
                            .foregroundStyle(item.categoria.color)
                            .cornerRadius(5)
                            .accessibilityLabel(item.categoria.nome)
                            .accessibilityValue("\(String(format: "%.0f", item.percentual * 100))%")
                        }
                        .frame(width: 100, height: 100)
                    }
                }
            }
            .padding() // Padding interno do card
            .frame(maxWidth: .infinity, minHeight: 150) // minHeight conforme seu código
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
// Preview para HomeView
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Schema([
        CategoriaModel.self, SubcategoriaModel.self, ExpenseModel.self,
        CategoriaPlanejadaModel.self, SubcategoriaPlanejadaModel.self
    ]), configurations: [config])
    let modelContext = container.mainContext

    let catPrev = CategoriaModel(id: UUID(), nome: "Alimentação", icon: "fork.knife", color: .blue)
    modelContext.insert(catPrev)
    try? modelContext.save()

    return HomeView(modelContext: modelContext)
        .environment(\.modelContext, modelContext)
}
