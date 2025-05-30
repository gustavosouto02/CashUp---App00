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
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR") // Garante Português (Brasil)
        // Define o formato para "MMMM yyyy" (ex: "Junho 2025")
        // "MMMM" dá o nome completo do mês.
        dateFormatter.dateFormat = "MMMM yyyy"
        
        // Converte a data para string e capitaliza a primeira letra (embora para pt_BR "MMMM" já deva fazer isso)
        let formattedString = dateFormatter.string(from: selectedMonth)
        return formattedString.prefix(1).uppercased() + formattedString.dropFirst()
    }
    
    init(selectedMonth: Date = Date()) {
        // Garante que o selectedMonth inicial seja sempre o início do mês para consistência
        self.selectedMonth = selectedMonth.startOfMonth()
    }

    func navigateMonth(isNext: Bool) {
        let calendar = Calendar.current // Use Calendar.current para respeitar as configurações do usuário
        // Ou Calendar(identifier: .gregorian) se você sempre quiser o Gregoriano
        
        if let newMonthBase = calendar.date(byAdding: .month, value: isNext ? 1 : -1, to: selectedMonth) {
            selectedMonth = newMonthBase.startOfMonth() // Mantém a data como início do mês
        }
    }
}

