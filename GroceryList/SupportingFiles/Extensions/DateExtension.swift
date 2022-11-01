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
}
