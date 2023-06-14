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
            let fridge = PantryModel(name: R.string.localizable.fridge(), index: 0,
                                     color: 9,
                                     icon: R.image.defaults_pantry_list_Fridge()?.pngData())
            let grocery = PantryModel(name: R.string.localizable.grocery(), index: 1,
                                      color: 5,
                                      icon: R.image.defaults_pantry_list_Grocery()?.pngData())
            let spicesHerbs = PantryModel(name: R.string.localizable.spicesHerbs(), index: 2,
                                          color: 3,
                                          icon: R.image.defaults_pantry_list_SpicesHerbs()?.pngData())
            let beautyHealth = PantryModel(name: R.string.localizable.beautyHealth(), index: 3,
                                           color: 7,
                                           icon: R.image.defaults_pantry_list_BeautyHealth()?.pngData())
            let household = PantryModel(name: R.string.localizable.household(), index: 4,
                                        color: 12,
                                        icon: R.image.defaults_pantry_list_Household()?.pngData())
            let hobby = PantryModel(name: R.string.localizable.hobby(), index: 5,
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
        let milk = Stock(index: 0, pantryId: fridgeId, name: R.string.localizable.milk(),
                         imageData: R.image.fridge_Milk()?.pngData(),
                         quantity: 1, unitId: .bottle, isAvailability: true)
        let mayonnaise = Stock(index: 1, pantryId: fridgeId, name: R.string.localizable.mayonnaise(),
                               imageData: R.image.fridge_Mayonnaise()?.pngData(),
                               quantity: 1, unitId: .can, isAvailability: false)
        let tomatoes = Stock(index: 2, pantryId: fridgeId, name: R.string.localizable.tomatoes(),
                             imageData: R.image.fridge_Tomatoes()?.pngData(),
                             quantity: 10, unitId: .piece, isAvailability: true)
        let lettuce = Stock(index: 3, pantryId: fridgeId, name: R.string.localizable.lettuce(),
                            imageData: R.image.fridge_Lettuce()?.pngData(),
                            quantity: 1, unitId: .piece, isAvailability: false)
        let creamCheese = Stock(index: 4, pantryId: fridgeId, name: R.string.localizable.creamCheese(),
                                imageData: R.image.fridge_CreamCheese()?.pngData(),
                                isAvailability: false)
        let parmesan = Stock(index: 5, pantryId: fridgeId, name: R.string.localizable.parmesan(),
                             imageData: R.image.fridge_Parmesan()?.pngData(),
                             quantity: 250, unitId: .gram, isAvailability: true)
        let smokedBacon = Stock(index: 6, pantryId: fridgeId, name: R.string.localizable.smokedBacon(),
                                imageData: R.image.fridge_SmokedBacon()?.pngData(),
                                quantity: 250, unitId: .gram, isAvailability: false)
        let butterUnsalted = Stock(index: 7, pantryId: fridgeId, name: R.string.localizable.butterUnsalted(),
                                   imageData: R.image.fridge_Butter()?.pngData(),
                                   quantity: 1, unitId: .pack, isAvailability: true)
        let chickenFillet = Stock(index: 8, pantryId: fridgeId, name: R.string.localizable.chickenFillet(),
                                  imageData: R.image.fridge_ChickenFillet()?.pngData(),
                                  quantity: 1, unitId: .kilogram, isAvailability: true)
        let frozenVegetables = Stock(index: 9, pantryId: fridgeId,
                                     name: R.string.localizable.frozenVegetables(),
                                     imageData: R.image.fridge_FrozenVegetables()?.pngData(),
                                     quantity: 1, unitId: .pack, isAvailability: false)
        let frozenMushrooms = Stock(index: 10, pantryId: fridgeId,
                                    name: R.string.localizable.frozenMushrooms(),
                                    imageData: R.image.fridge_FrozenMushrooms()?.pngData(),
                                    quantity: 1, unitId: .pack, isAvailability: false)
        let frozenBroccoli = Stock(index: 11, pantryId: fridgeId,
                                   name: R.string.localizable.frozenBroccoli(),
                                   imageData: R.image.fridge_FrozenBroccoli()?.pngData(),
                                   description: R.string.localizable.bigPack(), isAvailability: false)
        CoreDataManager.shared.saveStock(stock: [milk, mayonnaise, tomatoes, lettuce,
                                                 creamCheese, parmesan, smokedBacon, butterUnsalted,
                                                 chickenFillet, frozenVegetables, frozenMushrooms, frozenBroccoli],
                                         for: fridgeId.uuidString)
    }
    
    private func defaultGroceryStocks(groceryId: UUID) {
        let oliveOil = Stock(index: 0, pantryId: groceryId, name: R.string.localizable.oliveOil() ,
                             imageData: R.image.grocery_OliveOil()?.pngData(),
                             quantity: 2, unitId: .bottle, isAvailability: true)
        let cannedCorn = Stock(index: 1, pantryId: groceryId, name: R.string.localizable.cannedCorn(),
                               imageData: R.image.grocery_CannedCorn()?.pngData(),
                               quantity: 4, unitId: .can, isAvailability: true)
        let spaghetti = Stock(index: 2, pantryId: groceryId, name: R.string.localizable.spaghetti(),
                              imageData: R.image.grocery_Spaghetti()?.pngData(),
                              quantity: 3, unitId: .pack, isAvailability: false)
        let breakfastCereal = Stock(index: 3, pantryId: groceryId,
                                    name: R.string.localizable.breakfastCereal(),
                                    imageData: R.image.grocery_Breakfast()?.pngData(),
                                    quantity: 2, unitId: .pack, isAvailability: false)
        let longShelfLifeMilk = Stock(index: 4, pantryId: groceryId,
                                      name: R.string.localizable.longShelfLifeMilk(),
                                      imageData: R.image.grocery_Long()?.pngData(),
                                      quantity: 4, unitId: .pack, isAvailability: true)
        let groundCoffee = Stock(index: 5, pantryId: groceryId, name: R.string.localizable.groundCoffee(),
                                 imageData: R.image.grocery_Ground()?.pngData(),
                                 quantity: 2, unitId: .pack, isAvailability: true)
        let greenTeaBags = Stock(index: 6, pantryId: groceryId, name: R.string.localizable.greenTeaBags(),
                                 imageData: R.image.grocery_Green()?.pngData(),
                                 quantity: 2, unitId: .pack, isAvailability: true)
        let oatmeal = Stock(index: 7, pantryId: groceryId, name: R.string.localizable.oatmealMediumSize(),
                            imageData: R.image.grocery_Oatmeal()?.pngData(),
                            quantity: 2, unitId: .pack, isAvailability: true)
        let honey = Stock(index: 8, pantryId: groceryId, name: R.string.localizable.honey(),
                          imageData: R.image.grocery_Honey()?.pngData(),
                          isAvailability: false)
        let tunaChunks = Stock(index: 9, pantryId: groceryId, name: R.string.localizable.tunaChunks(),
                               imageData: R.image.grocery_Tuna()?.pngData(),
                               quantity: 3, unitId: .can, isAvailability: true)
        let eggs = Stock(index: 10, pantryId: groceryId, name: R.string.localizable.eggs(),
                         imageData: R.image.grocery_Eggs()?.pngData(),
                         quantity: 20, unitId: .piece, isAvailability: true)
        let wheatFlour = Stock(index: 11, pantryId: groceryId, name: R.string.localizable.wheatFlour(),
                               imageData: R.image.grocery_Wheat()?.pngData(),
                               quantity: 2, unitId: .kilogram, isAvailability: true)
        CoreDataManager.shared.saveStock(stock: [oliveOil, cannedCorn, spaghetti, breakfastCereal,
                                                 longShelfLifeMilk, groundCoffee, greenTeaBags, oatmeal,
                                                 honey, tunaChunks, eggs, wheatFlour],
                                         for: groceryId.uuidString)
    }
    
    private func defaultSpicesHerbsStocks(spicesHerbsId: UUID) {
        let salt = Stock(index: 0, pantryId: spicesHerbsId, name: R.string.localizable.seaSalt(),
                         imageData: R.image.spices_Sea()?.pngData(),
                         isAvailability: true)
        let pepper = Stock(index: 1, pantryId: spicesHerbsId, name: R.string.localizable.groundBlackPepper(),
                           imageData: R.image.spices_Ground()?.pngData(),
                           isAvailability: true)
        let garlic = Stock(index: 2, pantryId: spicesHerbsId, name: R.string.localizable.garlicPowder(),
                           imageData: R.image.spices_Garlic()?.pngData(),
                           isAvailability: true)
        let chili = Stock(index: 3, pantryId: spicesHerbsId, name: R.string.localizable.redChiliFlakes(),
                          imageData: R.image.spices_Red()?.pngData(),
                          isAvailability: true)
        let paprika = Stock(index: 4, pantryId: spicesHerbsId, name: R.string.localizable.paprika(),
                            imageData: R.image.spices_Paprika()?.pngData(),
                            isAvailability: true)
        let cinnamon = Stock(index: 5, pantryId: spicesHerbsId, name: R.string.localizable.cinnamon(),
                             imageData: R.image.spices_Cinnamon()?.pngData(),
                             isAvailability: true)
        CoreDataManager.shared.saveStock(stock: [salt, pepper, garlic,
                                                 chili, paprika, cinnamon],
                                         for: spicesHerbsId.uuidString)
    }
    
    private func defaultBeautyHealthStocks(beautyHealthId: UUID) {
        let toiletPaper = Stock(index: 0, pantryId: beautyHealthId, name: R.string.localizable.toiletPaper(),
                                imageData: R.image.beauty_Toilet()?.pngData(),
                                isAvailability: true)
        let cottonPads = Stock(index: 1, pantryId: beautyHealthId, name: R.string.localizable.cottonPads(),
                               imageData: R.image.spices_Cinnamon()?.pngData(),
                               isAvailability: true)
        let cottonBuds = Stock(index: 2, pantryId: beautyHealthId, name: R.string.localizable.cottonBuds(),
                               imageData: R.image.beauty_CottonBuds()?.pngData(),
                               isAvailability: true)
        let liquidSoap = Stock(index: 3, pantryId: beautyHealthId, name: R.string.localizable.liquidSoap(),
                               imageData: R.image.beauty_Liquid()?.pngData(),
                               isAvailability: true)
        let toothpaste = Stock(index: 4, pantryId: beautyHealthId, name: R.string.localizable.toothpaste(),
                               imageData: R.image.beauty_Toothpaste()?.pngData(),
                               isAvailability: true)
        let showerGel = Stock(index: 5, pantryId: beautyHealthId, name: R.string.localizable.showerGel(),
                              imageData: R.image.beauty_Shower()?.pngData(),
                              isAvailability: true)
        CoreDataManager.shared.saveStock(stock: [toiletPaper, cottonPads, cottonBuds,
                                                 liquidSoap, toothpaste, showerGel],
                                         for: beautyHealthId.uuidString)
    }
    
    private func defaultHouseholdStocks(householdId: UUID) {
        let sponges = Stock(index: 0, pantryId: householdId, name: R.string.localizable.kitchenScrubSponges(),
                            imageData: R.image.household_Kitchen()?.pngData(),
                            isAvailability: true)
        let dishwashing = Stock(index: 1, pantryId: householdId, name: R.string.localizable.dishwashingLiquid(),
                                imageData: R.image.household_Dishwashing()?.pngData(),
                                isAvailability: true)
        let paperTowels = Stock(index: 2, pantryId: householdId, name: R.string.localizable.paperTowels(),
                                imageData: R.image.household_Paper()?.pngData(),
                                isAvailability: true)
        let toiletPaper = Stock(index: 3, pantryId: householdId, name: R.string.localizable.toiletPaper(),
                                imageData: R.image.household_Toilet()?.pngData(),
                                isAvailability: true)
        let trashBags = Stock(index: 4, pantryId: householdId, name: R.string.localizable.trashBags(),
                              imageData: R.image.household_Trash()?.pngData(),
                              isAvailability: false)
        let fabricSoftener = Stock(index: 5, pantryId: householdId, name: R.string.localizable.fabricSoftener(),
                                   imageData: R.image.household_Fabric()?.pngData(),
                                   isAvailability: true)
        let cleaningCloth = Stock(index: 6, pantryId: householdId, name: R.string.localizable.cleaningCloth(),
                                  imageData: R.image.household_Cleaning()?.pngData(),
                                  isAvailability: true)
        let batteries = Stock(index: 7, pantryId: householdId, name: R.string.localizable.aaBatteries(),
                              imageData: R.image.household_AA()?.pngData(),
                              isAvailability: false)
        CoreDataManager.shared.saveStock(stock: [sponges, dishwashing, paperTowels, toiletPaper,
                                                 trashBags, fabricSoftener, cleaningCloth, batteries],
                                         for: householdId.uuidString)
    }
}
