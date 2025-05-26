//
//  utilsExpenses.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 21/05/25.
//

import SwiftUI

extension View {
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    func formatSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        if calendar.isDate(date, inSameDayAs: today) {
            return "Hoje"
        } else if calendar.isDate(date, inSameDayAs: yesterday) {
            return "Ontem"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "pt_BR")
            formatter.dateStyle = .long
            return formatter.string(from: date)
        }
    }
}
