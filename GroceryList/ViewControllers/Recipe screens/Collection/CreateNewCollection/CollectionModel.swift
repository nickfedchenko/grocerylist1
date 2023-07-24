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
    var color: Int?
    var isDefault: Bool
    var localImage: Data?
    var dishes: [Int]
    
    init(id: Int, index: Int, title: String, color: Int, isDefault: Bool = false) {
        self.id = id
        self.index = index
        self.title = title
        self.color = color
        self.isDefault = isDefault
        self.dishes = []
    }
    
    init(from dbModel: DBCollection) {
        id = Int(dbModel.id)
        index = Int(dbModel.index)
        title = dbModel.title ?? ""
        color = Int(dbModel.color)
        isDefault = dbModel.isDefault
        localImage = dbModel.localImage
        dishes = (try? JSONDecoder().decode([Int].self, from: dbModel.dishes ?? Data())) ?? []
    }
    
    init(networkCollection: NetworkCollection) {
        self.id = "\(networkCollection.id)\(networkCollection.pos)".asInt ?? networkCollection.id
        self.index = networkCollection.pos
        self.title = networkCollection.title
        self.isDefault = true
        self.dishes = networkCollection.dishes
        
        let newColor = networkCollection.pos % 17
        if newColor == 7 {
            let allColors = Set(0...17).subtracting([7])
            self.color = allColors.randomElement() ?? 0
        } else {
            self.color = newColor
        }
        
    }
}
