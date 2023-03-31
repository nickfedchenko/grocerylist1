//
//  IngredientViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.03.2023.
//

import ApphudSDK
import UIKit

protocol IngredientViewModelDelegate: AnyObject {
    func categoryChange(title: String)
    func unitChange(_ unit: UnitSystem)
}

final class IngredientViewModel {
    
    weak var router: RootRouter?
    weak var delegate: IngredientViewModelDelegate?
    var ingredientCallback: ((Ingredient) -> Void)?
    var productsChangedCallback: (([String]) -> Void)?
    
    func getNumberOfCells() -> Int {
        selectedUnitSystemArray.count
    }
    
    var productQuantityCount: Double? {
        return Double(currentSelectedUnit.stepValue)
    }
    
    private let network = NetworkEngine()
    private var arrayOfProductsByCategories: [DBNetProduct]?
    private var arrayOfUserProducts: [DBProduct]?
    private var categoryTitle = ""
    private var isMetricSystem = UserDefaultsManager.isMetricSystem
    private var currentSelectedUnit: UnitSystem = .gram
    private var selectedUnitSystemArray: [UnitSystem] {
        isMetricSystem ? arrayForMetricSystem : arrayForImperalSystem
    }
    private var arrayForMetricSystem: [UnitSystem] = [
        UnitSystem.gram,
        UnitSystem.kilogram,
        UnitSystem.liter,
        UnitSystem.mililiter,
        UnitSystem.can,
        UnitSystem.bottle,
        UnitSystem.pack,
        UnitSystem.piece
    ]
    
    private var arrayForImperalSystem: [UnitSystem] = [
        UnitSystem.ozz,
        UnitSystem.lbс,
        UnitSystem.pt,
        UnitSystem.fluidOz,
        UnitSystem.can,
        UnitSystem.bottle,
        UnitSystem.pack,
        UnitSystem.piece,
        UnitSystem.gallon,
        UnitSystem.quart
    ]
    
    init() {
        arrayOfProductsByCategories = CoreDataManager.shared.getAllNetworkProducts()?
                                                     .sorted(by: { $0.title ?? "" > $1.title ?? "" })
        arrayOfUserProducts = CoreDataManager.shared.getAllProducts()?
                                             .sorted(by: { $0.name ?? "" > $1.name ?? "" })
    }
    
    func save(title: String, quantity: Double,
              quantityStr: String?, description: String?) {
        let product = getProduct(title: title)
        let ingredient = Ingredient(id: UUID().integer,
                                    product: product,
                                    quantity: quantity,
                                    isNamed: false,
                                    unit: MarketUnitClass(id: UUID().integer,
                                                          title: currentSelectedUnit.rawValue,
                                                          shortTitle: currentSelectedUnit.rawValue,
                                                          isOnlyForMarket: false),
                                    description: description,
                                    quantityStr: quantityStr)
        
        ingredientCallback?(ingredient)
        sendUserProduct(product: title)
    }
    
    func goToSelectCategoryVC() {
        guard let controller = router?.prepareSelectCategoryController(model: nil, compl: { [weak self] newCategoryName in
            guard let self = self else { return }
            self.delegate?.categoryChange(title: newCategoryName)
            self.categoryTitle = newCategoryName
        }) else {
            return
        }
        controller.modalTransitionStyle = .crossDissolve
        router?.navigationPresent(controller, animated: true)
    }
    
    func checkIsProductFromCategory(name: String?) {
        guard let arrayOfProductsByCategories,
              let name = name?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                                           .getTitleWithout(symbols: ["(", ")"]) else {
            productsChangedCallback?([])
            return
        }
        var productTitles: [String] = []
        var product: DBNetProduct?
        for productDB in arrayOfProductsByCategories {
            guard let productTitle = productDB.title else { return }
            let title = productTitle.lowercased().getTitleWithout(symbols: ["(", ")"])
            
            guard title != name else {
                product = productDB
                if name.count > 1 {
                    productTitles.append(productTitle)
                }
                break
            }
            
            if title.smartContains(name) {
                product = productDB
                if name.count > 1 {
                    productTitles.append(productTitle)
                }
            }
        }
        
        productTitles += getUserProduct(name: name)
        productTitles = sortTitle(by: name, titles: productTitles)
        productsChangedCallback?(productTitles)
        
        if let updateProduct = arrayOfProductsByCategories.first(where: { $0.title == productTitles.first }) {
            product = updateProduct
        }
        
        guard let product = product else {
            delegate?.categoryChange(title: R.string.localizable.selectCategory())
            categoryTitle = R.string.localizable.selectCategory()
            return
        }
        getAllInformation(product: product)
    }
    
    func getAllInformation(product: DBNetProduct) {
        let title = product.marketCategory
        let shouldSelectUnit: MarketUnitClass.MarketUnitPrepared =
            .init(rawValue: Int(product.defaultMarketUnitID)) ?? .gram
        let properSelectedUnit: UnitSystem = {
            switch shouldSelectUnit {
            case .bottle:       return .bottle
            case .gram:         return isMetricSystem ? .gram : .ozz
            case .kilogram:     return isMetricSystem ? .kilogram : .lbс
            case .litter:       return isMetricSystem ? .liter : .pt
            case .millilitre:   return isMetricSystem ? .mililiter : .fluidOz
            case .pack:         return .pack
            case .piece:        return .piece
            case .tin:          return .can
            }
        }()
        currentSelectedUnit = properSelectedUnit
        delegate?.categoryChange(title: title ?? R.string.localizable.selectCategory())
        categoryTitle = title ?? R.string.localizable.selectCategory()
        delegate?.unitChange(currentSelectedUnit)
    }
    
    func getTitleForCell(at ind: Int) -> String {
        selectedUnitSystemArray[ind].rawValue.localized
    }
    
    func cellSelected(at ind: Int) {
        let step = selectedUnitSystemArray[ind]
        currentSelectedUnit = step
        delegate?.unitChange(step)
    }
    
    private func getProduct(title: String) -> NetworkProductModel {
        return NetworkProductModel(
            id: UUID().integer,
            title: title,
            marketCategory: getMarketCategory(),
            units: [],
            photo: "",
            marketUnit: nil
        )
        
    }
    
    private func getMarketCategory() -> MarketCategory {
        let title = categoryTitle == R.string.localizable.selectCategory() ? R.string.localizable.other()
                                                                           : categoryTitle
        return MarketCategory(id: UUID().integer, title: title)
    }
    
    private func getUserProduct(name: String) -> [String] {
        var productTitles: [String] = []
        if let arrayOfUserProducts {
            arrayOfUserProducts.forEach { product in
                if name.count > 1, let productName = product.name,
                   productName.smartContains(name) {
                    productTitles.append(productName)
                }
            }
        }
        return productTitles
    }
    
    private func sortTitle(by name: String, titles: [String]) -> [String] {
        let count = name.count
        var titles = titles
        let titleByLetter = titles.filter { $0.prefix(count).lowercased() == name.prefix(count).lowercased() }
        titleByLetter.forEach { title in
            titles.removeAll { $0 == title }
        }
        
        return titleByLetter + titles
    }
    
    private func sendUserProduct(product: String) {
        var userToken = Apphud.userID()
        var productId: String?
        var categoryId: String?
        let product = product.trimmingCharacters(in: .whitespaces)
        
        if let user = UserAccountManager.shared.getUser() {
            userToken = user.token
        }
        
        if let product = arrayOfProductsByCategories?.first(where: { $0.title?.lowercased() == product.lowercased() }) {
            productId = "\(product.id)"
        }
        
        if let userCategory = CoreDataManager.shared.getAllCategories()?.first(where: { categoryTitle == $0.name }) {
            categoryId = "\(userCategory.id)"
        }
        
        let userProduct = UserProduct(userToken: userToken,
                                      itemId: productId,
                                      itemTitle: product,
                                      categoryId: categoryId,
                                      categoryTitle: categoryTitle)
        
        network.userProduct(userToken: userToken,
                            product: userProduct) { result in
            switch result {
            case .failure(let error):       print(error)
            case .success(let response):    print(response)
            }
        }
    }
}
