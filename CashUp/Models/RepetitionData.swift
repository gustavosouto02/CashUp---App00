//
//  RepetitionData.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 26/05/25.
//

// Arquivo: Models/RepetitionData.swift
// (Baseado em Repetition de CashUp/Views/Transação/Componentes/RepeatOptionPicker.swift)

import Foundation

// RepeatOption já é Codable no seu código original em RepeatOptionPicker.swift
// Certifique-se de que ele permaneça acessível (pode ser movido para este arquivo ou um arquivo global de Enums/Structs)
// enum RepeatOption: String, CaseIterable, Identifiable, Codable { ... }

struct RepetitionData: Codable, Equatable {
    let repeatOption: RepeatOption
    let endDate: Date?
}
