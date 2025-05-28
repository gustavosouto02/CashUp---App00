import SwiftUI
import SwiftData

// A struct auxiliar ExpenseSection agora usará DisplayableExpense
struct DisplayableExpenseSection: Identifiable { // Renomeado para clareza
    let id = UUID()
    let date: Date
    let expenses: [DisplayableExpense] // Agora contém DisplayableExpense
}

struct SubcategoryDetailView: View {
    let subcategoriaModel: SubcategoriaModel
    let isIncome: Bool // Para filtrar corretamente as transações
    @ObservedObject var viewModel: ExpensesViewModel // ViewModel que contém transacoesExibidas
    @Environment(\.dismiss) var dismiss
    
    // Propriedade computada para gerar as seções da lista
    var sections: [DisplayableExpenseSection] {
        // Usa a propriedade transacoesExibidas da viewModel, que já está filtrada por mês e tipo (despesa/receita)
        // e já inclui as recorrências.
        // Precisamos filtrar adicionalmente pela subcategoria específica.
        
        let relevantTransactions = viewModel.transacoesExibidas.filter { displayableExpense in
            // Verifica se é da subcategoria correta E se o tipo (isIncome) corresponde
            displayableExpense.subcategoria?.id == subcategoriaModel.id && displayableExpense.isIncome == self.isIncome
        }
        
        let groupedByDate = Dictionary(grouping: relevantTransactions) { expense in
            Calendar.current.startOfDay(for: expense.date)
        }
        
        return groupedByDate.keys.sorted(by: { $0 > $1 }).map { date in
            // Ordena as despesas dentro de cada dia pela data completa (incluindo hora, se houver)
            DisplayableExpenseSection(date: date, expenses: groupedByDate[date]!.sorted(by: { $0.date > $1.date }))
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
                                    // Usar DisplayableExpenseRow ou uma view de linha similar
                                    DisplayableExpenseRow(expense: displayableExpense)
                                    // Não precisa de swipe actions aqui se a deleção é feita na lista principal
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
