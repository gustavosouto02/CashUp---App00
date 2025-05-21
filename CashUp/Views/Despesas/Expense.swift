//
//  Planning.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 09/05/25.
//  Modelo para metas de planejamento

import Foundation

struct Expense: Identifiable, Codable, Equatable {
    let id: UUID
    let amount: Double
    let date: Date
    let category: Categoria
    let subcategory: Subcategoria
    let description: String
    let isIncome: Bool
    let repetition: Repetition?

    init(
        id: UUID = UUID(),
        amount: Double,
        date: Date,
        category: Categoria,
        subcategory: Subcategoria,
        description: String,
        isIncome: Bool,
        repetition: Repetition? = nil
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.category = category
        self.subcategory = subcategory
        self.description = description
        self.isIncome = isIncome
        self.repetition = repetition
    }
}

