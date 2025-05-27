// Arquivo: CashUp/Views/Despesas/ExpensesView.swift
// Refatorado para receber ViewModel via EnvironmentObject

import SwiftUI
import SwiftData

struct ExpensesView: View {
    @EnvironmentObject var viewModel: ExpensesViewModel

    var body: some View {
        let _ = Self._printChanges() // Para depuração

        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                MonthSelector(
                    viewModel: MonthSelectorViewModel(selectedMonth: viewModel.currentMonth),
                    onMonthChanged: { selectedDate in
                        viewModel.currentMonth = selectedDate.startOfMonth()
                    }
                )

                ExpensesResumoView( //
                                   income: viewModel.totalIncomeForCurrentMonth(),
                                   expense: viewModel.totalExpenseForCurrentMonth()
                )
                
                ExpensesPorCategoriaListView(viewModel: viewModel) //
                    .frame(height: 200)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .frame(maxWidth: .infinity)
                
                Text("Extrato de Transações")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                
                ExpensesListView(viewModel: viewModel) //
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
            }
            .padding()
            .navigationTitle("Despesas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // ação para filtros
                        print("Botão de Filtro de Despesas tocado.")
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container: ModelContainer
    do {
        container = try ModelContainer(for: Schema([
            CategoriaModel.self, SubcategoriaModel.self, ExpenseModel.self
        ]), configurations: [config])
        
        let modelContext = container.mainContext
        
        // Criar ViewModel para o preview
        let expensesVM = ExpensesViewModel(modelContext: modelContext)
        expensesVM.currentMonth = Date().startOfMonth()

        return ExpensesView()
            .modelContainer(container) 
            .environmentObject(expensesVM)

    } catch {
        return Text("Erro ao configurar preview para ExpensesView: \(error.localizedDescription)")
    }
}
