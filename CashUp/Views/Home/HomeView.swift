// Arquivo: CashUp/Views/Home/HomeView.swift
// Refatorado para SwiftData usando HomeViewModel corretamente

import SwiftUI
import SwiftData

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
                    
                    expensesCard
                        .padding(.horizontal)
                    
                    ResumoDespesasCardView(categoriasResumo: homeViewModel.categoriasResumo)
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
    
    // MARK: - Mini Gráfico (Cartão 1)
    private var miniChartCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Resumo Financeiro do Mês")
                .font(.headline)
            
            if homeViewModel.totalSpentMonth > 0 || homeViewModel.totalIncomeMonth > 0 {
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Receitas:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(homeViewModel.totalIncomeMonth, format: .currency(code: "BRL"))
                            .font(.title3.bold())
                            .foregroundStyle(.green)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Despesas:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(homeViewModel.totalSpentMonth, format: .currency(code: "BRL"))
                            .font(.title3.bold())
                            .foregroundStyle(.red)
                    }
                }
                .padding(.top, 4)
                
                HStack(alignment: .bottom, spacing: 8) {
                    let maxVal = max(homeViewModel.totalIncomeMonth, homeViewModel.totalSpentMonth, 1)
                    
                    BarView(value: homeViewModel.totalIncomeMonth, maxValue: maxVal, color: .green, label: "Receita")
                    BarView(value: homeViewModel.totalSpentMonth, maxValue: maxVal, color: .red, label: "Despesa")
                    if homeViewModel.totalIncomeMonth - homeViewModel.totalSpentMonth != 0 {
                        BarView(value: abs(homeViewModel.totalIncomeMonth - homeViewModel.totalSpentMonth),
                                maxValue: maxVal,
                                color: (homeViewModel.totalIncomeMonth - homeViewModel.totalSpentMonth) > 0 ? .blue : .orange,
                                label: (homeViewModel.totalIncomeMonth - homeViewModel.totalSpentMonth) > 0 ? "Saldo" : "Déficit")
                    }
                }
                .frame(height: 100)
                .padding(.top, 8)
                
            } else {
                Text("Nenhuma transação registrada este mês para exibir resumo.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 120, alignment: .center)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    struct BarView: View {
        let value: Double
        let maxValue: Double
        let color: Color
        let label: String
        
        var body: some View {
            VStack(spacing: 4) {
                Rectangle()
                    .fill(color)
                    .frame(width: 50, height: max(10, (value / maxValue) * 80))
                Text(label)
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
    }
    
    // MARK: - Planejamento (Cartão 2)
    private var planningCard: some View {

        NavigationLink {
            PlanningView()
                .environmentObject(homeViewModel.planningViewModel)
                .environmentObject(homeViewModel.expensesViewModel)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text("Planejamento do Mês")
                    .font(.headline)
                
                if homeViewModel.totalPlanejadoMes > 0 {  // corrigido para comparar valor
                
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
                    
                    ProgressView(value: homeViewModel.totalPlanejadoMes - homeViewModel.totalRestantePlanejadoMes,
                                 total: homeViewModel.totalPlanejadoMes > 0 ? homeViewModel.totalPlanejadoMes : 1)
                        .tint(homeViewModel.totalRestantePlanejadoMes < 0 ? .red : .green)


                    
                } else {
                    Text("Nenhum planejamento definido para este mês.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(minHeight: 60, alignment: .center)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .frame(maxWidth: .infinity, minHeight: 130)
        }
        .buttonStyle(PlainButtonStyle())
    }

    
    // MARK: - Despesas (Cartão 3)
    private var expensesCard: some View {
        NavigationLink {
            ExpensesView()
                .environmentObject(homeViewModel.expensesViewModel)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text("Despesas do Mês")
                    .font(.headline)
                
                if homeViewModel.totalSpentMonth > 0 {
                    Text("Total Gasto:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(homeViewModel.totalSpentMonth, format: .currency(code: "BRL"))
                        .font(.title2.bold())
                        .foregroundStyle(.red)
                } else {
                    Text("Nenhuma despesa registrada este mês.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(minHeight: 60, alignment: .center)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .frame(maxWidth: .infinity, minHeight: 130)
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
