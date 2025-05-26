import SwiftUI

struct HomeView: View {
    @Environment(\.sizeCategory) var sizeCategory

    // 1. Declare os StateObjects sem inicialização direta aqui
    // Eles serão inicializados no 'init' da View
    @StateObject private var planningVM: PlanningViewModel
    @StateObject private var expensesVM: ExpensesViewModel

    // 2. O HomeViewModel depende dos anteriores
    @StateObject private var viewModel: HomeViewModel

    @State private var isAddTransactionPresented = false

    @State private var selectedSubcategory: Subcategoria? = nil
    @State private var selectedCategory: Categoria? = nil

    // 3. Inicializador customizado para injetar as dependências corretamente
    init() {
        // Inicializa os StateObjects "independentes" primeiro
        let initialPlanningVM = PlanningViewModel()
        let initialExpensesVM = ExpensesViewModel()

        // Em seguida, inicializa o HomeViewModel, passando as instâncias criadas
        let initialHomeViewModel = HomeViewModel(
            planningViewModel: initialPlanningVM,
            expensesViewModel: initialExpensesVM
        )

        // Atribui as instâncias aos StateObjects
        _planningVM = StateObject(wrappedValue: initialPlanningVM)
        _expensesVM = StateObject(wrappedValue: initialExpensesVM)
        _viewModel = StateObject(wrappedValue: initialHomeViewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // MARK: - Seleção de Mês
                        MonthSelector(
                            viewModel: MonthSelectorViewModel(selectedMonth: viewModel.currentMonth),
                            onMonthChanged: { selectedDate in
                                viewModel.currentMonth = selectedDate // This will trigger the HomeViewModel to update
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
                        // Action for info button
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
                // É crucial passar o expensesVM aqui se AddTransactionView precisar dele
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
                // You can aadd logic here to display actual miniChart data from viewModel.miniChart
            )
    }

    // MARK: - Planejamento (Cartão 2)
    private var planningCard: some View {
        NavigationLink(destination: PlanningView(viewModel: planningVM)) { // Use planningVM diretamente para PlanningView
            VStack(alignment: .leading, spacing: 16) {
                Text("Planejamento")
                    .font(.headline)
                Text("Restante")
                    .font(.caption)
                    .foregroundStyle(.gray)

                HStack {
                    // Display either the remaining amount or the spent amount if over budget
                    Text(viewModel.restanteDoPlanejamento < 0 ?
                         viewModel.formatCurrency(viewModel.totalGastoEmPlanejado) :
                         viewModel.formatCurrency(viewModel.restanteDoPlanejamento))
                        .font(.title2)
                        .bold()
                        .foregroundStyle(viewModel.restanteDoPlanejamento < 0 ? .red : .primary)

                    Text("/ \(viewModel.formatCurrency(viewModel.totalPlanejado))")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                // ProgressView using actual spent and planned totals
                ProgressView(value: viewModel.totalGastoEmPlanejado, total: viewModel.totalPlanejado == 0 ? 1 : viewModel.totalPlanejado)
                    .accentColor(viewModel.restanteDoPlanejamento < 0 ? .red : .green) // Red if over budget, green otherwise
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
                        Text("🟪 Transporte - 50%") // This should be dynamic
                        Text("🟦 Alimentação - 30%") // This should be dynamic
                        Text("🟥 Lazer - 20%") // This should be dynamic
                    }

                    Spacer()

                    Circle() // This circle should reflect expense distribution
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
        // O .environmentObject(ExpensesViewModel()) aqui é importante para que o Preview
        // não falhe se ExpensesViewModel for um EnvironmentObject em alguma sub-view
        // que o Preview tenta renderizar.
        .environmentObject(ExpensesViewModel())
}
