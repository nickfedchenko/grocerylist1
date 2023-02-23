//
//  DomainModelsToLocalTransformer.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.02.2023.
//

import Foundation

class DomainModelsToLocalTransformer {
    
    deinit {
        print("DomainModelsToLocalTransformer")
    }
    
    func transformCoreDataModelToModel(_ model: DBGroceryListModel) -> GroceryListsModel {
        let id = model.id ?? UUID()
        let date = model.dateOfCreation ?? Date()
        let color = model.color
        let sortType = Int(model.typeOfSorting)
        let products = model.products?.allObjects as? [DBProduct]
        let prod = products?.map({ transformCoreDataProducts(product: $0) }) ?? []
        let isShared = model.isShared
        let sharedId = model.sharedListId ?? ""
        
        return GroceryListsModel(id: id, dateOfCreation: date,
                                 name: model.name, color: Int(color),
                                 isFavorite: model.isFavorite, products: prod,
                                 typeOfSorting: sortType, isShared: isShared, sharedId: sharedId)
    }
    
    private func transformCoreDataProducts(product: DBProduct?) -> Product {
        guard let product = product else { return Product(listId: UUID(), name: "",
                                                          isPurchased: false, dateOfCreation: Date(), category: "", isFavorite: false, description: "")}

        let id = product.id ?? UUID()
        let listId = product.listId ?? UUID()
        let name = product.name ?? ""
        let isPurchased = product.isPurchased
        let dateOfCreation = product.dateOfCreation ?? Date()
        let category = product.category ?? ""
        let isFavorite = product.isFavorite
        let imageData = product.image
        let description = product.userDescription ?? ""
        let fromRecipeTitle = product.fromRecipeTitle
        
        return Product(id: id, listId: listId, name: name, isPurchased: isPurchased,
                       dateOfCreation: dateOfCreation, category: category, isFavorite: isFavorite, imageData: imageData, description: description, fromRecipeTitle: fromRecipeTitle)
    }
    
}
