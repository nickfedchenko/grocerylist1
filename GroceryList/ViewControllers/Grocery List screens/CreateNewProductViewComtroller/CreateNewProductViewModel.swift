//
//  CreateNewProductViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 25.11.2022.
//

import ApphudSDK
import Foundation
import Kingfisher
import UIKit

protocol CreateNewProductViewModelDelegate: AnyObject {
    func presentController(controller: UIViewController?)
    func selectCategory(text: String, imageURL: String, imageData: Data?, defaultSelectedUnit: UnitSystem?)
    func showKeyboard()
    func newStore(store: Store?)
}

class CreateNewProductViewModel {
    
    weak var delegate: CreateNewProductViewModelDelegate?
    weak var router: RootRouter?
    
    var valueChangedCallback: ((Product) -> Void)?
    var productsChangedCallback: (([String]) -> Void)?
    
    var model: GroceryListsModel?
    var currentSelectedUnit: UnitSystem = .gram
    var stores: [Store] = []
    var currentProduct: Product?
    var costOfProductPerUnit: Double?
    
    let colorManager = ColorManager()
    var defaultStore: Store?
    let network = NetworkEngine()
    var networkBaseProducts: [DBNewNetProduct]?
    var networkDishesProducts: [DBNewNetProduct]?
    var userProducts: [DBProduct]?
    var networkBaseProductTitles: [String] = []
    var networkDishesProductTitles: [String] = []
    var userProductTitles: [String] = []
    var isMetricSystem = UserDefaultsManager.isMetricSystem
    
    init() {
        networkBaseProducts = CoreDataManager.shared.getAllNetworkProducts()?
            .filter({ $0.productTypeId == 1 || $0.productTypeId == -1 })
            .sorted(by: { $0.title ?? "" < $1.title ?? "" })
        networkDishesProducts = CoreDataManager.shared.getAllNetworkProducts()?
            .filter({ $0.productTypeId == 3 })
            .sorted(by: { $0.title ?? "" < $1.title ?? "" })
        userProducts = CoreDataManager.shared.getAllProducts()?
            .sorted(by: { $0.name ?? "" < $1.name ?? "" })
        
        networkBaseProductTitles = networkBaseProducts?.compactMap({ $0.title }) ?? []
        networkDishesProductTitles = networkDishesProducts?.compactMap({ $0.title }) ?? []
        userProductTitles = userProducts?.compactMap({ $0.name }) ?? []
        
        stores = CoreDataManager.shared.getAllStores()?
            .sorted(by: { $0.createdAt ?? Date() > $1.createdAt ?? Date() })
            .compactMap({ Store(from: $0) }) ?? []
    }
    
    var selectedUnitSystemArray: [UnitSystem] {
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
    
    var productCategory: String? {
        currentProduct?.category
    }
    
    var productName: String? {
        currentProduct?.name
    }
    
    var productImage: UIImage? {
        guard let data = currentProduct?.imageData else {
            return nil
        }
        return UIImage(data: data)
    }
    
    var productDescription: String? {
        currentProduct?.description
    }
    
    var userComment: String? {
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
    
    var productQuantityCount: Double? {
        guard let quantity = currentProduct?.quantity else {
            guard let stringArray = getProductDescriptionQuantity()?.components(separatedBy: .decimalDigits.inverted)
                                                               .filter({ !$0.isEmpty }),
                  let lastCount = stringArray.first else {
                return nil
            }
            return Double(lastCount)
        }
        
        return quantity
    }
    
    var productQuantityUnit: UnitSystem? {
        guard let descriptionQuantity = getProductDescriptionQuantity() else {
            return nil
        }
        
        for unit in selectedUnitSystemArray where descriptionQuantity.contains(unit.title) {
            currentSelectedUnit = unit
        }
        
        return currentSelectedUnit
    }
    
    var productStepValue: Double {
        Double(currentSelectedUnit.stepValue)
    }
    
    var isVisibleImage: Bool {
        guard let model else {
            return UserDefaultsManager.isShowImage
        }
        return model.isShowImage.getBool(defaultValue: UserDefaultsManager.isShowImage)
    }
    
    var isVisibleStore: Bool {
        return model?.isVisibleCost ?? true
    }
    
    var productStore: Store? {
        currentProduct?.store
    }
    
    var productCost: String? {
        guard let cost = currentProduct?.cost else {
            return nil
        }
        return String(format: "%.\(cost.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", cost)
    }
    
    var getColorForBackground: UIColor {
        colorManager.getGradient(index: model?.color ?? 0).light
    }
    
    var getColorForForeground: UIColor {
        colorManager.getGradient(index: model?.color ?? 0).medium
    }
    
    func getNumberOfCells() -> Int {
        selectedUnitSystemArray.count
    }
    
    func getTitleForCell(at ind: Int) -> String {
        selectedUnitSystemArray[ind].title
    }
    
    func getDefaultStore() -> Store? {
        let modelStores = model?.products.compactMap({ $0.store })
                                         .sorted(by: { $0.createdAt > $1.createdAt }) ?? []
        defaultStore = modelStores.first
        return defaultStore
    }
    
    func setCostOfProductPerUnit() {
        costOfProductPerUnit = currentProduct?.cost
    }
    
    func setUnit(_ unit: UnitSystem) {
        currentSelectedUnit = unit
    }
    
    func saveProduct(categoryName: String, productName: String, description: String,
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
        if costOfProductPerUnit != nil {
            AmplitudeManager.shared.logEvent(.shopSavePrice)
        }
        
        CoreDataManager.shared.createProduct(product: product)
        valueChangedCallback?(product)
        
        idsOfChangedProducts.insert(product.id)
        idsOfChangedLists.insert(model.id)
        
#if RELEASE
        sendUserProduct(category: categoryName, product: productName)
#endif
    }
    
    func goToSelectCategoryVC() {
        guard let model else { return }
        let controller = router?.prepareSelectCategoryController(model: model, compl: { [weak self] newCategoryName in
            guard let self = self else { return }
            self.delegate?.selectCategory(text: newCategoryName, imageURL: "", imageData: nil, defaultSelectedUnit: nil)
            self.delegate?.showKeyboard()
        })
        delegate?.presentController(controller: controller)
    }
    
    func goToCreateNewStore() {
        router?.goToCreateStore(model: model, compl: { [weak self] store in
            if let store {
                self?.stores.append(store)
            }
            self?.delegate?.newStore(store: store)
        })
    }
    
    func showAutoCategoryAlert() {
        var title = ""
        var message = ""
        if (FeatureManager.shared.isActiveAutoCategory ?? true) {
            title = R.string.localizable.autoCategoryTitleOn()
            message = R.string.localizable.autoCategoryDescOn()
        } else {
            message = R.string.localizable.autoCategoryDescOff()
            
        }
        router?.showAlertVC(title: title, message: message, completion: {
            UserDefaultsManager.countInfoMessage = 11
        })
    }
    
    func checkIsProductFromCategory(name: String?) {
        guard let name = name?.prepareForSearch() else {
            productsChangedCallback?([])
            return
        }
        let userProductTitles = search(name: name, by: userProductTitles)
        let networkProductTitles = search(name: name, by: networkBaseProductTitles)
        let networkDishesProductTitles = search(name: name, by: networkDishesProductTitles)
        if name.count > 1 {
            let titles = Array(Set(userProductTitles + networkProductTitles))
            let productTitles = sortTitle(by: name, titles: titles)
            let dishesTitle = sortTitle(by: name, titles: networkDishesProductTitles)
            productsChangedCallback?(productTitles + dishesTitle)
        } else {
            productsChangedCallback?([])
        }
        
        if userProductTitles.contains(where: { $0.prepareForSearch() == name }),
           let product = userProducts?.first(where: { $0.name?.prepareForSearch().smartContains(name) ?? false }) {
            getInformation(userProduct: product)
            return
        }
        
        if networkProductTitles.contains(where: { $0.prepareForSearch() == name }),
           let product = networkBaseProducts?.first(where: { $0.title?.prepareForSearch().smartContains(name) ?? false }) {
            getInformation(networkProduct: product)
            return
        }
        
        if networkDishesProductTitles.contains(where: { $0.prepareForSearch() == name }),
           let product = networkDishesProducts?.first(where: { $0.title?.prepareForSearch().smartContains(name) ?? false }) {
            getInformation(networkProduct: product)
            return
        }
        let isAutomaticCategory = model?.isAutomaticCategory ?? true
        let title = isAutomaticCategory ? R.string.localizable.other() : ""
        delegate?.selectCategory(text: title, imageURL: "", imageData: nil, defaultSelectedUnit: nil)
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
        let photoUrl = networkProduct.photo ?? ""
        let imageUrl = isVisibleImage ? photoUrl : ""
        let isAutomaticCategory = model?.isAutomaticCategory ?? true
        let categoryTitle = networkProduct.marketCategory ?? R.string.localizable.other()
        let title = isAutomaticCategory ? categoryTitle : ""
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
        delegate?.selectCategory(text: title, imageURL: imageUrl, imageData: nil, defaultSelectedUnit: currentSelectedUnit)
    }
    
    private func getInformation(userProduct: DBProduct) {
        let imageData = userProduct.image
        let isAutomaticCategory = model?.isAutomaticCategory ?? true
        let categoryTitle = userProduct.category ?? R.string.localizable.other()
        let title = isAutomaticCategory ? categoryTitle : ""
        let defaultUnit: UnitSystem = isMetricSystem ? .gram : .ozz
        let shouldSelectUnit: UnitSystem = .init(rawValue: Int(userProduct.unitId)) ?? defaultUnit
        currentSelectedUnit = shouldSelectUnit
        delegate?.selectCategory(text: title, imageURL: "", imageData: imageData, defaultSelectedUnit: currentSelectedUnit)
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
    private func sendUserProduct(category: String, product: String) {
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
        
        if let category = CoreDataManager.shared.getDefaultCategories()?.first(where: { category == $0.name }) {
            categoryId = "\(category.id)"
        }
        
        let userProduct = UserProduct(userToken: userToken,
                                      country: countryName(),
                                      lang: Locale.current.languageCode,
                                      modelType: productType,
                                      modelId: productId,
                                      modelTitle: product,
                                      categoryId: categoryId,
                                      categoryTitle: category,
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
        default: return "product"
        }
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
