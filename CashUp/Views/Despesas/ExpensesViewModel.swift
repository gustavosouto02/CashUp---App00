//
//  ExpensesViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 09/05/25.
//  Despesas e renda

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
    
    func addExpense(_ expense: Expense) {
        expensesDoMes.append(expense)
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
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            self.expensesDoMes = decoded
        } else {
            self.expensesDoMes = []
        }
    }
    
}
