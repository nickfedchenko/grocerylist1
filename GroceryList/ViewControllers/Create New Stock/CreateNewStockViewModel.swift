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
        
        return quantity
    }
    
    override var productQuantityUnit: UnitSystem? {
        guard let descriptionQuantity = getProductDescriptionQuantity() else {
            return nil
        }
        
        for unit in selectedUnitSystemArray where descriptionQuantity.contains(unit.title) {
            currentSelectedUnit = unit
        }
        
        return currentSelectedUnit
    }
    
    override var isVisibleImage: Bool {
        guard let model else {
            return UserDefaultsManager.isShowImage
        }
        return model.isShowImage.getBool(defaultValue: UserDefaultsManager.isShowImage)
    }
    
    override var isVisibleStore: Bool {
        return model?.isVisibleCost ?? true
    }
    
    override var productStore: Store? {
        currentProduct?.store
    }
    
    override var productCost: String? {
        guard let cost = currentProduct?.cost else {
            return nil
        }
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
            return "Auto Repeat"
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
                value = "every \(times + 1) weekly: \(weekday)"
            } else {
                value = "weekly: \(weekday)"
            }
        } else {
            if times == 0 {
                value = period.title
            } else {
                value = "every \(times + 1) \(period.title)"
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
        costOfProductPerUnit = currentProduct?.cost
    }
    
    func saveStock(productName: String, description: String, isAvailability: Bool, 
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
            currentStock.description = description
            currentStock.imageData = imageData
            currentStock.isUserImage = isUserImage
            currentStock.store = store
            currentStock.quantity = quantity
            currentStock.unitId = currentSelectedUnit
            currentStock.isAvailability = isAvailability
            currentStock.isAutoRepeat = isAutoRepeat
            currentStock.isReminder = isReminder
            currentStock.autoRepeat = autoRepeatSetting
            stock = currentStock
        } else {
            stock = Stock(pantryId: pantry.id, name: productName, imageData: imageData, description: description,
                          store: store, cost: costOfProductPerUnit ?? -1, quantity: quantity == 0 ? nil : quantity,
                          unitId: currentSelectedUnit,
                          isAvailability: isAvailability, isAutoRepeat: isAutoRepeat, autoRepeat: autoRepeatSetting,
                          isReminder: isReminder)
        }
        
        //        CoreDataManager.shared.createProduct(product: product)
        setLocalNotification(stock: stock)
        
        updateUI?(stock)
    }
    
    override func goToCreateNewStore() {
        let modelForColor = GroceryListsModel(dateOfCreation: Date(), color: pantry.color, products: [], typeOfSorting: 0)
        router?.goToCreateStore(model: modelForColor, compl: { [weak self] store in
            if let store {
                self?.stores.append(store)
                self?.delegate?.newStore(store: store)
            }
        })
    }
    
    func getTheme() -> Theme {
        colorManager.getGradient(index: pantry.color)
    }
    
    // достаем из описания продукта часть с количеством
    private func getProductDescriptionQuantity() -> String? {
        guard let description = currentProduct?.description else {
            return nil
        }
        
        guard description.contains(where: { "," == $0 }) else {
            return currentProduct?.description
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
    
    private func setLocalNotification(stock: Stock) {
        guard stock.isReminder,
              let autoRepeat = stock.autoRepeat?.state else {
            return
        }
        let notificationRequest = LocalNotificationsManager.NotificationRequestModel(
            id: stock.id.uuidString,
            title: "Out of stocks",
            subtitle: "\(pantry.name): \(stock.name)",
            autoRepeat: autoRepeat,
            times: stock.autoRepeat?.times,
            weekday: stock.autoRepeat?.weekday,
            period: stock.autoRepeat?.period
        )
        
        LocalNotificationsManager.shared.addNotification(notificationRequest)
    }
}
