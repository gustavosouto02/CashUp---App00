// Arquivo: CashUp/Views/Despesas/ExpensesView.swift
// Refatorado para receber ViewModel via EnvironmentObject e usar DisplayableExpense implicitamente

import SwiftUI
import SwiftData

struct ExpensesView: View {
    @EnvironmentObject var viewModel: ExpensesViewModel

    var body: some View {
        // let _ = Self._printChanges() // Para depuração

        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                MonthSelector( // Esta View precisa existir e funcionar como esperado
                    viewModel: MonthSelectorViewModel(selectedMonth: viewModel.currentMonth),
                    onMonthChanged: { selectedDate in
                        viewModel.currentMonth = selectedDate.startOfMonth()
                    }
                )

                .padding(.horizontal) // Exemplo se quisesse padding aqui

                ExpensesResumoView( // Esta View não muda, pois recebe Doubles
                    income: viewModel.totalIncomeForCurrentMonth(),
                    expense: viewModel.totalExpenseForCurrentMonth()
                )
                .padding(.horizontal) // Adiciona padding horizontal ao resumo

                ExpensesPorCategoriaListView(viewModel: viewModel)
                    // O frame, background e cornerRadius devem ser aplicados de forma consistente.
                    // Se este é um "card", aplicar aqui. Se for parte de um layout maior, pode ser diferente.
                    .frame(height: 250) // Aumentado um pouco a altura para melhor visualização
                     .background(Color(.systemGray6)) // Removido background aqui para um visual mais limpo, pode ser adicionado se preferir "card"
                     .cornerRadius(16)
                     .padding(.horizontal)

                Text("Extrato de Transações")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal) // Adicionado padding
                    // .padding(.horizontal, 8) // Ajuste de como era antes

                // ExpensesListView agora consome viewModel.transacoesExibidas que são DisplayableExpense
                ExpensesListView(viewModel: viewModel)
                     .background(Color(.systemGray6)) // Removido background aqui, a lista geralmente não tem seu próprio fundo de card assim
                     .cornerRadius(16) // Removido
                    .padding(.horizontal) // Adiciona padding horizontal à lista
                
            }
            .padding(.top) 
            .navigationTitle("Transações") // Título mais genérico
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Botão de Filtro.")
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    }
                }
            }
        }
    }
}
