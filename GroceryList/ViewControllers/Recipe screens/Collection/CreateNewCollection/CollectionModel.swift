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
    var color: Int
    var isDefault: Bool
    var localImage: Data?
    
    init(id: Int, index: Int, title: String, color: Int, isDefault: Bool = false) {
        self.id = id
        self.index = index
        self.title = title
        self.color = color
        self.isDefault = isDefault
    }
    
    init?(from dbModel: DBCollection) {
        id = Int(dbModel.id)
        index = Int(dbModel.index)
        title = dbModel.title ?? ""
        color = Int(dbModel.color)
        isDefault = dbModel.isDefault
        localImage = dbModel.localImage
    }
}
