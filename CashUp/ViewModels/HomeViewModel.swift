//
//  HomeViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 09/05/25.
//  Dados da visão geral

import Foundation
import SwiftUI

class MonthSelectorViewModel: ObservableObject {
    @AppStorage("selectedDate") private var selectedDateString: String = Date().isoString()

    @Published var selectedDate: Date
    @Published var selectedTab: Int = 0

    private let calendar = Calendar.current

    private let formatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "pt_BR")
        df.dateFormat = "LLLL yyyy" // Ex: "maio 2025"
        return df
    }()

    var selectedMonth: String {
        formatter.string(from: selectedDate).capitalized // Ex: "Maio 2025"
    }

    init() {
        // Inicializa selectedDate com a data atual
        self.selectedDate = Date()

        // Tenta carregar a data salva
        if let savedDate = Date.fromISO(selectedDateString) {
            self.selectedDate = savedDate
            print("Loaded saved date: \(savedDate)")
        } else {
            // Se não houver data salva, usa a data atual
            selectedDateString = selectedDate.isoString() // Atualiza o valor armazenado
            print("Using current date: \(self.selectedDate)")
        }
    }

    func navigateMonth(isNext: Bool) {
        if let newDate = calendar.date(byAdding: .month, value: isNext ? 1 : -1, to: selectedDate) {
            selectedDate = newDate
            selectedDateString = newDate.isoString() // Atualiza o valor armazenado no @AppStorage
            print("Navigated to new date: \(newDate)")
        }
    }
}



