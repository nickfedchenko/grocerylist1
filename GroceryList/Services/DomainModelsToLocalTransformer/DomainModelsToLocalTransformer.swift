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
    
    func transformCoreDataModelToModel(_ dbModel: DBGroceryListModel) -> GroceryListsModel {
        let id = dbModel.id ?? UUID()
        let date = dbModel.dateOfCreation ?? Date()
        let color = dbModel.color
        let sortType = Int(dbModel.typeOfSorting)
        let products = dbModel.products?.allObjects as? [DBProduct]
        let prod = products?.map({ transformCoreDataProducts(product: $0,
                                                             isVisibleCost: dbModel.isVisibleCost) }) ?? []
        let isShared = dbModel.isShared
        let sharedId = dbModel.sharedListId ?? ""
        let isSharedListOwner = dbModel.isSharedListOwner
        let isShowImage = PictureMatchingState(rawValue: dbModel.isShowImage) ?? .nothing
        
        return GroceryListsModel(id: id, dateOfCreation: date,
                                 name: dbModel.name, color: Int(color),
                                 isFavorite: dbModel.isFavorite, products: prod,
                                 typeOfSorting: sortType, isShared: isShared,
                                 sharedId: sharedId, isSharedListOwner: isSharedListOwner,
                                 isShowImage: isShowImage, isVisibleCost: dbModel.isVisibleCost)
    }
    
    func transformCoreDataProducts(product: DBProduct?, isVisibleCost: Bool) -> Product {
        guard let product = product else {
            return Product(listId: UUID(), name: "",
                           isPurchased: false, dateOfCreation: Date(), category: "", isFavorite: false, description: "")
        }
        
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
        let isUserImage = product.isUserImage
        let userToken = product.userToken
        let storeFromDB = (try? JSONDecoder().decode(Store.self, from: product.store ?? Data()))
        let store = storeFromDB?.title == "" ? nil : storeFromDB
        let cost = product.cost == -1 ? nil : product.cost
        let quantity = product.quantity == -1 ? nil : product.quantity
        let isVisibleCost = isVisibleCost
        return Product(id: id, listId: listId, name: name, isPurchased: isPurchased,
                       dateOfCreation: dateOfCreation, category: category, isFavorite: isFavorite, imageData: imageData,
                       description: description, fromRecipeTitle: fromRecipeTitle,
                       isUserImage: isUserImage, userToken: userToken,
                       store: store, cost: cost, quantity: quantity, isVisibleСost: isVisibleCost)
    }
}
