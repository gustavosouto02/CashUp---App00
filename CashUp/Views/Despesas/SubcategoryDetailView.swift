//
//  SubcategoryDetailView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 21/05/25.
//

// Arquivo: CashUp/Views/Despesas/SubcategoryDetailView.swift
// Refatorado para SwiftData

import SwiftUI
import SwiftData

// A struct auxiliar ExpenseSection agora usará ExpenseModel
struct ExpenseSectionSwiftData: Identifiable {
    let id = UUID()
    let date: Date
    let expenses: [ExpenseModel] // Agora contém ExpenseModel
}

struct SubcategoryDetailView: View {
    let subcategoriaModel: SubcategoriaModel // Agora recebe SubcategoriaModel
    let isIncome: Bool
    @ObservedObject var viewModel: ExpensesViewModel // ViewModel refatorado
    @Environment(\.dismiss) var dismiss
    
    // Propriedade computada para gerar as seções da lista
    var sections: [ExpenseSectionSwiftData] {
        // Filtra as transações do ViewModel para a subcategoria e tipo (renda/despesa) corretos
        let allTransactionsForMonth = viewModel.transactionsForCurrentMonth() // Busca todas as transações do mês
        
        let filteredExpenses = allTransactionsForMonth.filter { expenseModel in
            (expenseModel.subcategoria?.id == subcategoriaModel.id) && (expenseModel.isIncome == isIncome)
        }
        
        let groupedByDate = Dictionary(grouping: filteredExpenses) { expense in
            Calendar.current.startOfDay(for: expense.date)
        }
        
        return groupedByDate.keys.sorted(by: { $0 > $1 }).map { date in
            ExpenseSectionSwiftData(date: date, expenses: groupedByDate[date]!.sorted(by: { $0.date > $1.date }))
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if sections.isEmpty {
                    VStack {
                        Spacer()
                        Text("Nenhuma transação registrada para \(subcategoriaModel.nome) neste mês.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(sections) { section in
                            Section(header: Text(formatSectionDate(section.date))) { // Sua func utilitária
                                ForEach(section.expenses) { expenseModel in // Agora é ExpenseModel
                                    // Linha de despesa
                                    HStack {
                                        // Ícone da subcategoria (e cor da categoria pai)
                                        if let catModel = expenseModel.categoria { // Acessa a categoria do ExpenseModel
                                            CategoriasViewIcon(systemName: subcategoriaModel.icon, cor: catModel.color, size: 24) //
                                        } else {
                                            Image(systemName: "questionmark.circle.fill") // Fallback
                                                .resizable().scaledToFit().frame(width: 24 * 1.4, height: 24 * 1.4)
                                                .foregroundStyle(Color.gray)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            if expenseModel.expenseDescription.isEmpty { // Usa expenseDescription
                                                Text(subcategoriaModel.nome) // Nome da subcategoria principal
                                                    .font(.headline)
                                            } else {
                                                Text(subcategoriaModel.nome)
                                                    .font(.headline)
                                                Text(expenseModel.expenseDescription) // Descrição da transação
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Text(formatCurrency(expenseModel.amount)) // Sua func utilitária
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(expenseModel.isIncome ? .green : (expenseModel.amount > 0 ? .red : .primary) ) // Ajusta cor para despesa
                                    }
                                    .padding(.vertical, 8)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.removeExpense(expenseModel)
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
