//
//  ProductsDataManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 11.11.2022.
//

import UIKit

class ProductsDataManager {
    
    var supplays: [Supplay?]
    
    init ( supplays: [Supplay?] ) {
        self.supplays = supplays
        self.supplays = [
            Supplay(name: "dsds", isPurchased: true, dateOfCreation: Date(), category: "1"),
            Supplay(name: "cxx", isPurchased: true, dateOfCreation: Date(), category: "2"),
            Supplay(name: "fff", isPurchased: true, dateOfCreation: Date(), category: "2")
        ]

    }
    
    var dataChangedCallBack: (() -> Void)?
    
    var arrayWithSections: [Category] = [] {
        didSet {
            dataChangedCallBack?()
        }
    }

    func createArrayWithSections() {

        var dict: [ String: [Supplay] ] = [:]
        
        supplays.forEach({ supplay in
            guard let supplay1 = supplay else { return }
            if dict[supplay1.category] != nil {
                dict[supplay1.category]?.append(supplay1)
            } else {
                dict[supplay1.category] = [supplay1]
            }
        })
        
        arrayWithSections = dict.map({ Category(name: $0.key, supplays: $0.value) })
    }
        
}






















//class ProductsDataManager {
//
//    let supplays: [Supplay?]
//
//    init ( supplays: [Supplay?] ) {
//        self.supplays = supplays
//    }
//
//    var dataChangedCallBack: (() -> Void)?
//
//    func createArrayWithSections() {
//        var listOfCategories: Set<Category?> = []
//
//        var listOfCategoryNames: Set<String?> = []
//
//        supplays.forEach({ listOfCategoryNames.insert($0?.name) })
//
//        listOfCategoryNames.forEach({ listOfCategories.insert(Category(name: $0, supplays: [])) })
//
//        supplays.forEach({ suppl in
//
//        })
//    }
//}
