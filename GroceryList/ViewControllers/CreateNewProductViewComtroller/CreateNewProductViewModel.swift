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
    
    var valueChangedCallback: ((Product) -> Void)?
    weak var delegate: CreateNewProductViewModelDelegate?
    weak var router: RootRouter?
    var model: GroceryListsModel?
    private var colorManager = ColorManager()

}
