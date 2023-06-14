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
    private let stocksUpdateHours = 10
    
    init() {
        let today = Date()
        if today.todayWithSetting(hour: stocksUpdateHours) <= today,
           isUpdateStockRequired() {
            checkThatItemIsOutOfStock()
            UserDefaultsManager.lastUpdateStockDate = today.todayWithSetting(hour: stocksUpdateHours)
        }
        
        defaultPantry()
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
        guard let lastRefreshDate = UserDefaultsManager.lastUpdateStockDate else {
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
        var outOfStocks = dbStock.map({ Stock(dbModel: $0) })
        
        for (index, stock) in outOfStocks.enumerated() {
            guard let autoRepeat = stock.autoRepeat else { break }
            let startDate = stock.dateOfCreation.onlyDate
            let resetDay = today.todayWithSetting(hour: stocksUpdateHours)
            switch autoRepeat.state {
            case .daily:
                outOfStocks[index].isAvailability = resetDay > today
                CoreDataManager.shared.saveStock(stock: [outOfStocks[index]],
                                                 for: stock.pantryId.uuidString)
            case .weekly:
                if startDate.dayNumberOfWeek == today.dayNumberOfWeek {
                    outOfStocks[index].isAvailability = resetDay > today
                    CoreDataManager.shared.saveStock(stock: [outOfStocks[index]],
                                                     for: stock.pantryId.uuidString)
                }
            case .monthly:
                if startDate.day == today.day {
                    outOfStocks[index].isAvailability = resetDay > today
                    CoreDataManager.shared.saveStock(stock: [outOfStocks[index]],
                                                     for: stock.pantryId.uuidString)
                }
            case .yearly:
                if startDate.month == today.month,
                   startDate.day == today.day {
                    outOfStocks[index].isAvailability = resetDay > today
                    CoreDataManager.shared.saveStock(stock: [outOfStocks[index]],
                                                     for: stock.pantryId.uuidString)
                }
            case .custom:
                if checkCustomAutoRepeat(autoRepeat: autoRepeat,
                                         today: today, startDate: startDate) {
                    outOfStocks[index].isAvailability = resetDay > today
                    CoreDataManager.shared.saveStock(stock: [outOfStocks[index]],
                                                     for: stock.pantryId.uuidString)
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
    
    private func defaultPantry() {
        if !UserDefaultsManager.isFillingDefaultPantry {
            let fridge = PantryModel(name: "Fridge", index: 0,
                                     color: 9,
                                     icon: R.image.defaults_pantry_list_Fridge()?.pngData())
            let grocery = PantryModel(name: "Grocery", index: 1,
                                      color: 5,
                                      icon: R.image.defaults_pantry_list_Grocery()?.pngData())
            let spicesHerbs = PantryModel(name: "Spices & Herbs", index: 2,
                                          color: 3,
                                          icon: R.image.defaults_pantry_list_SpicesHerbs()?.pngData())
            let beautyHealth = PantryModel(name: "Beauty & Health", index: 3,
                                           color: 7,
                                           icon: R.image.defaults_pantry_list_BeautyHealth()?.pngData())
            let household = PantryModel(name: "Household", index: 4,
                                        color: 12,
                                        icon: R.image.defaults_pantry_list_Household()?.pngData())
            let hobby = PantryModel(name: "Hobby", index: 5,
                                    color: 2,
                                    icon: R.image.defaults_pantry_list_Hobby()?.pngData())
            
            CoreDataManager.shared.savePantry(pantry: [fridge, grocery, spicesHerbs, beautyHealth, household, hobby])
            
            defaultFridgeStocks(fridgeId: fridge.id)
            defaultGroceryStocks(groceryId: grocery.id)
            defaultSpicesHerbsStocks(spicesHerbsId: spicesHerbs.id)
            defaultBeautyHealthStocks(beautyHealthId: beautyHealth.id)
            defaultHouseholdStocks(householdId: household.id)
            
            UserDefaultsManager.isFillingDefaultPantry = true
        }
    }
    
    private func defaultFridgeStocks(fridgeId: UUID) {
        let milk = Stock(index: 0, pantryId: fridgeId, name: "Milk",
                         imageData: R.image.fridge_Milk()?.pngData(),
                         quantity: 1, unitId: .bottle, isAvailability: true)
        let mayonnaise = Stock(index: 1, pantryId: fridgeId, name: "Mayonnaise",
                               imageData: R.image.fridge_Mayonnaise()?.pngData(),
                               quantity: 1, unitId: .can, isAvailability: false)
        let tomatoes = Stock(index: 2, pantryId: fridgeId, name: "Tomatoes",
                             imageData: R.image.fridge_Tomatoes()?.pngData(),
                             quantity: 10, unitId: .piece, isAvailability: true)
        let lettuce = Stock(index: 3, pantryId: fridgeId, name: "Lettuce",
                            imageData: R.image.fridge_Lettuce()?.pngData(),
                            quantity: 1, unitId: .piece, isAvailability: false)
        let creamCheese = Stock(index: 4, pantryId: fridgeId, name: "Cream cheese",
                                imageData: R.image.fridge_CreamCheese()?.pngData(),
                                isAvailability: false)
        let parmesan = Stock(index: 5, pantryId: fridgeId, name: "Parmesan",
                             imageData: R.image.fridge_Parmesan()?.pngData(),
                             quantity: 250, unitId: .gram, isAvailability: true)
        let smokedBacon = Stock(index: 6, pantryId: fridgeId, name: "Smoked bacon",
                                imageData: R.image.fridge_SmokedBacon()?.pngData(),
                                quantity: 250, unitId: .gram, isAvailability: false)
        let butterUnsalted = Stock(index: 7, pantryId: fridgeId, name: "Butter, unsalted",
                                   imageData: R.image.fridge_Butter()?.pngData(),
                                   quantity: 1, unitId: .pack, isAvailability: true)
        let chickenFillet = Stock(index: 8, pantryId: fridgeId, name: "Chicken fillet",
                                  imageData: R.image.fridge_ChickenFillet()?.pngData(),
                                  quantity: 1, unitId: .kilogram, isAvailability: true)
        let frozenVegetables = Stock(index: 9, pantryId: fridgeId, name: "Frozen vegetables",
                                     imageData: R.image.fridge_FrozenVegetables()?.pngData(),
                                     quantity: 1, unitId: .pack, isAvailability: false)
        let frozenMushrooms = Stock(index: 10, pantryId: fridgeId, name: "Frozen mushrooms",
                                    imageData: R.image.fridge_FrozenMushrooms()?.pngData(),
                                    quantity: 1, unitId: .pack, isAvailability: false)
        let frozenBroccoli = Stock(index: 11, pantryId: fridgeId, name: "Frozen broccoli",
                                   imageData: R.image.fridge_FrozenBroccoli()?.pngData(),
                                   description: "Big pack", isAvailability: false)
        CoreDataManager.shared.saveStock(stock: [milk, mayonnaise, tomatoes, lettuce,
                                                 creamCheese, parmesan, smokedBacon, butterUnsalted,
                                                 chickenFillet, frozenVegetables, frozenMushrooms, frozenBroccoli],
                                         for: fridgeId.uuidString)
    }
    
    private func defaultGroceryStocks(groceryId: UUID) {
        let oliveOil = Stock(index: 0, pantryId: groceryId, name: "Olive oil", imageData: Data(),
                             quantity: 2, unitId: .bottle, isAvailability: true)
        let cannedCorn = Stock(index: 1, pantryId: groceryId, name: "Canned corn", imageData: Data(),
                               quantity: 4, unitId: .can, isAvailability: true)
        let spaghetti = Stock(index: 2, pantryId: groceryId, name: "Spaghetti", imageData: Data(),
                              quantity: 3, unitId: .pack, isAvailability: false)
        let breakfastCereal = Stock(index: 3, pantryId: groceryId, name: "Breakfast cereal", imageData: Data(),
                                    quantity: 2, unitId: .pack, isAvailability: false)
        let longShelfLifeMilk = Stock(index: 4, pantryId: groceryId, name: "Long shelf life milk", imageData: Data(),
                                      quantity: 4, unitId: .pack, isAvailability: true)
        let groundCoffee = Stock(index: 5, pantryId: groceryId, name: "Ground coffee", imageData: Data(),
                                 quantity: 2, unitId: .pack, isAvailability: true)
        let greenTeaBags = Stock(index: 6, pantryId: groceryId, name: "Green tea bags", imageData: Data(),
                                 quantity: 2, unitId: .pack, isAvailability: true)
        let oatmeal = Stock(index: 7, pantryId: groceryId, name: "Oatmeal, medium size", imageData: Data(),
                            quantity: 2, unitId: .pack, isAvailability: true)
        let honey = Stock(index: 8, pantryId: groceryId, name: "Honey", imageData: Data(),
                          isAvailability: false)
        let tunaChunks = Stock(index: 9, pantryId: groceryId, name: "Tuna chunks", imageData: Data(),
                               quantity: 3, unitId: .can, isAvailability: true)
        let eggs = Stock(index: 10, pantryId: groceryId, name: "Eggs", imageData: Data(),
                         quantity: 20, unitId: .piece, isAvailability: true)
        let wheatFlour = Stock(index: 11, pantryId: groceryId, name: "Wheat flour", imageData: Data(),
                               quantity: 2, unitId: .kilogram, isAvailability: true)
        CoreDataManager.shared.saveStock(stock: [oliveOil, cannedCorn, spaghetti, breakfastCereal,
                                                 longShelfLifeMilk, groundCoffee, greenTeaBags, oatmeal,
                                                 honey, tunaChunks, eggs, wheatFlour],
                                         for: groceryId.uuidString)
    }
    
    private func defaultSpicesHerbsStocks(spicesHerbsId: UUID) {
        let salt = Stock(index: 0, pantryId: spicesHerbsId, name: "Sea salt", imageData: Data(),
                         isAvailability: true)
        let pepper = Stock(index: 1, pantryId: spicesHerbsId, name: "Ground black pepper", imageData: Data(),
                           isAvailability: true)
        let garlic = Stock(index: 2, pantryId: spicesHerbsId, name: "Garlic powder", imageData: Data(),
                           isAvailability: true)
        let chili = Stock(index: 3, pantryId: spicesHerbsId, name: "Red chili flakes", imageData: Data(),
                          isAvailability: true)
        let paprika = Stock(index: 4, pantryId: spicesHerbsId, name: "Paprika", imageData: Data(),
                            isAvailability: true)
        let cinnamon = Stock(index: 5, pantryId: spicesHerbsId, name: "Cinnamon", imageData: Data(),
                             isAvailability: true)
        CoreDataManager.shared.saveStock(stock: [salt, pepper, garlic,
                                                 chili, paprika, cinnamon],
                                         for: spicesHerbsId.uuidString)
    }
    
    private func defaultBeautyHealthStocks(beautyHealthId: UUID) {
        let toiletPaper = Stock(index: 0, pantryId: beautyHealthId, name: "Toilet paper", imageData: Data(),
                                isAvailability: true)
        let cottonPads = Stock(index: 1, pantryId: beautyHealthId, name: "Cotton pads", imageData: Data(),
                               isAvailability: true)
        let cottonBuds = Stock(index: 2, pantryId: beautyHealthId, name: "Cotton buds", imageData: Data(),
                               isAvailability: true)
        let liquidSoap = Stock(index: 3, pantryId: beautyHealthId, name: "Liquid soap", imageData: Data(),
                               isAvailability: true)
        let toothpaste = Stock(index: 4, pantryId: beautyHealthId, name: "Toothpaste", imageData: Data(),
                               isAvailability: true)
        let showerGel = Stock(index: 5, pantryId: beautyHealthId, name: "Shower gel", imageData: Data(),
                              isAvailability: true)
        CoreDataManager.shared.saveStock(stock: [toiletPaper, cottonPads, cottonBuds,
                                                 liquidSoap, toothpaste, showerGel],
                                         for: beautyHealthId.uuidString)
    }
    
    private func defaultHouseholdStocks(householdId: UUID) {
        let sponges = Stock(index: 0, pantryId: householdId, name: "Kitchen Scrub Sponges", imageData: Data(),
                            isAvailability: true)
        let dishwashing = Stock(index: 1, pantryId: householdId, name: "Dishwashing liquid", imageData: Data(),
                                isAvailability: true)
        let paperTowels = Stock(index: 2, pantryId: householdId, name: "Paper towels", imageData: Data(),
                                isAvailability: true)
        let toiletPaper = Stock(index: 3, pantryId: householdId, name: "Toilet paper", imageData: Data(),
                                isAvailability: true)
        let trashBags = Stock(index: 4, pantryId: householdId, name: "Trash bags", imageData: Data(),
                              isAvailability: false)
        let fabricSoftener = Stock(index: 5, pantryId: householdId, name: "Fabric softener", imageData: Data(),
                                   isAvailability: true)
        let cleaningCloth = Stock(index: 6, pantryId: householdId, name: "Cleaning Cloth", imageData: Data(),
                                  isAvailability: true)
        let batteries = Stock(index: 7, pantryId: householdId, name: "AA batteries", imageData: Data(),
                              isAvailability: false)
        CoreDataManager.shared.saveStock(stock: [sponges, dishwashing, paperTowels, toiletPaper,
                                                 trashBags, fabricSoftener, cleaningCloth, batteries],
                                         for: householdId.uuidString)
    }
}
