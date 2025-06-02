//
//  RepetitionData.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 26/05/25.
//

import Foundation

struct RepetitionData: Codable, Equatable {
    var repeatOption: RepeatOption
    var endDate: Date?
    var excludedDates: [Date]?

    init(repeatOption: RepeatOption, endDate: Date?, excludedDates: [Date]? = nil) {
        self.repeatOption = repeatOption
        self.endDate = endDate
        self.excludedDates = excludedDates
    }
}
