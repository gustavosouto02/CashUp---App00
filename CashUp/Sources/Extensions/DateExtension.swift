//
//  DateExtension.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 12/05/25.
//

import Foundation

extension Date {
    func isoString() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
    static func fromISO(_ iso: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: iso)
    }
}

