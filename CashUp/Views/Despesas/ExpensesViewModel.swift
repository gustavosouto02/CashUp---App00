//
//  ExpensesViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 09/05/25.
//  Despesas e renda


import Foundation
import SwiftUI

class ExpensesViewModel: ObservableObject {
    
    // MARK: - Propriedades Publicadas
    
    @Published var currentMonth: Date = Date() {
        didSet {
            currentMesAno = formatador.string(from: currentMonth)
            carregarExpensesDoMes()
        }
    }
    
    @Published var expensesDoMes: [Expense] = [] {
        didSet {
            salvarExpensesDoMes()
        }
    }
    
    @Published var availableCategories: [Categoria] = CategoriasData.todas

    // MARK: - Propriedades Privadas
    
    private var currentMesAno: String
    private let formatador: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM"
        return df
    }()
    
    // MARK: - Inicializador
    
    init() {
        let now = Date()
        self.currentMonth = now
        self.currentMesAno = formatador.string(from: now)
        carregarExpensesDoMes()
    }
    
    // MARK: - Métodos Públicos
    
    // Modify addExpense to ensure category and subcategory instances are from availableCategories
    func addExpense(_ expense: Expense) {
        // 1. Tenta encontrar a CATEGORIA correspondente nas categorias disponíveis (availableCategories)
        // usando o ID da categoria da despesa.
        guard let existingCategory = availableCategories.first(where: { $0.id == expense.category.id }) else {
            print("Erro: Categoria '\(expense.category.nome)' (ID: \(expense.category.id)) não encontrada em availableCategories. Transação não adicionada.")
            return // Se a categoria não for encontrada, não adicionamos a despesa para evitar inconsistências.
        }

        // 2. Tenta encontrar a SUBCATEGORIA correspondente dentro da categoria existente
        // (que acabamos de encontrar) usando o ID da subcategoria da despesa.
        guard let existingSubcategory = existingCategory.subcategorias.first(where: { $0.id == expense.subcategory.id }) else {
            print("Erro: Subcategoria '\(expense.subcategory.nome)' (ID: \(expense.subcategory.id)) não encontrada na categoria '\(existingCategory.nome)'. Transação não adicionada.")
            return // Se a subcategoria não for encontrada, não adicionamos a despesa.
        }

        // 3. Cria uma NOVA instância de Expense, mas agora usando as INSTÂNCIAS GERENCIADAS
        // de Categoria e Subcategoria que foram encontradas.
        let newExpense = Expense(
            id: expense.id,
            amount: expense.amount,
            date: expense.date,
            category: existingCategory,       // <-- Usa a instância existente/gerenciada
            subcategory: existingSubcategory, // <-- Usa a instância existente/gerenciada
            description: expense.description,
            isIncome: expense.isIncome,
            repetition: expense.repetition
        )

        expensesDoMes.append(newExpense)
    }
    
    func removeExpense(_ expense: Expense) {
        expensesDoMes.removeAll { $0.id == expense.id }
    }
    
    func totalIncome() -> Double {
        expensesDoMes
            .filter { $0.isIncome }
            .map { $0.amount }
            .reduce(0, +)
    }
    
    func totalExpense() -> Double {
        expensesDoMes
            .filter { !$0.isIncome }
            .map { $0.amount }
            .reduce(0, +)
    }
    
    func navigateMonth(isNext: Bool) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: isNext ? 1 : -1, to: currentMonth) {
            currentMonth = newDate
        }
    }

    // MARK: - Persistência por Mês
    
    private func salvarExpensesDoMes() {
        let key = "expenses-\(currentMesAno)"
        if let data = try? JSONEncoder().encode(expensesDoMes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func carregarExpensesDoMes() {
        let key = "expenses-\(currentMesAno)"
        if let data = UserDefaults.standard.data(forKey: key),
           let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: data) {

            // 1. Processa as despesas decodificadas. Usamos `compactMap` para ignorar despesas
            // que não correspondem a uma categoria/subcategoria existente em `availableCategories`.
            self.expensesDoMes = decodedExpenses.compactMap { loadedExpense in
                // 1.1. Tenta encontrar a instância REAL da categoria em `availableCategories`
                guard let categoryToUse = availableCategories.first(where: { $0.id == loadedExpense.category.id }) else {
                    print("Aviso: Categoria '\(loadedExpense.category.nome)' (ID: \(loadedExpense.category.id)) de despesa carregada não encontrada nas categorias disponíveis. Despesa será ignorada.")
                    return nil // Retorna nil para `compactMap` para remover esta despesa
                }

                // 1.2. Tenta encontrar a instância REAL da subcategoria dentro da categoria encontrada
                guard let subcategoryToUse = categoryToUse.subcategorias.first(where: { $0.id == loadedExpense.subcategory.id }) else {
                    print("Aviso: Subcategoria '\(loadedExpense.subcategory.nome)' (ID: \(loadedExpense.subcategory.id)) de despesa carregada não encontrada na categoria '\(categoryToUse.nome)'. Despesa será ignorada.")
                    return nil // Retorna nil para `compactMap` para remover esta despesa
                }

                // 1.3. Se ambas forem encontradas, retorna uma nova Expense usando as instâncias gerenciadas
                return Expense(
                    id: loadedExpense.id,
                    amount: loadedExpense.amount,
                    date: loadedExpense.date,
                    category: categoryToUse,       // <-- Usa a instância existente/gerenciada
                    subcategory: subcategoryToUse, // <-- Usa a instância existente/gerenciada
                    description: loadedExpense.description,
                    isIncome: loadedExpense.isIncome,
                    repetition: loadedExpense.repetition
                )
            }
        } else {
            self.expensesDoMes = [] // Se não houver dados ou houver erro, inicializa com array vazio
        }
    }
}
