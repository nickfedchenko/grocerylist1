//
//  RecipesListViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.06.2023.
//

import UIKit
import Kingfisher

class RecipesListViewModel {
    
    weak var router: RootRouter?
    var updatePhoto: ((UIImage) -> Void)?
    
    private var section: RecipeSectionsModel
    private var colorManager = ColorManager()
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
    
    func showPhotosFromRecipe() {
        router?.goToPhotosFromRecipe(allPhotos: allPhotos, collectionId: section.collectionId,
                                     updateUI: { [weak self] image in
            self?.updatePhoto?(image)
        })
    }
    
    func addToShoppingList() {
        
    }
    
    func addToFavorites() {
        
    }
    
    func addToCollection() {
        
    }
    
    func edit() {
        
    }
 
    private func setAllPhotos() {
        DispatchQueue.global().async {
            self.section.recipes.forEach {
                if let imageData = $0.localImage, let image = UIImage(data: imageData) {
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
