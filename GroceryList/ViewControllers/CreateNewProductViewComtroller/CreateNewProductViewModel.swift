//
//  CreateNewProductViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 25.11.2022.
//

import Kingfisher
import Foundation
import UIKit

protocol CreateNewProductViewModelDelegate: AnyObject {
    func presentController(controller: UIViewController?)
    func selectCategory(text: String, imageURL: String)
    func deselectCategory()
}

class CreateNewProductViewModel {
    
    var arrayOfproductsByCategories: GetAllProductsResponse?
   
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
    
    var network: NetworkDataProvider
    var valueChangedCallback: ((Product) -> Void)?
    weak var delegate: CreateNewProductViewModelDelegate?
    weak var router: RootRouter?
    var model: GroceryListsModel?
    private var colorManager = ColorManager()
    
    func getBackgroundColor() -> UIColor {
        guard let colorInd = model?.color else { return UIColor.white}
        return colorManager.getGradient(index: colorInd).1
    }
    
    func goToSelectCategoryVC() {
        guard let model else { return }
        let controller = router?.prepareSelectCategoryController(model: model, compl: { _ in
            
        })
        delegate?.presentController(controller: controller)
    }
    
    func chekIsProductFromCategory(name: String?) {
        guard let arrayOfproductsByCategories else { return }
        guard let product = arrayOfproductsByCategories.data.first(where: { $0.title == name }) else { delegate?.deselectCategory(); return }
        getAllInformation(product: product)
       
    }
    
    func getAllInformation(product: NetworkProductModel) {
        let imageUrl = product.photo
        let title = product.title
        let units = product.units
        delegate?.selectCategory(text: title, imageURL: imageUrl)
    }
}

enum UnitSystem {
    
    case unaited (_: USUntiSystem)
    case metric (_: MetricUnitSystem)
    
    enum USUntiSystem {
        case ozz
        case pondus
        case gall
        case fluidOz
        case pack
        case piece
        
        var stepValue: Int {
            switch self {
            case .ozz:
                return 100
            case .fluidOz:
                return 20
            case .pack:
                return 1
            case .piece:
                return 1
            case .gall:
                return 1
            case .pondus:
                return 1
            }
        }
    }

    enum MetricUnitSystem: Int {
        case kilogram
        case gram
        case mililiter
        case liter
        case pack
        case piece
    }
}
