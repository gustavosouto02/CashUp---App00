import SwiftUI

struct HomeView: View {
    @Environment(\.sizeCategory) var sizeCategory
    @StateObject private var viewModel = MonthSelectorViewModel()
    @State private var isAddTransactionPresented = false
    
    @State private var selectedSubcategory: Subcategoria? = nil
    @State private var selectedCategory: Categoria? = nil

    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // MARK: - Seleção de Mês
                        MonthSelector(
                            displayedMonth: viewModel.selectedMonth,
                            onPrevious: { viewModel.navigateMonth(isNext: false) },
                            onNext: { viewModel.navigateMonth(isNext: true) }
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
                        // ação do botão de info
                    }) {
                        Image(systemName: "info.circle.fill")
                            .font(.headline)
                    }
                    
                    Button(action: {
                        // ação do botão de registrar
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
                    .foregroundColor(.white)
                    .font(.body)
            )
    }

    // MARK: - Planejamento (Cartão 2)
    private var planningCard: some View {
        NavigationLink(destination: PlanningView()) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Planejamento")
                    .font(.headline)
                Text("Sobrou para gastar")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("R$ 100")
                        .font(.title2)
                        .bold()
                    Text("/ 700")
                        .font(.caption)
                }
                ProgressView(value: 100, total: 700)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .frame(minHeight: 150)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Despesas (Cartão 3)
    private var expensesCard: some View {
        NavigationLink(destination: ExpensesView()) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Despesas")
                    .font(.headline)
                Text("Categorias principais")
                    .font(.caption)
                    .foregroundColor(.gray)
                
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
}
