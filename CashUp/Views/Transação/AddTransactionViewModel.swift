//
//  AddTransactionViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 09/05/25.
// Lógica ao adicionar gasto/renda

import Foundation

class AddTransactionViewModel: ObservableObject {
    @Published var selectedTransactionType: Int = 0 // 0: Despesa, 1: Receita
    @Published var amount: Double = 0.0
    @Published var description: String = ""
    @Published var selectedDate: Date = Date()
    @Published var repeatOption: RepeatOption = .nunca
    @Published var repeatEndDate: Date? = nil
    @Published var isRepeatDialogPresented: Bool = false // Controla a exibição do menu/modal

    // MARK: - Closure para notificar a criação da transação
    // Este closure será configurado pela View e chamará o método no ExpensesViewModel.
    var onTransactionCreated: ((Expense, Categoria, Subcategoria) -> Void)?

    // MARK: - Currency Formatter otimizado com lazy var
    private lazy var currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale.current // Usa a localização atual do usuário
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        return f
    }()

    func formattedAmount() -> String {
        currencyFormatter.string(from: NSNumber(value: amount)) ?? "0"
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDateStart = calendar.startOfDay(for: date)

        if selectedDateStart == today {
            return "Hoje"
        } else if selectedDateStart == calendar.date(byAdding: .day, value: -1, to: today) {
            return "Ontem"
        } else {
            return formatter.string(from: date)
        }
    }

    var repeatOptions: [RepeatOption] {
        RepeatOption.allCases
    }

    func setRepeatOption(_ option: RepeatOption) {
        repeatOption = option
    }

    func criarTransacao(
        categoria: Categoria?,
        subcategoria: Subcategoria?
    ) -> Bool {
        guard let selectedCategoria = categoria,
              let selectedSubcategoria = subcategoria,
              amount > 0 else {
            return false // Validação básica
        }

        // Não mais tentando encontrar a categoria gerenciada aqui.
        // Essa validação será feita pelo ExpensesViewModel quando ele receber a transação.

        let repetition = Repetition(repeatOption: repeatOption, endDate: repeatEndDate)

        let novaTransacao = Expense(
            id: UUID(),
            amount: amount,
            date: selectedDate,
            category: selectedCategoria, // Usa a categoria selecionada diretamente
            subcategory: selectedSubcategoria, // Usa a subcategoria selecionada diretamente
            description: description,
            isIncome: selectedTransactionType == 1,
            repetition: repetition
        )

        // Chama o closure para que a View (ou quem o configurou) possa lidar com a transação
        onTransactionCreated?(novaTransacao, selectedCategoria, selectedSubcategoria)

        resetFields()
        return true
    }

    func resetFields() {
        amount = 0
        description = ""
        selectedDate = Date()
        repeatOption = .nunca
        repeatEndDate = nil
    }
}
