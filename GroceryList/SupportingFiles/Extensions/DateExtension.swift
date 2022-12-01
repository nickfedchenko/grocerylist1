//
//  DateExtension.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 25.10.2022.
//

import Foundation

extension Date {
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
}
