//
//  MonthSelectorViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 15/05/25.
//

import Foundation

class MonthSelectorViewModel: ObservableObject {
    @Published var selectedMonth: Date = Date()

    var displayedMonth: String {
        selectedMonth.formatted(.dateTime.month(.wide).year(.defaultDigits))
    }
    
    init(selectedMonth: Date = Date()) { // Inicializador que aceita uma Date (com valor padrão)
        self.selectedMonth = selectedMonth
    }

    func navigateMonth(isNext: Bool) {
        let calendar = Calendar.current
        let components = DateComponents(month: isNext ? 1 : -1)
        selectedMonth = calendar.date(byAdding: components, to: selectedMonth) ?? selectedMonth
    }
}

