import SwiftUI

struct HomeView: View {
    @Environment(\.sizeCategory) var sizeCategory
    @StateObject private var viewModel = HomeViewModel(planningViewModel: PlanningViewModel())
    @State private var isAddTransactionPresented = false
    
    @State private var selectedSubcategory: Subcategoria? = nil
    @State private var selectedCategory: Categoria? = nil
    
    @StateObject private var expensesVM = ExpensesViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // MARK: - Seleção de Mês
                        MonthSelector(
                            viewModel: MonthSelectorViewModel(selectedMonth: viewModel.planningViewModel.currentMonth),
                            onMonthChanged: { selectedDate in
                                viewModel.currentMonth = selectedDate
                            }
                        )
                        
                        // MARK: - Cartão 1: Gráfico de gastos
                        miniChartCard
                        
                        // MARK: - Cartão 2: Planejamento
                        planningCard
                        
                        // MARK: - Cartão 3: Despesas
                        expensesCard
                    }
                    .padding()
                    .overlay(
                        Divider()
                            .background(Color.gray)
                            .frame(height: 1)
                            .padding(.top, 2),
                        alignment: .top
                    )
                }
            }
            .navigationTitle("Visão Geral")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: {
                    }) {
                        Image(systemName: "info.circle.fill")
                            .font(.headline)
                    }
                    
                    Button(action: {
                        isAddTransactionPresented = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Registrar")
                        }
                        .font(.headline)
                    }
                }
            }
            .fullScreenCover(isPresented: $isAddTransactionPresented) {
                AddTransactionView(
                    selectedSubcategory: $selectedSubcategory,
                    selectedCategory: $selectedCategory
                )
                .environmentObject(expensesVM)
            }
            .onAppear() {
                viewModel.loadHomeData(for: Date())
            }
        }
    }
    
    // MARK: - Mini Gráfico (Cartão 1)
    private var miniChartCard: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 200)
            .overlay(
                Text("Mini Gráfico")
                    .foregroundStyle(.white)
                    .font(.body)
                // Text(\(viewModel.miniChartData))
            )
    }
    
    // MARK: - Planejamento (Cartão 2)
    private var planningCard: some View {
        NavigationLink(destination: PlanningView(viewModel : viewModel.planningViewModel)) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Planejamento")
                    .font(.headline)
                Text("Total planejado para o mês")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                HStack {
                    Text("R$ 200") // lofica de total gasto do planejamento
                        .font(.title2)
                        .bold()
                    Text("/ R$ \(viewModel.planningViewModel.valorTotalPlanejado(categorias: viewModel.planningViewModel.categoriasPlanejadas), specifier: "%.2f")")
    
                }
                ProgressView( value: 200, total: viewModel.planningViewModel.valorTotalPlanejado(categorias: viewModel.planningViewModel.categoriasPlanejadas))
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .frame(minHeight: 150)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Despesas (Cartão 3)
    private var expensesCard: some View {

        NavigationLink(destination: ExpensesView().environmentObject(expensesVM)) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Despesas")
                    .font(.headline)
                Text("Categorias principais")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🟪 Transporte - 50%")
                        Text("🟦 Alimentação - 30%")
                        Text("🟥 Lazer - 20%")
                    }
                    
                    Spacer()
                    
                    Circle()
                        .trim(from: 0.0, to: 1.0)
                        .stroke(LinearGradient(colors: [.purple, .blue, .pink], startPoint: .top, endPoint: .bottom), lineWidth: 12)
                        .frame(width: 60, height: 60)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
        .environmentObject(ExpensesViewModel())
}
