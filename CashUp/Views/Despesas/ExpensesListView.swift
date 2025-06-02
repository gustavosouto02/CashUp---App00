//
//  ExpensesListView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 19/05/25.
//

import SwiftUI
import SwiftData

struct ExpensesListView: View {
    @ObservedObject var viewModel: ExpensesViewModel

    @State private var expenseToDelete: DisplayableExpense? = nil
    @State private var showRecurrenceDeleteOptions: Bool = false

    private var transacoesDoMesParaExibicao: [DisplayableExpense] {
        viewModel.transacoesExibidas
    }

    var body: some View {
        Group {
            if transacoesDoMesParaExibicao.isEmpty {
                VStack {
                    Spacer()
                    Text(viewModel.selectedTransactionType == 0 ? "Que tal registrar sua primeira despesa?" : "Que tal registrar sua primeira receita?")
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(groupedExpenses.keys.sorted(by: >), id: \.self) { date in
                        Section(
                            header:
                                HStack {
                                    Text(formatSectionDate(date))
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(formatCurrency(totalForDay(date)))
                                        .font(.headline.bold())
                                        .foregroundStyle(colorForTotal(totalForDay(date)))
                                }
                                .padding(.vertical, 4)
                        ) {
                            ForEach(groupedExpenses[date] ?? [], id: \.id) { displayableExpense in
                                DisplayableExpenseRow(expense: displayableExpense)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color(.systemGray6))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
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
                            }
                        }
                        .listRowSpacing(8)
                    }
                }
                .listStyle(.plain)
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
    
    var groupedExpenses: [Date: [DisplayableExpense]] {
        let calendar = Calendar.current
        return Dictionary(grouping: transacoesDoMesParaExibicao) {
            calendar.startOfDay(for: $0.date)
        }
    }
    
    func totalForDay(_ date: Date) -> Double {
        groupedExpenses[date]?.reduce(0) { $0 + $1.amount } ?? 0
    }

    func colorForTotal(_ total: Double) -> Color {
        if viewModel.selectedTransactionType == 0 {
            return total >= 0 ? .red : .green
        } else {
            return total >= 0 ? .green : .red
        }
    }
}

struct DisplayableExpenseRow: View {
    let expense: DisplayableExpense
    
    var body: some View {
        HStack(spacing: 12) {
            if let categoria = expense.categoria {
                 CategoriasViewIcon(
                    systemName: expense.subcategoria?.icon ?? categoria.icon,
                    cor: categoria.color,
                    size: 22
                )
            } else {
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20 * 1.4, height: 20 * 1.4)
                    .foregroundStyle(Color.gray)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.expenseDescription.isEmpty ? (expense.subcategoria?.nome ?? expense.categoria?.nome ?? (expense.isIncome ? "Receita" : "Despesa")) : expense.expenseDescription)
                    .font(.headline)
                    .lineLimit(1)
                
                if !expense.expenseDescription.isEmpty && (expense.subcategoria != nil || expense.categoria != nil) {
                     Text(expense.subcategoria?.nome ?? expense.categoria?.nome ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(formatCurrency(expense.amount))
                .foregroundStyle(expense.isIncome ? .green : (expense.amount > 0 ? .primary : .secondary) )
                .fontWeight(.bold)
        }
        .padding(.vertical, 6)
        
    }
}

func formatSectionDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "pt_BR")
    
    let calendar = Calendar.current
    if calendar.isDateInToday(date) {
        return "Hoje, \(dateFormatter.weekdaySymbols[calendar.component(.weekday, from: date) - 1].capitalized)"
    } else if calendar.isDateInYesterday(date) {
        return "Ontem, \(dateFormatter.weekdaySymbols[calendar.component(.weekday, from: date) - 1].capitalized)"
    } else {
        dateFormatter.dateFormat = "EEEE, dd/MM"
        return dateFormatter.string(from: date).capitalized
    }
}

func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$0,00"
}
