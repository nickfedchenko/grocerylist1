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
    
    var currentday: Date {
        return Calendar.current.date(byAdding: .day, value: 0, to: self) ?? self
    }
    
    var nextDay: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self) ?? self
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self) ?? self
    }
    
    var nextWeek: Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: self) ?? self
    }
    
    var previousWeek: Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: -1, to: self) ?? self
    }
    
    var previousMonth: Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self) ?? self
    }
    
    var dayNumberOfWeek: Int {
        (Calendar.current.component(.weekday, from: self) - Calendar.current.firstWeekday + 7) % 7 + 1
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var week: Int {
        return Calendar.current.component(.weekOfYear, from: self)
    }
    
    var startOfWeek: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear],
                                                                           from: self)) ?? self
    }
    var endOfWeek: Date {
        return Calendar.current.date(byAdding: DateComponents(day: -1, weekOfYear: 1), to: self.startOfWeek) ?? self
    }
    
    func todayWithSetting(hour: Int, min: Int = 0) -> Date {
        let today = self.getDate(with: [.day, .month, .year]) ?? Date()
        return Calendar.current.date(bySettingHour: hour, minute: min, second: 0, of: today) ?? Date()
    }
    
    func days(sinceDate: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: sinceDate, to: self).day ?? 0
    }
    
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    
    func getListDatesOfWeek(date: Date) -> [Date] {
        var weekDates: [Date] = []
        var startDay = date.startOfWeek.nextDay
        let endWeek = startDay.endOfWeek.nextDay
        
        while startDay <= endWeek {
            weekDates.append(startDay)
            startDay = startDay.nextDay
        }
        return weekDates
    }
    
    func getDates(by date: Date) -> [Date] {
        var dates: [Date] = []
        var startDate = self
        let endDate = date
        
        while startDate <= endDate {
            dates.append(startDate)
            startDate = startDate.nextDay
        }
        return dates
    }
    
    func after(dayCount: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: dayCount, to: self) ?? self
    }
    
    func getDateFor(days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())
    }
    
    func getStringDate(format: String) -> String {
        return DateFormatter().getString(format: format, from: self)
    }
    
    private func getDate(with calendarComponents: Set<Calendar.Component>) -> Date? {
        let components = Calendar.current.dateComponents(calendarComponents, from: self) as NSDateComponents
        components.year = Calendar.current.component(.year, from: self)
        components.month = Calendar.current.component(.month, from: self)
        components.day = Calendar.current.component(.day, from: self)
        return Calendar.current.date(from: components as DateComponents)
    }
}

extension DateFormatter {
    func getString(format: String, from date: Date) -> String {
        self.setLocalizedDateFormatFromTemplate(format)
        return self.string(from: date)
    }
}
