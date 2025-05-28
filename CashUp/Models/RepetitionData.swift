//
//  RepetitionData.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 26/05/25.
//

// Arquivo: Models/RepetitionData.swift

import Foundation

struct RepetitionData: Codable, Equatable {
    var repeatOption: RepeatOption
    var endDate: Date?
    var excludedDates: [Date]? // NOVA PROPRIEDADE: Datas das ocorrências que foram "deletadas"

    // Atualize o init se você tiver um customizado, ou deixe o padrão.
    // Se deixar o padrão, excludedDates será nil inicialmente.
    // Se você tiver um init customizado:
    init(repeatOption: RepeatOption, endDate: Date?, excludedDates: [Date]? = nil) {
        self.repeatOption = repeatOption
        self.endDate = endDate
        self.excludedDates = excludedDates
    }
}
