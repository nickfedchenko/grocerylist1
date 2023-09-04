//
//  PantryDataSource.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.05.2023.
//

import Foundation

final class PantryDataSource {
    
    var reloadData: (() -> Void)?
    
    private var pantries: [PantryModel] = []
    private let stocksUpdateHours = 7
    
    init() {
        let today = Date()
        if today.todayWithSetting(hour: stocksUpdateHours) <= today,
           isUpdateStockRequired() {
            checkThatItemIsOutOfStock()
            UserDefaultsManager.shared.lastUpdateStockDate = today.todayWithSetting(hour: stocksUpdateHours)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(defaultPantry),
                                               name: .productsDownloadedAndSaved, object: nil)
        getPantriesFromDB()
    }
    
    func getPantries() -> [PantryModel] {
        pantries
    }
    
    func updatePantriesAfterMove(updatedPantries: [PantryModel]) {
        var updatedPantries = updatedPantries
        for newIndex in updatedPantries.indices {
            updatedPantries[newIndex].index = newIndex
        }
        CoreDataManager.shared.savePantry(pantry: updatedPantries)
        updatedPantries.forEach { pantry in
            CloudManager.shared.saveCloudData(pantryModel: pantry)
        }
        
        updatePantry()
    }
    
    func updatePantry() {
        getPantriesFromDB()
        reloadData?()
    }
    
    func movePantry(source: Int, destination: Int) {
        let item = pantries.remove(at: source)
        pantries.insert(item, at: destination)
    }
    
    func delete(pantry: PantryModel) {
        CoreDataManager.shared.deletePantry(by: pantry.id)
        CloudManager.shared.delete(recordType: .pantryModel, recordID: pantry.recordId)
        updatePantry()
    }
    
    private func getPantriesFromDB() {
        var isSortIndex = false
        let dbPantries = CoreDataManager.shared.getAllPantries() ?? []
        
        pantries = dbPantries.map({ PantryModel(dbModel: $0) })
        pantries.forEach {
            if $0.index > 0 {
                isSortIndex = true
            }
        }
        
        if isSortIndex {
            pantries.sort { $0.index < $1.index }
        } else {
            pantries.sort { $0.dateOfCreation > $1.dateOfCreation }
        }
    }
    
    private func isUpdateStockRequired() -> Bool {
        guard let lastRefreshDate = UserDefaultsManager.shared.lastUpdateStockDate else {
            return true
        }
        if let diff = Calendar.current.dateComponents(
            [.hour], from: lastRefreshDate, to: Date()
        ).hour {
            return diff > 24
        }
        return false
    }
    
    private func checkThatItemIsOutOfStock() {
        let today = Date()
        let dbStock = CoreDataManager.shared.getAllStock()?.filter { $0.isAutoRepeat } ?? []
        let outOfStocks = dbStock.map({ Stock(dbModel: $0) })
        
        for stock in outOfStocks {
            guard let autoRepeat = stock.autoRepeat else { break }
            let startDate = stock.dateOfCreation.onlyDate
            let resetDay = today.todayWithSetting(hour: stocksUpdateHours)
            switch autoRepeat.state {
            case .daily:
                updateStock(stock: stock, isAvailability: resetDay > today)
            case .weekly:
                if startDate.dayNumberOfWeek == today.dayNumberOfWeek {
                    updateStock(stock: stock, isAvailability: resetDay > today)
                }
            case .monthly:
                if startDate.day == today.day {
                    updateStock(stock: stock, isAvailability: resetDay > today)
                }
            case .yearly:
                if startDate.month == today.month,
                   startDate.day == today.day {
                    updateStock(stock: stock, isAvailability: resetDay > today)
                }
            case .custom:
                if checkCustomAutoRepeat(autoRepeat: autoRepeat,
                                         today: today, startDate: startDate) {
                    updateStock(stock: stock, isAvailability: resetDay > today)
                }
            }
        }
    }
    
    private func updateStock(stock: Stock, isAvailability: Bool) {
        var stock = stock
        stock.isAvailability = isAvailability
        CoreDataManager.shared.saveStock(stocks: [stock], for: stock.pantryId.uuidString)
        CloudManager.shared.saveCloudData(stock: stock)
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
    
    @objc
    private func defaultPantry() {
        if !UserDefaultsManager.shared.isFillingDefaultPantry,
            let allProducts = CoreDataManager.shared.getAllNetworkProducts(),
           allProducts.count > 1000 {
            
            var defaultsPantry: [PantryModel] = []
            
            DefaultsPantry.allCases.forEach { pantry in
                defaultsPantry.append(PantryModel(id: pantry.pantryId,
                                                  name: pantry.title, index: pantry.rawValue,
                                                  color: pantry.color, icon: pantry.imageData))
            }
            
            CoreDataManager.shared.savePantry(pantry: defaultsPantry)
            
            defaultsPantry.forEach { pantry in
                if let defaultsPantry = DefaultsPantry(rawValue: pantry.index) {
                    switch defaultsPantry {
                    case .fridge:
                        defaultFridgeStocks(fridgeId: pantry.id, allProducts: allProducts)
                    case .grocery:
                        defaultGroceryStocks(groceryId: pantry.id, allProducts: allProducts)
                    case .spicesHerbs:
                        defaultSpicesHerbsStocks(spicesHerbsId: pantry.id, allProducts: allProducts)
                    case .beautyHealth:
                        defaultBeautyHealthStocks(beautyHealthId: pantry.id, allProducts: allProducts)
                    case .household:
                        defaultHouseholdStocks(householdId: pantry.id, allProducts: allProducts)
                    case .hobby:
                        break
                    }
                }
            }
            
            UserDefaultsManager.shared.isFillingDefaultPantry = true
        }
    }
    
    private func defaultFridgeStocks(fridgeId: UUID, allProducts: [DBNewNetProduct]) {
        var defaultsFridgeStocks: [Stock] = []
        DefaultsFridgeStocks.allCases.forEach { stock in
            let netProduct = allProducts.first(where: { $0.id == stock.netProductId })
            let defaultsStock = Stock(id: UUID(number: stock.netProductId),
                                      index: stock.rawValue, pantryId: fridgeId,
                                      name: stock.title,
                                      imageData: stock.imageData,
                                      description: stock.description,
                                      category: netProduct?.marketCategory,
                                      quantity: stock.quantity,
                                      unitId: stock.unitId,
                                      isAvailability: stock.isAvailability,
                                      isDefault: true)
            defaultsFridgeStocks.append(defaultsStock)
        }
        
        CoreDataManager.shared.saveStock(stocks: defaultsFridgeStocks, for: fridgeId.uuidString)
    }
    
    private func defaultGroceryStocks(groceryId: UUID, allProducts: [DBNewNetProduct]) {
        var defaultGroceryStocks: [Stock] = []
        DefaultsGroceryStocks.allCases.forEach { stock in
            let netProduct = allProducts.first(where: { $0.id == stock.netProductId })
            let defaultsStock = Stock(id: UUID(number: stock.netProductId),
                                      index: stock.rawValue, pantryId: groceryId,
                                      name: netProduct?.title ?? stock.title,
                                      imageData: stock.imageData,
                                      description: stock.description,
                                      category: netProduct?.marketCategory,
                                      quantity: stock.quantity,
                                      unitId: stock.unitId,
                                      isAvailability: stock.isAvailability,
                                      isDefault: true)
            defaultGroceryStocks.append(defaultsStock)
        }
        
        CoreDataManager.shared.saveStock(stocks: defaultGroceryStocks, for: groceryId.uuidString)
    }
    
    private func defaultSpicesHerbsStocks(spicesHerbsId: UUID, allProducts: [DBNewNetProduct]) {
        var defaultsSpicesHerbsStocks: [Stock] = []
        DefaultsSpicesHerbsStocks.allCases.forEach { stock in
            let netProduct = allProducts.first(where: { $0.id == stock.netProductId })
            let defaultsStock = Stock(id: UUID(number: stock.netProductId),
                                      index: stock.rawValue, pantryId: spicesHerbsId,
                                      name: stock.title,
                                      imageData: stock.imageData,
                                      category: netProduct?.marketCategory,
                                      isDefault: true)
            defaultsSpicesHerbsStocks.append(defaultsStock)
        }
        
        CoreDataManager.shared.saveStock(stocks: defaultsSpicesHerbsStocks, for: spicesHerbsId.uuidString)
    }
    
    private func defaultBeautyHealthStocks(beautyHealthId: UUID, allProducts: [DBNewNetProduct]) {
        var defaultBeautyHealthStocks: [Stock] = []
        DefaultsBeautyHealthStocks.allCases.forEach { stock in
            let netProduct = allProducts.first(where: { $0.id == stock.netProductId })
            let defaultsStock = Stock(id: UUID(number: stock.netProductId),
                                      index: stock.rawValue, pantryId: beautyHealthId,
                                      name: stock.title,
                                      imageData: stock.imageData,
                                      category: netProduct?.marketCategory,
                                      isDefault: true)
            defaultBeautyHealthStocks.append(defaultsStock)
        }
        
        CoreDataManager.shared.saveStock(stocks: defaultBeautyHealthStocks, for: beautyHealthId.uuidString)
    }
    
    private func defaultHouseholdStocks(householdId: UUID, allProducts: [DBNewNetProduct]) {
        var defaultHouseholdStocks: [Stock] = []
        DefaultsHouseholdStocks.allCases.forEach { stock in
            let netProduct = allProducts.first(where: { $0.id == stock.netProductId })
            let defaultsStock = Stock(id: UUID(number: stock.netProductId),
                                      index: stock.rawValue, pantryId: householdId,
                                      name: stock.title,
                                      imageData: stock.imageData,
                                      category: netProduct?.marketCategory,
                                      isAvailability: stock.isAvailability,
                                      isDefault: true)
            defaultHouseholdStocks.append(defaultsStock)
        }
        
        CoreDataManager.shared.saveStock(stocks: defaultHouseholdStocks, for: householdId.uuidString)
    }
}

extension PantryDataSource {
    enum DefaultsPantry: Int, CaseIterable {
        case fridge
        case grocery
        case spicesHerbs
        case beautyHealth
        case household
        case hobby
    }
    
    enum DefaultsFridgeStocks: Int, CaseIterable {
        case milk, mayonnaise, tomatoes, lettuce,
             creamCheese, parmesan, smokedBacon, butterUnsalted,
             chickenFillet, frozenVegetables, frozenMushrooms, frozenBroccoli
    }
    
    enum DefaultsGroceryStocks: Int, CaseIterable {
        case oliveOil, cannedCorn, spaghetti, breakfastCereal,
             longShelfLifeMilk, groundCoffee, greenTeaBags, oatmeal,
             honey, tunaChunks, eggs, wheatFlour
    }
    
    enum DefaultsSpicesHerbsStocks: Int, CaseIterable {
        case salt, pepper, garlic,
             chili, paprika, cinnamon
    }
    
    enum DefaultsBeautyHealthStocks: Int, CaseIterable {
        case toiletPaper, cottonPads, cottonBuds,
             liquidSoap, toothpaste, showerGel
    }
    
    enum DefaultsHouseholdStocks: Int, CaseIterable {
        case sponges, dishwashing, paperTowels, toiletPaper,
             trashBags, fabricSoftener, cleaningCloth, batteries
    }
}
