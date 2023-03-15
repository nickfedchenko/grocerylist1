//
//  SearchInRecipeViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.03.2023.
//

import Foundation

final class SearchInRecipeViewModel {
    
    weak var router: RootRouter?
    let placeholder: String
    var updateData: (() -> Void)?
    
    private var recipes: [Recipe] = []
    private var searchText = ""
    private var editableRecipes: [Recipe] = [] {
        didSet { updateData?() }
    }
    
    init(placeholder: String) {
        self.placeholder = placeholder
    }
    
    func search(text: String?) {
//        editableLists.removeAll()
//        var filteredLists: [SearchList] = []
//        guard let text = text?.lowercased().trimmingCharacters(in: .whitespaces),
//              text.count >= 3 else {
//            searchText = ""
//            editableLists = filteredLists
//            return
//        }
//        recipes.forEach { list in
//            let filteredProducts = list.products.filter { $0.name.smartContains(text) }
//            if !filteredProducts.isEmpty {
//                filteredLists.append(SearchList(groceryList: list,
//                                                products: filteredProducts))
//            }
//        }
//        searchText = text
//        editableLists = filteredLists
    }
    
}
