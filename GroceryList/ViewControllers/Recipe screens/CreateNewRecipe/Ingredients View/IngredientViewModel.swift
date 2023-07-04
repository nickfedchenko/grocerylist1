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

final class IngredientViewModel: CreateNewProductViewModel {

    weak var ingredientDelegate: IngredientViewModelDelegate?
    var ingredientCallback: ((Ingredient) -> Void)?
    var isShowCost: Bool? = false

    var getNumberOfCells: Int {
        selectedUnitSystemArray.count
    }

    private var categoryTitle = ""
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
    
    override var getColorForBackground: UIColor {
        R.color.background() ?? .white
    }
    
    override var getColorForForeground: UIColor {
        R.color.darkGray() ?? .black
    }
    
    override var isVisibleStore: Bool {
        return isShowCost ?? false
    }
    
    func save(title: String, quantity: Double,
              quantityStr: String?, description: String?, localImage: UIImage?) {
        let product = getProduct(title: title, image: localImage)
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
#if RELEASE
        sendUserProduct(product: title)
#endif
    }
    
    override func goToSelectCategoryVC() {
        guard let controller = router?.prepareSelectCategoryController(model: nil, compl: { [weak self] newCategoryName in
            guard let self = self else { return }
            self.ingredientDelegate?.categoryChange(title: newCategoryName)
            self.categoryTitle = newCategoryName
        }) else {
            return
        }
        controller.modalTransitionStyle = .crossDissolve
        router?.navigationPresent(controller, animated: true)
    }
    
    override func getTitleForCell(at ind: Int) -> String {
        selectedUnitSystemArray[ind].title
    }
    
    func cellSelected(at ind: Int) {
        let step = selectedUnitSystemArray[ind]
        currentSelectedUnit = step
        ingredientDelegate?.unitChange(step)
    }
    
    private func getProduct(title: String, image: UIImage?) -> NetworkProductModel {
        return NetworkProductModel(
            id: UUID().integer,
            title: title,
            productTypeId: 2,
            marketCategory: getMarketCategory(),
            units: [],
            photo: "",
            marketUnit: nil,
            localImage: image?.pngData()
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
        ingredientDelegate?.categoryChange(title: title)
        categoryTitle = title
        ingredientDelegate?.unitChange(currentSelectedUnit)
    }
    
    private func getInformation(userProduct: DBProduct) {
        let title = userProduct.category ?? R.string.localizable.selectCategory()
        let defaultUnit: UnitSystem = isMetricSystem ? .gram : .ozz
        let shouldSelectUnit: UnitSystem = .init(rawValue: Int(userProduct.unitId)) ?? defaultUnit
        currentSelectedUnit = shouldSelectUnit
        ingredientDelegate?.categoryChange(title: title)
        categoryTitle = title
        ingredientDelegate?.unitChange(currentSelectedUnit)
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
        var userToken = Apphud.userID()
        var productId: String?
        var categoryId: String?
        var productType: String?
        let product = product.trimmingCharacters(in: .whitespaces)
        
        if let user = UserAccountManager.shared.getUser() {
            userToken = user.token
        }
        
        if let product = networkBaseProducts?.first(where: { $0.title?.lowercased() == product.lowercased() }) {
            productId = "\(product.id)"
            productType = getProductType(productTypeId: product.productTypeId)
        }
        
        if let category = CoreDataManager.shared.getDefaultCategories()?.first(where: { categoryTitle == $0.name }) {
            categoryId = "\(category.id)"
        }
        
        let userProduct = UserProduct(userToken: userToken,
                                      country: countryName(),
                                      lang: Locale.current.languageCode,
                                      modelType: productType,
                                      modelId: productId,
                                      modelTitle: product,
                                      categoryId: categoryId,
                                      categoryTitle: categoryTitle,
                                      new: true,
                                      version: "\(Bundle.main.appVersionLong)(\(Bundle.main.appBuild))")
        
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
        default:    return "product"
        }
    }
}
