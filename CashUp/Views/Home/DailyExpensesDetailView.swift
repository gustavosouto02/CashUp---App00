//
//  DailyExpensesDetailView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 29/05/25.
//

// DailyExpensesDetailView.swift
import SwiftUI

struct DailyExpensesDetailView: View {
    let selectedDate: Date
    @ObservedObject var expensesViewModel: ExpensesViewModel // Para buscar as despesas do dia
    @Environment(\.dismiss) var dismiss

    // Filtra as transações para o dia selecionado
    private var expensesForSelectedDay: [DisplayableExpense] {
        expensesViewModel.transacoesExibidas.filter { expense in
            !expense.isIncome && Calendar.current.isDate(expense.date, inSameDayAs: selectedDate)
        }
    }
    
    // Versão mais robusta usando a viewModel para buscar todas as transações do dia
    private var robustExpensesForSelectedDay: [DisplayableExpense] {
        let allMonthTransactions = expensesViewModel.allTransactionsForCurrentMonth() // Pega todas, incluindo recorrências
        return allMonthTransactions.filter { expense in
            !expense.isIncome && Calendar.current.isDate(expense.date, inSameDayAs: selectedDate)
        }.sorted(by: { $0.amount > $1.amount }) // Ordena por valor, por exemplo
    }


    var body: some View {
        NavigationStack {
            VStack {
                if robustExpensesForSelectedDay.isEmpty {
                    Text("Nenhuma despesa registrada para este dia.")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(robustExpensesForSelectedDay) { expense in
                            // Use sua DisplayableExpenseRow ou uma row customizada aqui
                            DisplayableExpenseRow(expense: expense)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Gastos de \(selectedDate, style: .date)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { // Ou .navigationBarTrailing
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
