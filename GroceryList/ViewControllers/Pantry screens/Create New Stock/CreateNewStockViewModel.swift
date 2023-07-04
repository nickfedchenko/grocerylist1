//
//  CreateNewStockViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.06.2023.
//

import UIKit

class CreateNewStockViewModel: CreateNewProductViewModel {
    
    var updateUI: ((Stock) -> Void)?
    var currentStock: Stock?
    private var pantry: PantryModel
    
    init(pantry: PantryModel) {
        self.pantry = pantry
        super.init()
    }
    
    override var productName: String? {
        currentStock?.name
    }
    
    override var productImage: UIImage? {
        guard let data = currentStock?.imageData else {
            return nil
        }
        return UIImage(data: data)
    }
    
    override var productDescription: String? {
        currentStock?.description
    }
    
    override var userComment: String? {
        guard let quantity = getProductDescriptionQuantity() else {
            return productDescription
        }
        var userComment = productDescription?.replacingOccurrences(of: quantity, with: "")
        
        if userComment?.last == "," {
            userComment?.removeLast()
        }
        
        if userComment?.first == "," {
            userComment?.removeFirst()
        }
        
        return userComment?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    override var productQuantityCount: Double? {
        guard let quantity = currentStock?.quantity else {
            guard let stringArray = getProductDescriptionQuantity()?.components(separatedBy: .decimalDigits.inverted)
                                                                    .filter({ !$0.isEmpty }),
                  let lastCount = stringArray.first else {
                return nil
            }
            return Double(lastCount)
        }
        
        return quantity < 0 ? nil : quantity
    }
    
    override var productQuantityUnit: UnitSystem? {
        guard let unitId = currentStock?.unitId else {
            guard let descriptionQuantity = getProductDescriptionQuantity() else {
                return nil
            }
            
            for unit in selectedUnitSystemArray where descriptionQuantity.contains(unit.title) {
                currentSelectedUnit = unit
            }
            
            return currentSelectedUnit
        }
        
        currentSelectedUnit = unitId

        return currentSelectedUnit
    }
    
    override var isVisibleImage: Bool {
        guard let model else {
            return UserDefaultsManager.isShowImage
        }
        return model.isShowImage.getBool(defaultValue: UserDefaultsManager.isShowImage)
    }
    
    override var isVisibleStore: Bool {
        return pantry.isVisibleCost
    }
    
    override var productStore: Store? {
        currentStock?.store
    }
    
    override var productCost: String? {
        guard var cost = currentStock?.cost else {
            return nil
        }
        cost = cost < 0 ? 0 : cost
        return String(format: "%.\(cost.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", cost)
    }
    
    override var getColorForBackground: UIColor {
        colorManager.getGradient(index: pantry.color).light
    }
    
    override var getColorForForeground: UIColor {
        colorManager.getGradient(index: pantry.color).medium
    }
    
    var isAvailability: Bool {
        currentStock?.isAvailability ?? true
    }
    
    var isAutoRepeat: Bool {
        currentStock?.isAutoRepeat ?? false
    }
    
    var autoRepeatTitle: String? {
        guard let autoRepeatModel = currentStock?.autoRepeat,
              isAutoRepeat else {
            return R.string.localizable.autoRepeat()
        }
        
        let autoRepeat = autoRepeatModel.state
        guard autoRepeat == .custom else {
            return autoRepeat.title
        }
        
        var value = ""
        let times = autoRepeatModel.times ?? 0
        let period = autoRepeatModel.period ?? .days
        
        if period == .weeks {
            let weekdayIndex = ((autoRepeatModel.weekday ?? 0) + 1) % 7
            let weekday = Calendar.current.standaloneWeekdaySymbols[weekdayIndex]
            if times >= 1 {
                value = R.string.localizable.everyWeekly("\(times + 1)", "\(weekday)")
            } else {
                value =  R.string.localizable.weeklyWeekday("\(weekday)")
            }
        } else {
            if times == 0 {
                value = period.title
            } else {
                value = R.string.localizable.everyTimesPeriod("\(times + 1)", "\(period.title)") 
            }
        }
        
        return value
    }
    
    var autoRepeatModel: AutoRepeatModel? {
        currentStock?.autoRepeat
    }
    
    var isReminder: Bool {
        currentStock?.isReminder ?? false
    }
    
    override func getDefaultStore() -> Store? {
        let modelStores = pantry.stock.compactMap({ $0.store })
            .sorted(by: { $0.createdAt > $1.createdAt })
        defaultStore = modelStores.first
        return defaultStore
    }
    
    override func setCostOfProductPerUnit() {
        costOfProductPerUnit = currentStock?.cost
    }
    
    func saveStock(productName: String, category: String, description: String,
                   isAvailability: Bool,
                   image: UIImage?, isUserImage: Bool, store: Store?, quantity: Double?,
                   isAutoRepeat: Bool, autoRepeatSetting: AutoRepeatModel?,
                   isReminder: Bool) {
        var imageData: Data?
        if let image {
            imageData = image.jpegData(compressionQuality: 0.5)
        }
        let stock: Stock
        if var currentStock {
            currentStock.name = productName
            currentStock.category = category
            currentStock.description = description
            currentStock.imageData = imageData
            currentStock.isUserImage = isUserImage
            currentStock.store = store
            currentStock.cost = costOfProductPerUnit ?? -1
            currentStock.quantity = quantity == 0 ? nil : quantity
            currentStock.unitId = currentSelectedUnit
            currentStock.isAvailability = isAvailability
            currentStock.isAutoRepeat = isAutoRepeat
            currentStock.isReminder = isReminder
            currentStock.autoRepeat = autoRepeatSetting
            stock = currentStock
        } else {
            let index = CoreDataManager.shared.getAllStocks(for: pantry.id.uuidString)?.count ?? 1
            stock = Stock(index: -index,
                          pantryId: pantry.id, name: productName,
                          imageData: imageData, description: description,
                          category: category,
                          store: store, cost: costOfProductPerUnit ?? -1,
                          quantity: quantity == 0 ? nil : quantity,
                          unitId: currentSelectedUnit,
                          isAvailability: isAvailability,
                          isAutoRepeat: isAutoRepeat,
                          autoRepeat: autoRepeatSetting,
                          isReminder: isReminder,
                          isUserImage: isUserImage)
        }
        
        CoreDataManager.shared.saveStock(stock: [stock], for: pantry.id.uuidString)
        analytics(stock: stock)
        updateUI?(stock)
    }
    
    override func goToCreateNewStore() {
        let modelForColor = GroceryListsModel(dateOfCreation: Date(), color: pantry.color, products: [], typeOfSorting: 0)
        router?.goToCreateStore(model: modelForColor, compl: { [weak self] store in
            if let store {
                self?.stores.append(store)
            }
            self?.delegate?.newStore(store: store)
        })
    }
    
    func getTheme() -> Theme {
        colorManager.getGradient(index: pantry.color)
    }
    
    // достаем из описания продукта часть с количеством
    private func getProductDescriptionQuantity() -> String? {
        guard let description = currentStock?.description else {
            return nil
        }
        
        guard description.contains(where: { "," == $0 }) else {
            return currentStock?.description
        }
        
        let allSubstring = description.components(separatedBy: ",")
        var quantityString: String?
        
        allSubstring.forEach { substring in
            UnitSystem.allCases.forEach { unit in
                if substring.trimmingCharacters(in: .whitespacesAndNewlines)
                    .smartContains(unit.title) {
                    quantityString = substring
                }
            }
            
        }
        return quantityString
    }
    
    private func analytics(stock: Stock) {
        AmplitudeManager.shared.logEvent(.pantryCreateItem)
        
        if let autoRepeatSetting = stock.autoRepeat {
            let property: EventName
            switch autoRepeatSetting.state {
            case .daily:        property = .pantryRepeatDaily
            case .weekly:       property = .pantryRepeatWeekly
            case .monthly:      property = .pantryRepeatMonthly
            case .yearly:       property = .pantryRepeatYearly
            case .custom:       property = .pantryRepeatCustom
            }
            AmplitudeManager.shared.logEvent(property)
        }
        
        if stock.isReminder {
            AmplitudeManager.shared.logEvent(.pantryRepeatReminder)
        }
        
        if stock.store != nil {
            AmplitudeManager.shared.logEvent(.pantryCreateItemShop)
        }
        
        if stock.cost != nil {
            AmplitudeManager.shared.logEvent(.pantryCreateItemPrice)
        }
        
        if stock.quantity != nil {
            AmplitudeManager.shared.logEvent(.pantryCreateItemQty)
        }
        
        if stock.unitId != nil {
            AmplitudeManager.shared.logEvent(.pantryCreateItemUnits)
        }
        
        if !stock.isAvailability {
            AmplitudeManager.shared.logEvent(.pantryCreateItemUncheck)
        }
        
        if stock.isUserImage {
            AmplitudeManager.shared.logEvent(.pantryCreateItemPhoto)
        } else if stock.imageData != nil {
            AmplitudeManager.shared.logEvent(.pantryCreateItemAutoPhoto)
        }
        

    }
}
