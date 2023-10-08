//
//  Extension CoreDataManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.08.2023.
//

import Foundation

extension CoreDataManager {
    
    func getCollectionForSharedSheet() -> [DBCollection]? {
        getAllCollection()
    }
    
    func saveWebRecipe(webRecipe: WebRecipe, url: String?, collections: [CollectionModel]) {
        guard var recipe = Recipe(title: webRecipe.title,
                                  totalServings: webRecipe.servings ?? -1,
                                  cookingTime: webRecipe.cookTime,
                                  description: webRecipe.info,
                                  kcal: getValue(webRecipe: webRecipe),
                                  ingredients: getIngredients(webRecipe: webRecipe),
                                  instructions: webRecipe.methods) else {
            return
        }
        recipe.photo = webRecipe.image ?? ""
        recipe.sourceUrl = url
        saveRecipes(recipes: [recipe])
        CloudManagerForShared.saveCloudData(recipe: recipe)
        
        var updateCollection = collections
        
        if collections.isEmpty,
           let dbFavoritesCollection = getAllCollection()?.first(where: { $0.id == EatingTime.favorites.rawValue }) {
            let favoritesCollection = CollectionModel(from: dbFavoritesCollection)
            updateCollection = [favoritesCollection]
            UserDefaultsManager.shared.favoritesRecipeIds.append(recipe.id)
            CloudManagerForShared.saveCloudSettings()
        }
        
        for (index, collection) in updateCollection.enumerated() {
            if collection.dishes != nil {
                updateCollection[index].dishes?.append(recipe.id)
            } else {
                updateCollection[index].dishes = [recipe.id]
            }
        }
        
        saveCollection(collections: updateCollection)
        updateCollection.forEach { collectionModel in
            CloudManagerForShared.saveCloudData(collectionModel: collectionModel)
        }
    }
    
    private func getIngredients(webRecipe: WebRecipe) -> [Ingredient] {
        var ingredients: [Ingredient] = []
        for ingredient in webRecipe.ingredients where !ingredient.name.isEmpty {
            ingredients.append(Ingredient(id: UUID().integer,
                                          product: getProduct(title: ingredient.name),
                                          quantity: ingredient.amount.asDouble ?? 0,
                                          isNamed: false,
                                          unit: MarketUnitClass(id: UUID().integer,
                                                                title: ingredient.unit,
                                                                shortTitle: ingredient.unit,
                                                                isOnlyForMarket: false))
                               )
        }

        return ingredients
    }
    
    private func getValue(webRecipe: WebRecipe) -> Value? {
        guard webRecipe.kcal != nil && webRecipe.carbohydrates != nil &&
                webRecipe.protein != nil && webRecipe.fat != nil else {

            return nil
        }
        
        return Value(kcal: intToDouble(intValue: webRecipe.kcal),
                     netCarbs: intToDouble(intValue: webRecipe.carbohydrates),
                     proteins: intToDouble(intValue: webRecipe.protein),
                     fats: intToDouble(intValue: webRecipe.fat))
    }
    
    private func intToDouble(intValue: Int?) -> Double? {
        if let intValue {
            return Double(intValue)
        }
        return nil
    }
    
    private func getProduct(title: String) -> NetworkProductModel {
        return NetworkProductModel(
            id: UUID().integer,
            title: title,
            productTypeId: 2,
            marketCategory: MarketCategory(id: UUID().integer,
                                           title: R.string.localizable.other()),
            units: [],
            photo: "",
            marketUnit: nil,
            localImage: nil,
            store: nil,
            cost: nil
        )
    }
}
