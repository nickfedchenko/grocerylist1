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
    
    var getNumberOfCells: Int {
        selectedUnitSystemArray.count
    }
    
    var productQuantityCount: Double? {
        return Double(currentSelectedUnit.stepValue)
    }
    
    private let network = NetworkEngine()
    private var networkProducts: [DBNewNetProduct]?
    private var networkDishesProducts: [DBNewNetProduct]?
    private var userProducts: [DBProduct]?
    private var networkProductTitles: [String] = []
    private var networkDishesProductTitles: [String] = []
    private var userProductTitles: [String] = []
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
        networkProducts = CoreDataManager.shared.getAllNetworkProducts()?
            .filter({ $0.productTypeId == 1 || $0.productTypeId == -1 })
            .sorted(by: { $0.title ?? "" < $1.title ?? "" })
        networkDishesProducts = CoreDataManager.shared.getAllNetworkProducts()?
            .filter({ $0.productTypeId == 3 })
            .sorted(by: { $0.title ?? "" < $1.title ?? "" })
        userProducts = CoreDataManager.shared.getAllProducts()?
            .sorted(by: { $0.name ?? "" < $1.name ?? "" })
        
        networkProductTitles = networkProducts?.compactMap({ $0.title }) ?? []
        networkDishesProductTitles = networkDishesProducts?.compactMap({ $0.title }) ?? []
        userProductTitles = userProducts?.compactMap({ $0.name }) ?? []
    }
    
    func save(title: String, quantity: Double,
              quantityStr: String?, description: String?) {
        let product = getProduct(title: title)
        let ingredient = Ingredient(id: UUID().integer,
                                    product: product,
                                    quantity: quantity,
                                    isNamed: false,
                                    unit: MarketUnitClass(id: UUID().integer,
                                                          title: currentSelectedUnit.title,
                                                          shortTitle: currentSelectedUnit.title,
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
        guard let name = name?.prepareForSearch() else {
            productsChangedCallback?([])
            return
        }
        let userProductTitles = search(name: name, by: userProductTitles)
        let networkProductTitles = search(name: name, by: networkProductTitles)
        let networkDishesProductTitles = search(name: name, by: networkDishesProductTitles)
        if name.count > 1 {
            let titles = Array(Set(userProductTitles + networkProductTitles))
            let productTitles = sortTitle(by: name, titles: titles)
            let dishesTitle = sortTitle(by: name, titles: networkDishesProductTitles)
            productsChangedCallback?(productTitles + dishesTitle)
        } else {
            productsChangedCallback?([])
        }
        
        if userProductTitles.contains(where: { $0.prepareForSearch().smartContains(name) }),
           let product = userProducts?.first(where: { $0.name?.prepareForSearch().smartContains(name) ?? false }) {
            getInformation(userProduct: product)
            return
        }
        
        if networkProductTitles.contains(where: { $0.prepareForSearch().smartContains(name) }),
           let product = networkProducts?.first(where: { $0.title?.prepareForSearch().smartContains(name) ?? false }) {
            getInformation(networkProduct: product)
            return
        }
        
        if networkDishesProductTitles.contains(where: { $0.prepareForSearch().smartContains(name) }),
           let product = networkDishesProducts?.first(where: { $0.title?.prepareForSearch().smartContains(name) ?? false }) {
            getInformation(networkProduct: product)
            return
        }
        
        delegate?.categoryChange(title: R.string.localizable.selectCategory())
        categoryTitle = R.string.localizable.selectCategory()
    }
    
    func getTitleForCell(at ind: Int) -> String {
        selectedUnitSystemArray[ind].title
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
            productTypeId: 2,
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
    
    private func search(name: String, by titles: [String]) -> [String] {
        var resultTitles: [String] = []
        
        for title in titles {
            let searchTitle = title.prepareForSearch()
            guard searchTitle != name else {
                resultTitles.append(title)
                break
            }
            
            if searchTitle.smartContains(name) {
                resultTitles.append(title)
            }
        }
        
        return resultTitles
    }
    
    private func getInformation(networkProduct: DBNewNetProduct) {
        let title = networkProduct.marketCategory ?? R.string.localizable.selectCategory()
        let marketId = Int(networkProduct.defaultMarketUnitID)
        let shouldSelectUnit: MarketUnitClass.MarketUnitPrepared = .init(rawValue: marketId ) ?? .gram
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
        delegate?.categoryChange(title: title)
        categoryTitle = title
        delegate?.unitChange(currentSelectedUnit)
    }
    
    private func getInformation(userProduct: DBProduct) {
        let title = userProduct.category ?? R.string.localizable.selectCategory()
        let defaultUnit: UnitSystem = isMetricSystem ? .gram : .ozz
        let shouldSelectUnit: UnitSystem = .init(rawValue: Int(userProduct.unitId)) ?? defaultUnit
        currentSelectedUnit = shouldSelectUnit
        delegate?.categoryChange(title: title)
        categoryTitle = title
        delegate?.unitChange(currentSelectedUnit)
    }
    
    /// сортировка: вперед выносим названия совпадающие с поиском, далее по алфавиту
    private func sortTitle(by name: String, titles: [String]) -> [String] {
        let count = name.count
        var titles = titles
        let titleByLetter = titles.filter { $0.prefix(count).lowercased() == name.prefix(count).lowercased() }
        titleByLetter.forEach { title in
            titles.removeAll { $0 == title }
        }
        
        return titleByLetter + titles
    }
    
    /// отправка созданного продуктов на сервер (метод для аналитики)
    private func sendUserProduct(product: String) {
        var isProductFromBase = false
        var isCategoryFromBase = false
        var userToken = Apphud.userID()
        var productId: String?
        var categoryId: String?
        var productType: String?
        var productCategoryName: String?
        let product = product.trimmingCharacters(in: .whitespaces)
        
        if let user = UserAccountManager.shared.getUser() {
            userToken = user.token
        }
        
        if let product = networkProducts?.first(where: { $0.title?.lowercased() == product.lowercased() }) {
            productId = "\(product.id)"
            productType = getProductType(productTypeId: product.productTypeId)
            productCategoryName = product.marketCategory
            isProductFromBase = true
        }
        
        if let category = CoreDataManager.shared.getDefaultCategories()?.first(where: { categoryTitle == $0.name }) {
            categoryId = "\(category.id)"
            isCategoryFromBase = productCategoryName == category.name
        }

        guard !(isProductFromBase && isCategoryFromBase) else {
            return
        }
        
        let userProduct = UserProduct(userToken: userToken,
                                      country: countryName(),
                                      lang: Locale.current.languageCode,
                                      modelType: productType,
                                      modelId: productId,
                                      modelTitle: product,
                                      categoryId: categoryId,
                                      categoryTitle: categoryTitle,
                                      new: true)
        
        network.userProduct(userToken: userToken,
                            product: userProduct) { result in
            switch result {
            case .failure(let error):       print(error)
            case .success(let response):    print(response)
            }
        }
    }
    
    private func countryName() -> String? {
        guard let countryCode = Locale.current.regionCode else {
            return nil
        }
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            return name
        } else {
            return countryCode
        }
    }
    
    private func getProductType(productTypeId: Int16) -> String {
        switch productTypeId {
        case -1:    return "item"
        case 1:     return "product"
        default: return "product"
        }
    }
}
