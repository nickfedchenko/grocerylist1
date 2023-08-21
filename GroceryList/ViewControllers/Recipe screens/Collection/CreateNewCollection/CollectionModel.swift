//
//  CollectionModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import CloudKit
import Foundation

struct CollectionModel: Codable {
    var id: Int
    var recordId = ""
    var index: Int
    var title: String
    var color: Int?
    var isDefault: Bool
    var localImage: Data?
    var dishes: [Int]?
    var isDeleteDefault: Bool?
    
    init(id: Int, index: Int, title: String, color: Int,
         isDefault: Bool = false, localImage: Data? = nil,
         dishes: [Int]? = [], isDeleteDefault: Bool = false) {
        self.id = id
        self.index = index
        self.title = title
        self.color = color
        self.isDefault = isDefault
        self.localImage = localImage
        self.dishes = dishes
        self.isDeleteDefault = isDeleteDefault
    }
    
    init(from dbModel: DBCollection) {
        id = Int(dbModel.id)
        index = Int(dbModel.index)
        title = dbModel.title ?? ""
        color = Int(dbModel.color)
        isDefault = dbModel.isDefault
        localImage = dbModel.localImage
        dishes = (try? JSONDecoder().decode([Int].self, from: dbModel.dishes ?? Data())) ?? []
        isDeleteDefault = dbModel.isDelete
    }
    
    init(networkCollection: NetworkCollection) {
        self.id = "\(networkCollection.id)\(networkCollection.pos)".asInt ?? networkCollection.id
        self.index = networkCollection.pos
        self.title = networkCollection.title
        self.isDefault = true
        self.dishes = networkCollection.dishes
        self.isDeleteDefault = false
        
        let newColor = networkCollection.pos % 17
        if newColor == 7 {
            let allColors = Set(0...17).subtracting([7])
            self.color = allColors.randomElement() ?? 0
        } else {
            self.color = newColor
        }
    }
    
    init?(record: CKRecord, imageData: Data?) {
        guard let collectionId = record.value(forKey: "id") as? Int else {
            return nil
        }
        
        id = collectionId
        recordId = record.recordID.recordName
        
        index = record.value(forKey: "index") as? Int ?? 0
        title = record.value(forKey: "title") as? String ?? ""
        color = record.value(forKey: "color") as? Int
        isDefault = record.value(forKey: "isDefault") as? Bool ?? false
        localImage = imageData
        let dishesData = record.value(forKey: "dishes") as? Data ?? Data()
        let dishesFromCloud = (try? JSONDecoder().decode([Int].self, from: dishesData))
        dishes = dishesFromCloud
        isDeleteDefault = record.value(forKey: "isDeleteDefault") as? Bool
    }
}
