//
//  CollectionModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import Foundation

struct CollectionModel: Codable {
    var id: Int
    var title: String
    
    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
    
    init?(from dbModel: DBCollection) {
        id = Int(dbModel.id)
        title = dbModel.title ?? ""
    }
}
