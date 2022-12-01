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
    func selectCategory(text: String, imageURL: String, preferedUint: String)
    func deselectCategory()
    func setupController(step: Int)
}

class CreateNewProductViewModel {
    
    var network: NetworkDataProvider
    var valueChangedCallback: ((Product) -> Void)?
    weak var delegate: CreateNewProductViewModelDelegate?
    weak var router: RootRouter?
    var model: GroceryListsModel?
    private var colorManager = ColorManager()
    var arrayOfproductsByCategories: GetAllProductsResponse?
    var isMetricSystem = UserDefaultsManager.isMetricSystem
    
    init(network: NetworkDataProvider) {
        self.network = network
        network.getAllProducts { post in
            switch post {
            case .failure(let error):
                print(error)
            case .success(let response):
                self.arrayOfproductsByCategories = response
                print(response)
            }
        }
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
            self?.delegate?.selectCategory(text: newCategoryName, imageURL: "", preferedUint: "")
        })
        delegate?.presentController(controller: controller)
    }
    
    func chekIsProductFromCategory(name: String?) {
        guard let arrayOfproductsByCategories else { return }
        guard let product = arrayOfproductsByCategories.data.first(where: { $0.title == name }) else { return }
        getAllInformation(product: product)
       
    }
    
    func getAllInformation(product: NetworkProductModel) {
        let imageUrl = product.photo
        let title = product.marketCategory?.title
        let unit = product.units.first(where: { $0.isDefault == true })
        delegate?.selectCategory(text: title ?? "other".localized, imageURL: imageUrl, preferedUint: unit?.title ?? "")
    }
}
