//
//  SubcategoryDetailView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 21/05/25.
//

import SwiftUI
import SwiftData

struct DisplayableExpenseSection: Identifiable {
    let id = UUID()
    let date: Date
    let expenses: [DisplayableExpense]
}

struct SubcategoryDetailView: View {
    let subcategoriaModel: SubcategoriaModel
    let isIncome: Bool
    @ObservedObject var viewModel: ExpensesViewModel
    @Environment(\.dismiss) var dismiss
    @State private var expenseToDelete: DisplayableExpense? = nil
    @State private var showRecurrenceDeleteOptions: Bool = false

    
    var sections: [DisplayableExpenseSection] {
        let filteredTransactions = viewModel.transacoesExibidas.filter { displayableExpense in
            displayableExpense.subcategoria?.id == subcategoriaModel.id && displayableExpense.isIncome == isIncome
        }
        
        let grouped = Dictionary(grouping: filteredTransactions) { expense in
            Calendar.current.startOfDay(for: expense.date)
        }

        let sortedDates = grouped.keys.sorted(by: { $0 > $1 })

        return sortedDates.map { date in
            let expenses = grouped[date]?.sorted(by: { $0.date > $1.date }) ?? []
            return DisplayableExpenseSection(date: date, expenses: expenses)
        }
    }

    
    var body: some View {
        NavigationStack {
            Group {
                if sections.isEmpty {
                    VStack {
                        Spacer()
                        Text("Nenhuma transação registrada para \(subcategoriaModel.nome) neste mês \(isIncome ? "(receita)" : "(despesa)").")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(sections) { section in
                            Section(header: Text(formatSectionDate(section.date))) {
                                ForEach(section.expenses) { displayableExpense in
                                    DisplayableExpenseRow(expense: displayableExpense)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            if displayableExpense.isRecurringInstance && displayableExpense.originalExpenseID != nil {
                                                self.expenseToDelete = displayableExpense
                                                self.showRecurrenceDeleteOptions = true
                                            } else {
                                                viewModel.removeExpense(displayableExpense, scope: .entireSeries)
                                            }
                                        } label: {
                                            Label("Excluir", systemImage: "trash")
                                        }
                                    }
                                    .confirmationDialog(
                                        "Apagar Transação Recorrente",
                                        isPresented: $showRecurrenceDeleteOptions,
                                        presenting: expenseToDelete
                                    ) { expense in
                                        Button("Apagar somente esta ocorrência") {
                                            viewModel.removeExpense(expense, scope: .thisOccurrenceOnly)
                                            self.expenseToDelete = nil
                                        }
                                        Button("Apagar esta e todas as futuras") {
                                            viewModel.removeExpense(expense, scope: .thisAndAllFutureOccurrences)
                                            self.expenseToDelete = nil
                                        }
                                        Button("Apagar toda a série", role: .destructive) {
                                            viewModel.removeExpense(expense, scope: .entireSeries)
                                            self.expenseToDelete = nil
                                        }
                                        Button("Cancelar", role: .cancel) {
                                            self.expenseToDelete = nil
                                        }
                                    } message: { expense in
                                        Text("A transação \"\(expense.expenseDescription)\" de \(formatCurrency(expense.amount)) em \(expense.date.formatted(date: .numeric, time: .omitted)) é recorrente. Como você gostaria de apagá-la?")
                                    }

                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(subcategoriaModel.nome)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
