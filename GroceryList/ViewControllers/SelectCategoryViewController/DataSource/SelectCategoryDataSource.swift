//
//  SelectCategoryDataSource.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.11.2022.
//

import Foundation

class SelectCategoryDataSource {
    
    init() {
        arrayOfUsersCategories = CoreDataManager.shared.getAllCategories()
        transformCoreDataModels()
        defaultCategoriesArray.sort(by: { $0.name < $1.name })
        arrayOfCategories = defaultCategoriesArray
        arrayUpdatedCallback?()
    }
    
    var arrayUpdatedCallback: (() -> Void)?
    var arrayOfUsersCategories: [DBCategories]? = []
    var arrayOfCategories: [CategoryModel] = []
    private var selectedCategoryInd: Int? = 0
       
    var defaultCategoriesArray:  [CategoryModel] = [
        CategoryModel(ind: 1, name: "Alcohol".localized), CategoryModel(ind: 2, name: "Grocery".localized),
        CategoryModel(ind: 3, name: "ReadyFood".localized), CategoryModel(ind: 4, name: "Frozen".localized),
        CategoryModel(ind: 5, name: "HealtyFood".localized), CategoryModel(ind: 6, name: "WorldCitchen".localized),
        CategoryModel(ind: 7, name: "Milk".localized), CategoryModel(ind: 8, name: "Drinks".localized),
        CategoryModel(ind: 9, name: "FruitsAndVegetables".localized), CategoryModel(ind: 10, name: "Fish".localized),
        CategoryModel(ind: 11, name: "Sweet".localized), CategoryModel(ind: 12, name: "Bread".localized),
        CategoryModel(ind: 13, name: "Tea".localized), CategoryModel(ind: 14, name: "Meat".localized)
    ]
    
    func transformCoreDataModels() {
        arrayOfUsersCategories?.forEach({
            let category = CategoryModel(ind: Int($0.id), name: $0.name ?? "")
            defaultCategoriesArray.append(category)
        })
    }
    
    func getCategory(at ind: Int) -> CategoryModel {
        arrayOfCategories[ind]
    }
    
    func isSelected(at ind: Int) -> Bool {
        arrayOfCategories[ind].isSelected
    }
    
    func getNumberOfCategories() -> Int {
        arrayOfCategories.count
    }
    
    func getNewCategoryInd() -> Int {
        return defaultCategoriesArray.count + 1
    }
    
    func addNewCategory(category: CategoryModel) {
        print(category.ind)
        defaultCategoriesArray.append(category)
        defaultCategoriesArray.sort(by: { $0.name < $1.name })
        arrayOfCategories = defaultCategoriesArray
        arrayUpdatedCallback?()
    }
    
    func selectCell(at ind: Int) {
        for ind in arrayOfCategories.indices {
            arrayOfCategories[ind].isSelected = false
        }
        arrayOfCategories[ind].isSelected = true
        selectedCategoryInd = arrayOfCategories[ind].ind
    }
    
    func filterArray(word: String) {
      arrayOfCategories = defaultCategoriesArray.filter({ category in
          return category.name.lowercased().contains(word.lowercased())
        })
        
        if word.isEmpty {
            arrayOfCategories = defaultCategoriesArray
        }
        
        for (index, category) in arrayOfCategories.enumerated() {
            if category.ind == selectedCategoryInd {
                arrayOfCategories[index].isSelected = true
            }
        }
        arrayUpdatedCallback?()
    }
}
