//
//  ExpensesView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 08/05/25.
//

import SwiftUI

struct ExpensesView: View {
    @EnvironmentObject var viewModel: ExpensesViewModel
    @State private var selectedTransactionType: Int = 0

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - Header: Navegação por mês
                MonthSelector(
                    viewModel: MonthSelectorViewModel(selectedMonth: viewModel.currentMonth),
                    onMonthChanged: { selectedDate in
                        viewModel.currentMonth = selectedDate
                    }
                )

                // MARK: - Resumo do mês
                ExpensesResumoView(
                    income: viewModel.totalIncome(),
                    expense: viewModel.totalExpense()
                )

                // MARK: - Picker de tipo de transação (ainda não está em uso)
                TransactionPicker(selectedTransactionType: $selectedTransactionType)
                
                ExpensesPorCategoriaListView(viewModel: viewModel)
                    .frame(height: 200) // Ajustável, se necessário
                    .background(Color(.systemGray6)) // Define o fundo
                    .cornerRadius(16) // Aplica o arredondamento de canto
                    .frame(maxWidth: .infinity) // Garante que ocupe a largura total
                                

                
                Text("Extrato de Despesas")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                
                // MARK: - Lista de despesas e rendas
                ExpensesListView(viewModel: viewModel)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
            }
            .padding()
            .navigationTitle("Despesas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // ação para filtros
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}

#Preview {
    ExpensesView()
        .environmentObject(ExpensesViewModel())
}

