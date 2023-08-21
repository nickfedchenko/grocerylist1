//
//  CategoryModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.11.2022.
//

import CloudKit
import Foundation

struct CategoryModel {
    var recordId = ""
    var ind: Int
    var name: String
    var isSelected = false
    
    init(ind: Int, name: String) {
        self.ind = ind
        self.name = name
    }
    
    init?(record: CKRecord) {
        guard let index = record.value(forKey: "ind") as? Int else {
            return nil
        }
        ind = index
        recordId = record.recordID.recordName
        name = record.value(forKey: "name") as? String ?? ""
    }
}
