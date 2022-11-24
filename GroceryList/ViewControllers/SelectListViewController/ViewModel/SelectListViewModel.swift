//
//  SelectListViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import Foundation
import UIKit

protocol SelectListViewModelDelegate: AnyObject {
    func presentSelectedVC(controller: UIViewController)
}

class SelectListViewModel: MainScreenViewModel {
    
    weak var delegate: SelectListViewModelDelegate?
   
    func cellTapped(with model: GroceryListsModel, viewHeight: Double) {
        guard let viewController = router?.presentSelectProduct(height: viewHeight, model: model) else { return }
        viewController.modalPresentationStyle = .overCurrentContext
      
        delegate?.presentSelectedVC(controller: viewController)
    }
}
