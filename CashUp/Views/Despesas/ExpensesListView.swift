//
//  ExpensesListView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 19/05/25.
//

// Arquivo: CashUp/Views/Despesas/ExpensesListView.swift
// Refatorado para SwiftData

import SwiftUI
import SwiftData

struct ExpensesListView: View {
    // O ViewModel ainda é observado para obter o currentMonth e disparar atualizações.
    @ObservedObject var viewModel: ExpensesViewModel

    private var transacoesDoMes: [ExpenseModel] {
        viewModel.transactionsForCurrentMonth() // Usando a função que busca todas as transações do mês
    }

    var body: some View {
        Group {
            if transacoesDoMes.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "note.text")
                        .font(.largeTitle)
                        .foregroundStyle(.gray)
                        .padding(.bottom, 8)
                    Text("Nenhuma transação neste mês")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Text("Que tal registrar sua primeira despesa ou receita?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(groupedExpenses.keys.sorted(by: >), id: \.self) { date in
                        Section(
                            header:
                                HStack {
                                    Text(formatSectionDate(date)) // Sua func utilitária
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(formatCurrency(totalForDay(date))) // Sua func utilitária
                                        .font(.headline.bold())
                                        .foregroundStyle(totalForDay(date) >= 0 ? Color.green : Color.red)
                                }
                                .padding(.vertical, 2)
                        ) {
                            ForEach(groupedExpenses[date] ?? []) { expenseModel in // Agora é ExpenseModel
                                ExpenseRowSwiftData(expense: expenseModel) // Usa a nova View de linha
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color(.systemGray6))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) { // Adicionado swipeActions aqui
                                        Button(role: .destructive) {
                                            viewModel.removeExpense(expenseModel)
                                        } label: {
                                            Label("Excluir", systemImage: "trash")
                                        }
                                    }
                            }
                            // .onDelete não é mais necessário aqui se o swipeAction está na linha
                        }
                    }
                }
                .listStyle(.plain)
                .padding(.bottom, 8)
            }
        }
    }
    
    // MARK: Agrupamento e Cálculos
    
    var groupedExpenses: [Date: [ExpenseModel]] {
        let calendar = Calendar.current
        // Usa a propriedade computada transacoesDoMes
        return Dictionary(grouping: transacoesDoMes) {
            calendar.startOfDay(for: $0.date)
        }
    }
    
    func totalForDay(_ date: Date) -> Double {
        groupedExpenses[date]?.reduce(0) {
            $0 + ($1.isIncome ? $1.amount : -$1.amount)
        } ?? 0
    }
    
    // A função deleteExpense(at:for:) foi removida pois o swipeAction
    // chama diretamente viewModel.removeExpense(expenseModel)
}

// Nova struct para a linha, recebendo ExpenseModel
// (Esta struct foi definida na resposta anterior, mas a repito aqui para completude do arquivo)
struct ExpenseRowSwiftData: View {
    let expense: ExpenseModel // Recebe o modelo SwiftData
    
    var body: some View {
        HStack(spacing: 12) {
            // Acessa as propriedades opcionais com segurança
            if let subcategoria = expense.subcategoria, let categoria = expense.categoria {
                 CategoriasViewIcon( // Sua View de ícone
                    systemName: subcategoria.icon,
                    cor: categoria.color, // Usa a cor computada do CategoriaModel
                    size: 20
                )
            } else {
                // Placeholder ou ícone padrão se categoria/subcategoria não estiverem definidas
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20 * 1.4, height: 20 * 1.4) // Mantém o tamanho do ZStack de CategoriasViewIcon
                    .foregroundStyle(Color.gray)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.categoria?.nome ?? "Categoria Desconhecida")
                    .font(.headline)
                
                HStack(spacing: 4){
                    Text(expense.subcategoria?.nome ?? "Subcategoria Desconhecida")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !expense.expenseDescription.isEmpty { // Usa a propriedade renomeada
                        Text(": \(expense.expenseDescription)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Text(formatCurrency(expense.amount)) // Sua função utilitária
                .foregroundStyle(expense.isIncome ? .green : .primary) // Ajuste a cor
                .fontWeight(.bold)
        }
        .padding(.vertical, 6)
    }
}
