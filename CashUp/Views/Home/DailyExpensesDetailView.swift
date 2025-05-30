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
    @ObservedObject var expensesViewModel: ExpensesViewModel
    @Environment(\.dismiss) var dismiss

    private var expensesForThisDay: [DisplayableExpense] {
        // Chama a nova função na ViewModel para buscar despesas (isIncome: false) para a data específica.
        // A ordenação pode ser feita aqui ou na ViewModel.
        return expensesViewModel.fetchTransactions(forSpecificDate: selectedDate, isIncome: false)
            .sorted(by: { $0.amount > $1.amount }) // Exemplo de ordenação
    }

    var body: some View {
        NavigationStack {
            VStack {
                if expensesForThisDay.isEmpty { // Usa a nova propriedade
                    Text("Nenhuma despesa registrada para este dia.")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(expensesForThisDay) { expense in // Usa a nova propriedade
                            DisplayableExpenseRow(expense: expense)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Gastos de \(selectedDate, style: .date)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
