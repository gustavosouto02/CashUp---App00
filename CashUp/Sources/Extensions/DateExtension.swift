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
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        let start = self.startOfDay()
        return Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? self
    }
}
