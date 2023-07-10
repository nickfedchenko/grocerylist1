//
//  RecipesListViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.06.2023.
//

import Kingfisher
import UIKit

class RecipesListViewModel {
    
    weak var router: RootRouter?
    var updatePhoto: ((UIImage) -> Void)?
    
    private var section: RecipeSectionsModel
    private var colorManager = ColorManager.shared
    private var allPhotos: [UIImage] = []
    
    init(with section: RecipeSectionsModel) {
        self.section = section
        setAllPhotos()
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
    
    func isDefaultRecipe(by index: Int) -> Bool {
        section.recipes[safe: index]?.isDefaultRecipe ?? false
    }
    
    func showRecipe(by indexPath: IndexPath) {
        let recipeId = section.recipes[indexPath.item].id
        guard let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId),
              let model = Recipe(from: dbRecipe) else {
            return
        }
        router?.goToRecipe(recipe: model, sectionColor: theme)
    }
    
    func showSearch() {
        router?.goToSearchInRecipe(section: section)
    }
    
    func collectionImage() -> (url: String, data: Data?) {
        let url = section.imageUrl ?? ""
        let data = section.localImage
        return (url, data)
    }
    
    func showPhotosFromRecipe() {
        router?.goToPhotosFromRecipe(allPhotos: allPhotos, collectionId: section.collectionId,
                                     updateUI: { [weak self] image in
            self?.updatePhoto?(image)
        })
    }
    
    func addToShoppingList(recipeIndex: Int, contentViewHeigh: CGFloat, delegate: AddProductsSelectionListDelegate) {
        guard let recipeId = section.recipes[safe: recipeIndex]?.id,
              let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId) else {
            return
        }
        let recipe = ShortRecipeModel(withIngredients: dbRecipe)
        let recipeTitle = recipe.title
        let products: [Product] = recipe.ingredients?.map({
            let netProduct = $0.product
            let product = Product(
                name: netProduct.title,
                isPurchased: false,
                dateOfCreation: Date(),
                category: netProduct.marketCategory?.title ?? "",
                isFavorite: false,
                description: "",
                fromRecipeTitle: recipeTitle
            )
            return product
        }) ?? []
        
        router?.goToAddProductsSelectionList(products: products, contentViewHeigh: contentViewHeigh, delegate: delegate)
    }
    
    func addToFavorites(recipeIndex: Int) {
        guard let recipeId = section.recipes[safe: recipeIndex]?.id else {
            return
        }
        let favoritesID = EatingTime.favorites.rawValue
        
        guard !UserDefaultsManager.favoritesRecipeIds.contains(recipeIndex),
              let dbCollection = CoreDataManager.shared.getCollection(by: favoritesID),
              let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId),
              var recipe = Recipe(from: dbRecipe) else {
            return
        }
        
        UserDefaultsManager.favoritesRecipeIds.append(recipeId)
        let favoriteCollection = CollectionModel(from: dbCollection)
        
        if var localCollection = recipe.localCollection {
            localCollection.append(favoriteCollection)
            recipe.localCollection = localCollection
        } else {
            recipe.localCollection = [favoriteCollection]
        }
        CoreDataManager.shared.saveRecipes(recipes: [recipe])

        var updateRecipe = section.recipes.remove(at: recipeIndex)
        updateRecipe.isFavorite = true
        section.recipes.insert(updateRecipe, at: recipeIndex)
    }
    
    func addToCollection(recipeIndex: Int) {
        guard let recipeId = section.recipes[safe: recipeIndex]?.id,
              let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId),
              var recipe = Recipe(from: dbRecipe) else {
            return
        }
        router?.goToShowCollection(state: .select, recipe: recipe, updateUI: { 
//            self?.updateCollection?()
        })

    }
    
    func edit(recipeIndex: Int) {
        guard let recipeId = section.recipes[safe: recipeIndex]?.id,
              let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId),
              var recipe = Recipe(from: dbRecipe) else {
            return
        }
        router?.goToCreateNewRecipe(currentRecipe: recipe, compl: { [weak self] recipe in
            self?.section.recipes.remove(at: recipeIndex)
            self?.section.recipes.insert(ShortRecipeModel(withCollection: recipe), at: recipeIndex)
        })
    }
 
    private func setAllPhotos() {
        DispatchQueue.global().async {
            self.section.recipes.forEach {
                if let imageData = $0.localImage,
                   let image = UIImage(data: imageData) {
                    self.allPhotos.append(image)
                } else if let url = URL(string: $0.photo) {
                    KingfisherManager.shared.retrieveImage(with: url) { result in
                        if let image = try? result.get().image {
                            self.allPhotos.append(image)
                        }
                    }
                }
                
            }
        }
    }
    
}
