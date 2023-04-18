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
    func deselectCategory() // потом убрать
    func setupController(step: Int) // потом убрать
}

class CreateNewProductViewModel {
    
    weak var delegate: CreateNewProductViewModelDelegate?
    weak var router: RootRouter?
    
    var valueChangedCallback: ((Product) -> Void)?
    var productsChangedCallback: (([String]) -> Void)?
    
    var model: GroceryListsModel?
    var currentSelectedUnit: UnitSystem = .gram
    var currentProduct: Product?
    
    private let network = NetworkEngine()
    private var colorManager = ColorManager()
    private var networkBaseProducts: [DBNewNetProduct]?
    private var networkDishesProducts: [DBNewNetProduct]?
    private var userProducts: [DBProduct]?
    private var networkBaseProductTitles: [String] = []
    private var networkDishesProductTitles: [String] = []
    private var userProductTitles: [String] = []
    private var isMetricSystem = UserDefaultsManager.isMetricSystem
    
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
    }
    
    var selectedUnitSystemArray: [UnitSystem] {
        isMetricSystem ? arrayForMetricSystem : arrayForImperalSystem
    }
    
    var stores: [String] {
        ["test1", "test2", "test3"]
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
        guard let quantity = productDescriptionQuantity else {
            return productDescription
        }
        return productDescription?.replacingOccurrences(of: quantity, with: "")
    }
    
    var productQuantityCount: Double? {
        guard let stringArray = productDescriptionQuantity?.components(separatedBy: .decimalDigits.inverted)
            .filter({ !$0.isEmpty }),
              let lastCount = stringArray.first else {
            return nil
        }
        return Double(lastCount)
    }
    
    var productQuantityUnit: String? {
        guard let descriptionQuantity = productDescriptionQuantity else {
            return nil
        }
        
        for unit in selectedUnitSystemArray where descriptionQuantity.contains(unit.title) {
            currentSelectedUnit = unit
        }
        
        return currentSelectedUnit.title
    }
    
    var productStepValue: Double {
        Double(currentSelectedUnit.stepValue)
    }
    
    var isVisibleImage: Bool {
        guard let model else {
            return UserDefaultsManager.isShowImage
        }
        switch model.isShowImage {
        case .nothing:      return UserDefaultsManager.isShowImage
        case .switchOn:     return true
        case .switchOff:    return false
        }
    }
    
    var getColorForBackground: UIColor {
        colorManager.getGradient(index: model?.color ?? 0).1
    }
    
    var getColorForForeground: UIColor {
        colorManager.getGradient(index: model?.color ?? 0).0
    }
    
    private var productDescriptionQuantity: String? {
        guard let description = currentProduct?.description else {
            return nil
        }
        if description.contains(where: { "," == $0 }),
           let firstIndex = description.firstIndex(of: ",") {
            let quantityStr = description[firstIndex..<description.endIndex]
            return String(quantityStr)
        }
        return currentProduct?.description
    }
    
    func getNumberOfCells() -> Int {
        selectedUnitSystemArray.count
    }
    
    func getTitleForCell(at ind: Int) -> String {
        selectedUnitSystemArray[ind].title
    }
    
    func cellSelected(at ind: Int) {
        currentSelectedUnit = selectedUnitSystemArray[ind]
        let step = currentSelectedUnit.stepValue
        delegate?.setupController(step: step)
    }
    
    func saveProduct(categoryName: String, productName: String, description: String, image: UIImage?, isUserImage: Bool) {
        guard let model else { return }
        var imageData: Data?
        if let image {
            imageData = image.jpegData(compressionQuality: 0.5)
        }
        let product: Product
        
        if var currentProduct {
            currentProduct.name = productName
            currentProduct.category = categoryName
            currentProduct.imageData = imageData
            currentProduct.description = description
            currentProduct.unitId = currentSelectedUnit
            product = currentProduct
        } else {
            product = Product(listId: model.id, name: productName,
                              isPurchased: false, dateOfCreation: Date(),
                              category: categoryName, isFavorite: false,
                              imageData: imageData, description: description,
                              unitId: currentSelectedUnit, isUserImage: isUserImage)
        }
        
        CoreDataManager.shared.createProduct(product: product)
        valueChangedCallback?(product)
        
        idsOfChangedProducts.insert(product.id)
        idsOfChangedLists.insert(model.id)
        sendUserProduct(category: categoryName, product: productName)
    }
    
    func getBackgroundColor() -> UIColor {
        guard let colorInd = model?.color else { return UIColor.white}
        return colorManager.getGradient(index: colorInd).1
    }
    
    func goToSelectCategoryVC() {
        guard let model else { return }
        let controller = router?.prepareSelectCategoryController(model: model, compl: { [weak self] newCategoryName in
            guard let self = self else { return }
            self.delegate?.selectCategory(text: newCategoryName, imageURL: "", imageData: nil, defaultSelectedUnit: nil)
        })
        delegate?.presentController(controller: controller)
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
        
        if userProductTitles.contains(where: { $0.prepareForSearch().smartContains(name) }),
           let product = userProducts?.first(where: { $0.name?.prepareForSearch().smartContains(name) ?? false }) {
            getInformation(userProduct: product)
            return
        }
        
        if networkProductTitles.contains(where: { $0.prepareForSearch().smartContains(name) }),
           let product = networkBaseProducts?.first(where: { $0.title?.prepareForSearch().smartContains(name) ?? false }) {
            getInformation(networkProduct: product)
            return
        }
        
        if networkDishesProductTitles.contains(where: { $0.prepareForSearch().smartContains(name) }),
           let product = networkDishesProducts?.first(where: { $0.title?.prepareForSearch().smartContains(name) ?? false }) {
            getInformation(networkProduct: product)
            return
        }
        
        delegate?.selectCategory(text: "other".localized, imageURL: "", imageData: nil, defaultSelectedUnit: nil)
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
        let title = networkProduct.marketCategory ?? R.string.localizable.other()
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
        let title = userProduct.category ?? R.string.localizable.other()
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
        let product = product.trimmingCharacters(in: .whitespaces)
        
        if let user = UserAccountManager.shared.getUser() {
            userToken = user.token
        }
        
        if let product = networkBaseProducts?.first(where: { $0.title?.lowercased() == product.lowercased() }) {
            productId = "\(product.id)"
        }
        
        if let category = CoreDataManager.shared.getDefaultCategories()?.first(where: { category == $0.name }) {
            categoryId = "\(category.id)"
        }
        
        let userProduct = UserProduct(userToken: userToken,
                                      itemId: productId,
                                      itemTitle: product,
                                      categoryId: categoryId,
                                      categoryTitle: category)
        
        network.userProduct(userToken: userToken,
                            product: userProduct) { result in
            switch result {
            case .failure(let error):       print(error)
            case .success(let response):    print(response)
            }
        }
    }
}
