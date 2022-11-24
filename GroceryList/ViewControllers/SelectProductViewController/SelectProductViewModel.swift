//
//  SelectProductViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import UIKit

protocol SelectProductViewModelDelegate: AnyObject {
    func reloadCollection()
}

class SelectProductViewModel {
    
    init(model: GroceryListsModel, copiedProducts: Set<Product>) {
        self.model = model
        self.copiedProducts = copiedProducts
        prepareArrayOfProducts()
    }
    
    var productsSelectedCompl: ((Set<Product>) -> Void)?
    private var colorManager = ColorManager()
    weak var router: RootRouter?
    var model: GroceryListsModel
    var arrayOfProducts: [Product] = []
    var copiedProducts: Set<Product>
    weak var delegate: SelectProductViewModelDelegate?
    let firstFakeProduct = Product(listId: UUID(), name: "", isPurchased: false,
                                   dateOfCreation: Date(), category: "", isFavorite: false)
    
    private func prepareArrayOfProducts() {
        guard !model.products.isEmpty else { return }
        arrayOfProducts.append(firstFakeProduct)
        arrayOfProducts.append(contentsOf: model.products)
        arrayOfProducts.sort(by: { $0.name < $1.name })
        
        copiedProducts.forEach({ product in
            if let index = arrayOfProducts.firstIndex(of: product ) {
                arrayOfProducts.remove(at: index)
                arrayOfProducts.insert(product, at: index)
            }
        })
//
//        copiedProducts.forEach({ product in
//            for (ind, prod) in arrayOfProducts.enumerated() {
//                if prod.id == product.id {
//                    arrayOfProducts.remove(at: ind)
//                    arrayOfProducts.insert(product, at: ind)
//                }
//            }
//        })
        
    }
    
    func getNameOfList() -> String {
        return model.name ?? ""
    }
    
    func getColorForBackground() -> UIColor {
        colorManager.getGradient(index: model.color).1
    }
    
    func getForegroundColor() -> UIColor {
        colorManager.getGradient(index: model.color).0
    }
    
    func getNumberOfCell() -> Int {
        arrayOfProducts.count
    }
    
    func getNameOfCell(at ind: Int) -> String {
        arrayOfProducts[ind].name
    }
    
    func isProductSelected(at ind: Int) -> Bool {
        arrayOfProducts[ind].isSelected
    }
    
    func cellSelected(at ind: Int) {
        if ind == 0 {
            for ind in arrayOfProducts.indices {
                arrayOfProducts[ind].isSelected = true
            }
        } else {
            if arrayOfProducts[ind].isSelected {
                copiedProducts.remove(arrayOfProducts[ind])
                arrayOfProducts[ind].isSelected = !arrayOfProducts[ind].isSelected
            } else {
                arrayOfProducts[ind].isSelected = !arrayOfProducts[ind].isSelected
                copiedProducts.insert(arrayOfProducts[ind])
            }
        }
        
        delegate?.reloadCollection()
    }
    
    func doneButtonPressed() {
        arrayOfProducts.forEach({ product in
            if product.isSelected {
                guard product != firstFakeProduct else { return }
                copiedProducts.insert(product)
            }
        })
        print(copiedProducts.count)
        productsSelectedCompl?(copiedProducts)
    }
}
