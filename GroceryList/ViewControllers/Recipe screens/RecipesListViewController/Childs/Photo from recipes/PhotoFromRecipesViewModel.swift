//
//  PhotoFromRecipesViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.06.2023.
//

import UIKit

final class PhotoFromRecipesViewModel {
    
    private let collectionId: Int
    private let photos: [UIImage]
    
    var updateUI: ((UIImage) -> Void)?
    
    init(photos: [UIImage], collectionId: Int) {
        self.photos = photos
        self.collectionId = collectionId
    }
    
    var photosCount: Int {
        photos.count
    }
    
    func getPhoto(by index: IndexPath) -> UIImage {
        photos[index.item]
    }
    
    func savePhoto(image: UIImage?) {
        guard let image else {
            return
        }
        
        guard let dbCollection = CoreDataManager.shared.getCollection(by: collectionId) else {
            return
        }
        var collection = CollectionModel(from: dbCollection)
        collection.localImage = image.pngData()
        CoreDataManager.shared.saveCollection(collections: [collection])
        CloudManager.saveCloudData(collectionModel: collection)
        updateUI?(image)
    }
}
