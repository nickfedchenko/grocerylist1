//
//  CreateNewProductViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 25.11.2022.
//

import Foundation
import UIKit

protocol CreateNewProductViewModelDelegate: AnyObject {
    func presentController(controller: UIViewController?)
}

class CreateNewProductViewModel {
    
    init(network: NetworkDataProvider) {
        self.network = network
        network.getAllProducts { post in
            switch post {
            case .failure(let error):
                print(error)
            case .success(let response):
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
}


enum Caregories {
    
}
