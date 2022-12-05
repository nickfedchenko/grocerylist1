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
    func selectCategory(text: String, imageURL: String)
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
        UnitSystem.gram, UnitSystem.kilogram,
        UnitSystem.liter, UnitSystem.mililiter,
        UnitSystem.can, UnitSystem.bottle,
        UnitSystem.pack, UnitSystem.piece
    ]
    
    var arrayForImperalSystem: [UnitSystem] = [
        UnitSystem.ozz, UnitSystem.lbс,
        UnitSystem.pt, UnitSystem.fluidOz,
        UnitSystem.can, UnitSystem.bottle,
        UnitSystem.pack, UnitSystem.piece
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
            self?.delegate?.selectCategory(text: newCategoryName, imageURL: "")
        })
        delegate?.presentController(controller: controller)
    }
    
    func chekIsProductFromCategory(name: String?) {
        guard let arrayOfproductsByCategories else { return }
        guard let product = arrayOfproductsByCategories.first(where: { $0.title == name }) else { return }
        getAllInformation(product: product)
       
    }
    
    func getAllInformation(product: DBNetworkProduct) {
        let imageUrl = product.photo ?? ""
        let title = product.marketCategory
        delegate?.selectCategory(text: title ?? "other".localized, imageURL: imageUrl)
    }
}
