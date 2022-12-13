//
//  CreateNewProductViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 25.11.2022.
//

import Foundation
import Kingfisher
import UIKit

protocol CreateNewProductViewModelDelegate: AnyObject {
    func presentController(controller: UIViewController?)
    func selectCategory(text: String, imageURL: String, defaultSelectedUnit: UnitSystem)
    func deselectCategory()
    func setupController(step: Int)
}

class CreateNewProductViewModel {
    
    var valueChangedCallback: ((Product) -> Void)?
    weak var delegate: CreateNewProductViewModelDelegate?
    weak var router: RootRouter?
    var model: GroceryListsModel?
    private var colorManager = ColorManager()
    var arrayOfproductsByCategories: [DBNetworkProduct]?
    var isMetricSystem = UserDefaultsManager.isMetricSystem
    var currentSelectedUnit: UnitSystem = .gram
    init() {
        arrayOfproductsByCategories = CoreDataManager.shared.getAllNetworkProducts()
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
        UnitSystem.piece
    ]

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
        if let image { imageData = image.pngData() }
        let product = Product(listId: model.id, name: productName, isPurchased: false, dateOfCreation: Date(),
                              category: categoryName, isFavorite: false, imageData: imageData, description: description)
        CoreDataManager.shared.createProduct(product: product)
        valueChangedCallback?(product)
    }
    
    func getBackgroundColor() -> UIColor {
        guard let colorInd = model?.color else { return UIColor.white}
        return colorManager.getGradient(index: colorInd).1
    }
    
    func goToSelectCategoryVC() {
        guard let model else { return }
        let controller = router?.prepareSelectCategoryController(model: model, compl: { [weak self] newCategoryName in
            guard let self = self else { return }
            self.delegate?.selectCategory(text: newCategoryName, imageURL: "", defaultSelectedUnit: self.currentSelectedUnit )
        })
        delegate?.presentController(controller: controller)
    }
    
    func chekIsProductFromCategory(name: String?) {
        guard let arrayOfproductsByCategories else { return }
        
        guard let product = arrayOfproductsByCategories.first(where: {
            guard let name = name,
                  let title = $0.title else { return false }
            return title.lowercased().contains(name.lowercased())
            
        }) else { return }
        getAllInformation(product: product)
    }
    
    func getAllInformation(product: DBNetworkProduct) {
        let imageUrl = product.photo ?? ""
        print("Product id \(product.id)")
        let title = product.marketCategory
        let unitId = product.defaultMarketUnitID
        print("рит = \(unitId)")
        var shouldSelectUnit: MarketUnitClass.MarketUnitPrepared = .init(rawValue: Int(product.defaultMarketUnitID)) ?? .gram
        var properSelectedUnit: UnitSystem = {
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
                return isMetricSystem ?.mililiter : .fluidOz
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
}
