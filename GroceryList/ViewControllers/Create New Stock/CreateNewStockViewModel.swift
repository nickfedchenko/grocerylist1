//
//  CreateNewStockViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.06.2023.
//

import UIKit

class CreateNewStockViewModel: CreateNewProductViewModel {

    var updateUI: ((Stock) -> Void)?

    var pantry: PantryModel?
    var currentStock: Stock?
    
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
        colorManager.getGradient(index: pantry?.color ?? 0).light
    }
    
    override var getColorForForeground: UIColor {
        colorManager.getGradient(index: pantry?.color ?? 0).medium
    }
    
    var autoRepeat: String? {
        (currentStock?.isAutoRepeat ?? false) ? "AutoRepeat" : "no AutoRepeat"
    }
    
    override func getDefaultStore() -> Store? {
        let modelStores = pantry?.stock.compactMap({ $0.store })
                                         .sorted(by: { $0.createdAt > $1.createdAt }) ?? []
        defaultStore = modelStores.first
        return defaultStore
    }
    
    override func setCostOfProductPerUnit() {
        costOfProductPerUnit = currentProduct?.cost
    }
    
    override func saveProduct(categoryName: String, productName: String, description: String,
                     image: UIImage?, isUserImage: Bool, store: Store?, quantity: Double?) {
        guard let model else { return }
        var imageData: Data?
        if let image {
            imageData = image.jpegData(compressionQuality: 0.5)
        }
        let product: Product
        let categoryName = categoryName == R.string.localizable.category() ? "" : categoryName
        if var currentProduct {
            currentProduct.name = productName
            currentProduct.category = categoryName
            currentProduct.imageData = imageData
            currentProduct.description = description
            currentProduct.unitId = currentSelectedUnit
            currentProduct.store = store
            currentProduct.cost = costOfProductPerUnit ?? -1
            currentProduct.quantity = quantity == 0 ? nil : quantity
            product = currentProduct
        } else {
            product = Product(listId: model.id, name: productName,
                              isPurchased: false, dateOfCreation: Date(),
                              category: categoryName, isFavorite: false,
                              imageData: imageData, description: description,
                              unitId: currentSelectedUnit, isUserImage: isUserImage,
                              store: store, cost: costOfProductPerUnit ?? -1,
                              quantity: quantity == 0 ? nil : quantity)
        }
        
//        CoreDataManager.shared.createProduct(product: product)
        valueChangedCallback?(product)
        
        idsOfChangedProducts.insert(product.id)
        idsOfChangedLists.insert(model.id)
        
#if RELEASE
        sendUserProduct(category: categoryName, product: productName)
#endif
    }
    
    override func goToCreateNewStore() {
        let modelForColor = GroceryListsModel(dateOfCreation: Date(),
                                              color: pantry?.color ?? 0, products: [], typeOfSorting: 0)
        router?.goToCreateStore(model: modelForColor, compl: { [weak self] store in
            if let store {
                self?.stores.append(store)
                self?.delegate?.newStore(store: store)
            }
        })
    }
    
    func getTheme() -> Theme {
        colorManager.getGradient(index: pantry?.color ?? 0)
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
}
