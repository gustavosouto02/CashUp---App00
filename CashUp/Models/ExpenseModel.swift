//
//  ExpenseModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 26/05/25.
//

// Arquivo: Models/ExpenseModel.swift
// (Baseado em Expense de CashUp/Views/Despesas/Expense.swift)

import SwiftData
import SwiftUI

@Model
final class ExpenseModel {
    var id: UUID
    var amount: Double
    var date: Date
    var expenseDescription: String
    var isIncome: Bool
    var repetition: RepetitionData? 

    // Relacionamentos
    var categoria: CategoriaModel?
    var subcategoria: SubcategoriaModel?

    init(id: UUID = UUID(),
         amount: Double = 0.0,
         date: Date = Date(),
         expenseDescription: String = "",
         isIncome: Bool = false,
         repetition: RepetitionData? = nil,
         categoria: CategoriaModel? = nil,
         subcategoria: SubcategoriaModel? = nil) {
        self.id = id
        self.amount = amount
        self.date = date
        self.expenseDescription = expenseDescription
        self.isIncome = isIncome
        self.repetition = repetition
        self.categoria = categoria
        self.subcategoria = subcategoria
    }
}
