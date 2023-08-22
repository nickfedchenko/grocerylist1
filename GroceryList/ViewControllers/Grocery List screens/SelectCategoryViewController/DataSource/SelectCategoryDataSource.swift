//
//  SelectCategoryDataSource.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.11.2022.
//

import Foundation

class SelectCategoryDataSource {
    
    var arrayUpdatedCallback: (() -> Void)?
    
    private var usersCategories: [DBCategories]
    private var defaultCategories:  [DBNetCategory]
    
    private var allCategories: [CategoryModel] = []
    private var categories: [CategoryModel] = []
    private var selectedCategory: String?
    
    init() {
        usersCategories = CoreDataManager.shared.getUserCategories() ?? []
        defaultCategories = CoreDataManager.shared.getDefaultCategories() ?? []
        defaultCategories.removeAll { $0.name ?? "" == R.string.localizable.other() }
        transformCoreDataModels()
        categories = allCategories
        arrayUpdatedCallback?()
    }
    
    func transformCoreDataModels() {
        allCategories += usersCategories.compactMap({ CategoryModel(ind: Int($0.id), name: $0.name ?? "",
                                                                    recordId: $0.recordId ?? "") })
        allCategories += defaultCategories.compactMap({ CategoryModel(ind: Int($0.id), name: $0.name ?? "") })
        allCategories.sort(by: { $0.name < $1.name })
    }
    
    func getCategory(at ind: Int) -> CategoryModel {
        categories[ind]
    }
    
    func isSelected(at ind: Int) -> Bool {
        categories[ind].isSelected
    }
    
    func getNumberOfCategories() -> Int {
        categories.count
    }
    
    func getNewCategoryInd() -> Int {
        return categories.count + 1
    }
    
    func addNewCategory(category: CategoryModel) {
        print(category.ind)
        allCategories.append(category)
        allCategories.sort(by: { $0.name < $1.name })
        categories = allCategories
        arrayUpdatedCallback?()
    }
    
    func selectCell(at ind: Int) {
        for index in categories.indices {
            categories[index].isSelected = index == ind
        }
        
        selectedCategory = categories[ind].name
    }
    
    func filterArray(word: String) {
        categories = allCategories.filter({ category in
          return category.name.lowercased().contains(word.lowercased())
        })

        if word.isEmpty {
            categories = allCategories
        }

        for (index, category) in categories.enumerated() where category.name == selectedCategory {
            categories[index].isSelected = true
        }

        if categories.isEmpty {
            categories = allCategories
        }
        
        arrayUpdatedCallback?()
    }
}
