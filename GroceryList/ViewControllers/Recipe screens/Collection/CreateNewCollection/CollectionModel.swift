//
//  CollectionModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import Foundation

struct CollectionModel: Codable {
    var id: Int
    var index: Int
    var title: String
    var isDefault: Bool
    
    init(id: Int, index: Int, title: String, isDefault: Bool = false) {
        self.id = id
        self.index = index
        self.title = title
        self.isDefault = isDefault
    }
    
    init?(from dbModel: DBCollection) {
        id = Int(dbModel.id)
        index = Int(dbModel.index)
        title = dbModel.title ?? ""
        isDefault = dbModel.isDefault
    }
}
