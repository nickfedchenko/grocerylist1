//
//  RecipesListViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.06.2023.
//

import UIKit

class RecipesListViewModel {
    
    weak var router: RootRouter?
    
    private var section: RecipeSectionsModel
    private var colorManager = ColorManager()
    
    init(with section: RecipeSectionsModel) {
        self.section = section
    }
    
    var title: String {
        section.sectionType.title
    }
    
    var recipesCount: Int {
        section.recipes.count
    }
    
    var theme: Theme {
        colorManager.getGradient(index: section.color)
    }
    
    func getModel(by indexPath: IndexPath) -> ShortRecipeModel {
        section.recipes[indexPath.item]
    }
    
    func showRecipe(by indexPath: IndexPath) {
        let recipeId = section.recipes[indexPath.item].id
        guard let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId),
              let model = Recipe(from: dbRecipe) else {
            return
        }
        router?.goToRecipe(recipe: model)
    }
    
    func showSearch() {
        router?.goToSearchInRecipe(section: section)
    }
    
    func collectionImage() -> (url: String, data: Data?) {
        let url = section.imageUrl ?? ""
        let data = section.localImage
        return (url, data)
    }
    
    func savePhoto(image: UIImage?) {
        guard let dbCollection = CoreDataManager.shared.getCollection(by: section.collectionId) else {
            return
        }
        var collection = CollectionModel(from: dbCollection)
        collection.localImage = image?.pngData()
        
        CoreDataManager.shared.saveCollection(collections: [collection])
    }
}
