//
//  DateExtension.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 25.10.2022.
//

import Foundation

extension Date {
    var onlyDate: Date {
        return self.getDate(with: [.day, .month, .year]) ?? Date()
    }
    
    func getDateFor(days:Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())
    }
    var currentday: Date {
        return Calendar.current.date(byAdding: .day, value: 0, to: self) ?? self
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self) ?? self
    }
    
    var previousWeek: Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: 0, to: self) ?? self
    }
    
    var previousMonth: Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self) ?? self
    }
    
    func days(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.day], from: sinceDate, to: self).day
    }
    
    private func getDate(with calendarComponents: Set<Calendar.Component>) -> Date? {
        let components = Calendar.current.dateComponents(calendarComponents, from: self) as NSDateComponents
        components.year = Calendar.current.component(.year, from: self)
        components.month = Calendar.current.component(.month, from: self)
        components.day = Calendar.current.component(.day, from: self)
        return Calendar.current.date(from: components as DateComponents)
    }
}
