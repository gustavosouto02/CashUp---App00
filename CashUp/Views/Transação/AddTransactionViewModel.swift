//
//  AddTransactionViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 09/05/25.
// Lógica ao adicionar gasto/renda

import Foundation
import SwiftUI

class AddTransactionViewModel: ObservableObject {
    @Published var selectedTransactionType: Int = 0 // 0: Despesa, 1: Receita
    @Published var amount: Double = 0.0
    @Published var description: String = ""
    @Published var selectedDate: Date = Date()
    @Published var repeatOption: RepeatOption = .nunca
    @Published var repeatEndDate: Date? = nil
    @Published var isRepeatDialogPresented: Bool = false // Controla a exibição do menu/modal
    
    
    private var currencyFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale.current
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        return f
    }
    
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
        subcategoria: Subcategoria?,
        expensesViewModel: ExpensesViewModel // <--- Esta instância PRECISA ser a do ambiente
    ) -> Bool {
        guard let selectedCategoria = categoria,
              let selectedSubcategoria = subcategoria,
              amount > 0 else {
            return false // Validação básica
        }

        // Tenta encontrar a categoria gerenciada pelo ExpensesViewModel.
        // Isso é uma camada de segurança. O ideal é que `selectedCategory` já seja a instância correta
        // vinda do CategorySelectionSheet.
        guard let managedCategory = expensesViewModel.availableCategories.first(where: { $0.id == selectedCategoria.id }) else {
            print("Erro: Categoria selecionada não encontrada nas categorias disponíveis do ViewModel. Transação não criada.")
            return false
        }

        // Tenta encontrar a subcategoria gerenciada dentro da categoria gerenciada.
        guard let managedSubcategory = managedCategory.subcategorias.first(where: { $0.id == selectedSubcategoria.id }) else {
            print("Erro: Subcategoria selecionada não encontrada na categoria gerenciada. Transação não criada.")
            return false
        }

        let repetition = Repetition(repeatOption: repeatOption, endDate: repeatEndDate)

        let novaTransacao = Expense(
            id: UUID(),
            amount: amount,
            date: selectedDate,
            category: managedCategory,       // <-- Usa a instância gerenciada
            subcategory: managedSubcategory, // <-- Usa a instância gerenciada
            description: description,
            isIncome: selectedTransactionType == 1,
            repetition: repetition
        )

        expensesViewModel.addExpense(novaTransacao) // Chama addExpense na instância compartilhada

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
