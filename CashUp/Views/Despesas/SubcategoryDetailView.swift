//
//  SubcategoryDetailView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 21/05/25.
//

import SwiftUI

// Struct auxiliar para representar cada seção da lista
struct ExpenseSection: Identifiable {
    let id = UUID() // Para conformar a Identifiable
    let date: Date
    let expenses: [Expense]
}

struct SubcategoryDetailView: View {
    let subcategoria: Subcategoria
    let categoryColor: Color // Adicionado para passar a cor da categoria
    @ObservedObject var viewModel: ExpensesViewModel
    @Environment(\.dismiss) var dismiss
    
    // Propriedade computada para gerar as seções da lista
    var sections: [ExpenseSection] {
        let filteredExpenses = viewModel.expensesDoMes.filter {
            $0.subcategory.id == subcategoria.id
        }
        
        let groupedByDate = Dictionary(grouping: filteredExpenses) { expense in
            Calendar.current.startOfDay(for: expense.date)
        }
        
        // Mapeia para ExpenseSection e ordena as datas (mais recentes primeiro),
        // e as despesas dentro de cada seção também são ordenadas por data (mais recentes primeiro).
        return groupedByDate.keys.sorted(by: { $0 > $1 }).map { date in
            ExpenseSection(date: date, expenses: groupedByDate[date]!.sorted(by: { $0.date > $1.date }))
        }
    }
    
    var body: some View {
        NavigationStack {
            // O conteúdo principal da NavigationStack
            Group { // Usamos Group para encapsular o condicional e aplicar modificadores a ele.
                if sections.isEmpty {
                    VStack {
                        Spacer()
                        Text("Nenhuma transação registrada para esta subcategoria neste mês.")
                            .foregroundStyle(.secondary)
                            .padding()
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(sections) { section in
                            Section(header: Text(formatSectionDate(section.date))) {
                                ForEach(section.expenses) { expense in
                                    // Linha de despesa
                                    HStack {
                                        // Ícone da subcategoria
                                        Image(systemName: subcategoria.icon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                            // Usa a cor da categoria da despesa
                                            .foregroundStyle(expense.category.color)
                                        
                                        VStack(alignment: .leading) {
                                            // Mantendo a lógica original do VStack da descrição
                                            if expense.description.isEmpty {
                                                Text(subcategoria.nome)
                                                    .font(.headline)
                                            } else {
                                                Text(subcategoria.nome)
                                                    .font(.headline)
                                                Text(expense.description)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Text(formatCurrency(expense.amount))
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(expense.isIncome ? .green : .red)
                                    }
                                    .padding(.vertical, 8)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.removeExpense(expense)
                                        } label: {
                                            Label("Excluir", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(subcategoria.nome)
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

