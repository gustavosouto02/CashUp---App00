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
    @Published var selectedCategory: String = "Categoria"
    @Published var description: String = ""
    @Published var selectedDate: Date = Date()
    @Published var repeatOption: String = "Nunca"
    @Published var isRepeatDialogPresented: Bool = false // Controla a exibição do menu/modal
    @Published var repeatEndDate: Date? = nil
    @Published var selectedSubcategory: Subcategoria? = nil

    
    private var numberFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        return f
    }
    
    func formattedAmount() -> String {
        return numberFormatter.string(from: NSNumber(value: amount)) ?? "0"
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
    
    let repeatOptions: [String] = [
        "Nunca",
        "Diariamente",
        "Semanalmente",
        "A cada 10 dias",
        "Mensalmente",
        "Anualmente"
    ]

    
    func setRepeatOption(_ option: String) {
            repeatOption = option
        }
}
