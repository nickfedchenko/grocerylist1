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
    func selectCategory(text: String, imageURL: String, defaultSelectedUnit: UnitSystem?)
    func deselectCategory()
    func setupController(step: Int)
}

class CreateNewProductViewModel {
    
    var valueChangedCallback: ((Product) -> Void)?
    weak var delegate: CreateNewProductViewModelDelegate?
    weak var router: RootRouter?
    var model: GroceryListsModel?
    private var colorManager = ColorManager()
    var arrayOfProductsByCategories: [DBNetProduct]?
    var arrayOfUserProducts: [DBProduct]?
    var isMetricSystem = UserDefaultsManager.isMetricSystem
    var currentSelectedUnit: UnitSystem = .gram
    var currentProduct: Product?
    var productsChangedCallback: (([String]) -> Void)?
    private let network = NetworkEngine()
    
    init() {
        arrayOfProductsByCategories = CoreDataManager.shared.getAllNetworkProducts()?
            .sorted(by: { $0.title ?? "" < $1.title ?? "" })
        arrayOfUserProducts = CoreDataManager.shared.getAllProducts()?
            .sorted(by: { $0.name ?? "" < $1.name ?? "" })
    }
    
    var selectedUnitSystemArray: [UnitSystem] {
        if isMetricSystem {
            return arrayForMetricSystem
        } else {
            return arrayForImperalSystem
        }
    }
    
    var arrayForMetricSystem: [UnitSystem] = [
        UnitSystem.gram,
        UnitSystem.kilogram,
        UnitSystem.liter,
        UnitSystem.mililiter,
        UnitSystem.can,
        UnitSystem.bottle,
        UnitSystem.pack,
        UnitSystem.piece
    ]
    
    var arrayForImperalSystem: [UnitSystem] = [
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
        
        for unit in selectedUnitSystemArray where descriptionQuantity.contains(unit.rawValue.localized) {
            currentSelectedUnit = unit
        }
        
        return currentSelectedUnit.rawValue.localized
    }
    
    var productStepValue: Double {
        Double(currentSelectedUnit.stepValue)
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
        selectedUnitSystemArray[ind].rawValue.localized
    }
    
    func cellSelected(at ind: Int) {
        let step = selectedUnitSystemArray[ind].stepValue
        delegate?.setupController(step: step)
    }
    
    func saveProduct(categoryName: String, productName: String, image: UIImage?, description: String) {
        guard let model else { return }
        print(categoryName, productName)
        var imageData: Data?
        if let image { imageData = image.jpegData(compressionQuality: 0.5) }
        
        currentProduct?.name = productName
        currentProduct?.category = categoryName
        currentProduct?.imageData = imageData
        currentProduct?.description = description
        
        let product = Product(listId: model.id, name: productName, isPurchased: false, dateOfCreation: Date(),
                              category: categoryName, isFavorite: false, imageData: imageData, description: description)
        CoreDataManager.shared.createProduct(product: currentProduct ?? product)
        idsOfChangedProducts.insert(currentProduct?.id ?? product.id)
        idsOfChangedLists.insert(model.id)
        valueChangedCallback?(currentProduct ?? product)
        
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
            self.delegate?.selectCategory(text: newCategoryName, imageURL: "", defaultSelectedUnit: nil)
        })
        delegate?.presentController(controller: controller)
    }
    
    func checkIsProductFromCategory(name: String?) {
        guard let arrayOfProductsByCategories,
              let name = name?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
            productsChangedCallback?([])
            return
        }
        var productTitles: [String] = []
        var product: DBNetProduct?
        for productDB in arrayOfProductsByCategories {
            guard let title = productDB.title?.lowercased()
                .getTitleWithout(symbols: ["(", ")"]) else {
                return
            }
            
            guard title != name else {
                product = productDB
                if name.count > 1, title.count < 40 {
                    productTitles.append(title)
                }
                break
            }
            
            if title.smartContains(name) {
                product = productDB
                if name.count > 1, title.count < 40 {
                    productTitles.append(title)
                }
            }
        }
        
        productTitles += getUserProduct(name: name)
        productTitles = sortTitle(by: name, titles: productTitles)
        productsChangedCallback?(productTitles)
        
        guard let product = product else {
            delegate?.selectCategory(text: "other".localized, imageURL: "", defaultSelectedUnit: nil)
            return
        }
        getAllInformation(product: product)
    }
    
    func getAllInformation(product: DBNetProduct) {
        let imageUrl = product.photo ?? ""
        let title = product.marketCategory
        let unitId = product.defaultMarketUnitID
        let shouldSelectUnit: MarketUnitClass.MarketUnitPrepared = .init(rawValue: Int(product.defaultMarketUnitID)) ?? .gram
        let properSelectedUnit: UnitSystem = {
            switch shouldSelectUnit {
            case .bottle:
                return .bottle
            case .gram:
                return isMetricSystem ? .gram : .ozz
            case .kilogram:
                return isMetricSystem ? .kilogram : .lbс
            case .litter:
                return isMetricSystem ? .liter : .pt
            case .millilitre:
                return isMetricSystem ? .mililiter : .fluidOz
            case .pack:
                return .pack
            case .piece:
                return .piece
            case .tin:
                return .can
            }
        }()
        currentSelectedUnit = properSelectedUnit
        delegate?.selectCategory(text: title ?? "other".localized, imageURL: imageUrl, defaultSelectedUnit: currentSelectedUnit)
    }
    
    private func getUserProduct(name: String) -> [String] {
        var productTitles: [String] = []
        if let arrayOfUserProducts {
            arrayOfUserProducts.forEach { product in
                if name.count > 1, let productName = product.name,
                   productName.smartContains(name), productName.count < 30 {
                    productTitles.append(productName)
                }
            }
        }
        return productTitles
    }
    
    private func sortTitle(by name: String, titles: [String]) -> [String] {
        var titles = titles
        let titleByLetter = titles.filter { $0.prefix(3).lowercased() == name.prefix(3).lowercased() }
        titleByLetter.forEach { title in
            titles.removeAll { $0 == title }
        }
        
        return titleByLetter + titles
    }
    
    private func sendUserProduct(category: String, product: String) {
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
        
        if let userCategory = CoreDataManager.shared.getAllCategories()?.first(where: { category == $0.name }) {
            categoryId = "\(userCategory.id)"
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
