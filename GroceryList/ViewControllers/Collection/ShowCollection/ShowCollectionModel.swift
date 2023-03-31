//
//  ShowCollectionModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 31.03.2023.
//

import Foundation

struct ShowCollectionModel {
    
    var collection: CollectionModel
    var recipes: [Recipe]
    var select: Bool
    
    struct Recipe: Hashable, Equatable {
        let id: Int64
        var localCollection: [CollectionModel]?
        
        init?(from dbModel: DBRecipe) {
            id = dbModel.id
            localCollection = (try? JSONDecoder().decode([CollectionModel].self, from: dbModel.localCollection ?? Data())) ?? []
        }
        
        static func == (left: ShowCollectionModel.Recipe, right: ShowCollectionModel.Recipe) -> Bool {
            return left.id == right.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
