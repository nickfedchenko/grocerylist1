//
//  SelectCategoryDataSource.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.11.2022.
//

import Foundation

class SelectCategoryDataSource {
    
    init() {
        arrayOfCategories = workingArray
    }
    
    var arrayUpdatedCallback: (() -> Void)?
    
    var arrayOfCategories: [CategoryModel?] = []
       
    let workingArray:  [CategoryModel?] = [
        CategoryModel(name: "category 1"), CategoryModel(name: "category 2"), CategoryModel(name: "category 3"), CategoryModel(name: "category 4"),
        CategoryModel(name: "category 5"), CategoryModel(name: "category 6"), CategoryModel(name: "category 7"), CategoryModel(name: "category 8"),
        CategoryModel(name: "category 9"), CategoryModel(name: "category 10"), CategoryModel(name: "category 11"), CategoryModel(name: "category 12"),
        CategoryModel(name: "category 13"), CategoryModel(name: "category 14"), CategoryModel(name: "category 15"), CategoryModel(name: "category 16"),
        CategoryModel(name: "category 17"), CategoryModel(name: "category 18"), CategoryModel(name: "category 19"), CategoryModel(name: "category 20")
    ]
    
    func getCategory(at ind: Int) -> CategoryModel {
        arrayOfCategories[ind] ?? CategoryModel(name: "")
    }
    
    func isSelected(at ind: Int) -> Bool {
        arrayOfCategories[ind]?.isSelected ?? false
    }
    
    func getNumberOfCategories() -> Int {
        arrayOfCategories.count
    }
    
    func selectCell(at ind: Int) {
        for ind in arrayOfCategories.indices {
            arrayOfCategories[ind]?.isSelected = false
        }
        arrayOfCategories[ind]?.isSelected = true
  
    }
    
    func filterArray(word: String) {
      arrayOfCategories = workingArray.filter({ category in
            guard let category else { return false }
          return category.name.lowercased().contains(word.lowercased())
        })
        
        if word.isEmpty {
            arrayOfCategories = workingArray
        }
        arrayUpdatedCallback?()
    }
}
