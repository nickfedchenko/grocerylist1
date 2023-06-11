//
//  StockReminderDataSource.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.06.2023.
//

import Foundation

class StockReminderDataSource {
    
    var reloadData: (() -> Void)?
    
    private(set) var outOfStocks: [Stock] = []
    private let stocksUpdateHours = 10
    
    init() {
        checkThatItemIsOutOfStock()
        outOfStocks.sort { $0.name < $1.name }
    }
    
    func updateStockStatus(stock: Stock) {
        var stock = stock
        stock.isAvailability = !stock.isAvailability
        CoreDataManager.shared.saveStock(stock: [stock], for: stock.pantryId.uuidString)
        
        outOfStocks.removeAll { $0.id == stock.id }
        outOfStocks.append(stock)
        outOfStocks.sort { $0.name < $1.name }
        reloadData?()
    }

    private func checkThatItemIsOutOfStock() {
        let today = Date()
        let allStocks = CoreDataManager.shared.getAllStock() ?? []
        let reminderStock = allStocks.filter { $0.isReminder }
        let dbStock = reminderStock.filter({ !$0.isAvailability })

        var outOfStocks = dbStock.map({ Stock(dbModel: $0) })
        
        for stock in outOfStocks {
            guard let autoRepeat = stock.autoRepeat else { break }
            let startDate = stock.dateOfCreation.onlyDate
            let resetDay = today.todayWithSetting(hour: stocksUpdateHours)
            switch autoRepeat.state {
            case .daily:
                self.outOfStocks.append(stock)
            case .weekly:
                if startDate.dayNumberOfWeek == today.dayNumberOfWeek {
                    self.outOfStocks.append(stock)
                }
            case .monthly:
                if startDate.day == today.day {
                    self.outOfStocks.append(stock)
                }
            case .yearly:
                if startDate.month == today.month,
                   startDate.day == today.day {
                    self.outOfStocks.append(stock)
                }
            case .custom:
                if checkCustomAutoRepeat(autoRepeat: autoRepeat,
                                         today: today, startDate: startDate) {
                    self.outOfStocks.append(stock)
                }
            }
        }
    }
    
    private func checkCustomAutoRepeat(autoRepeat: AutoRepeatModel,
                                       today: Date, startDate: Date) -> Bool {
        guard autoRepeat.state == .custom,
              let period = autoRepeat.period else {
            return false
        }

        let times = (autoRepeat.times ?? 1) + 1
        switch period {
        case .days:
            let days = today.days(sinceDate: startDate)
            if days > 0 {
                return days % times == 0
            }
        case .weeks:
            let weekDates = Date().getListDatesOfWeek(date: startDate)
            guard let weekday = autoRepeat.weekday,
                  let startWeekDate = weekDates[safe: weekday] else {
                return false
            }
            if startWeekDate.dayNumberOfWeek == today.dayNumberOfWeek {
                let weeks = today.weeks(from: startWeekDate)
                if weeks >= 0 {
                    return weeks % times == 0
                }
            }
        case .months:
            let months = today.months(from: startDate)
            if months > 0 && months % times == 0 {
                return today.day == startDate.day
            }
        case .years:
            let years = today.years(from: startDate)
            if years > 0 && years % times == 0 {
                return today.day == startDate.day && today.month == startDate.month
            }
        }
        return false
    }
}
