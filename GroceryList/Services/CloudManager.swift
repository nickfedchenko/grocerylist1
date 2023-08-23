//
//  CloudManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 17.08.2023.
//

import CloudKit
import UIKit

final class CloudManager {
    
    // TODO: перед релизом поменять на CKContainer.default().privateCloudDatabase
    static let privateCloudDataBase = CKContainer.default().publicCloudDatabase
    
    enum RecordType: String {
        case groceryListsModel = "GroceryListsModel"
        case product = "Product"
        case categoryModel = "CategoryModel"
        case store = "Store"
        
        case pantryModel = "PantryModel"
        case stock = "Stock"
        
        case collectionModel = "CollectionModel"
        case recipe = "Recipe"
        
        case settings = "Settings"
    }

    static func saveCloudData(recipe: Recipe) {
        let image = prepareImageToSaveToCloud(name: recipe.id.asString,
                                              imageData: recipe.localImage)
        if recipe.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.recipe.rawValue)
            record = fillInRecord(record: record, recipe: recipe, asset: image.asset)

            save(record: record, imageUrl: image.url) { recordID in
                var updateRecipe = recipe
                updateRecipe.recordId = recordID
                CoreDataManager.shared.saveRecipes(recipes: [updateRecipe])
            }
            return
        }
        
        let recordID = CKRecord.ID(recordName: recipe.recordId)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if var record {
                record = fillInRecord(record: record, recipe: recipe, asset: image.asset)
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: image.url) { _ in }
                }
            }
        }
    }
    
    private static func fillInRecord(record: CKRecord, recipe: Recipe, asset: CKAsset?) -> CKRecord {
        let record = record
        record.setValue(recipe.id, forKey: "id")
        record.setValue(recipe.title, forKey: "title")
        record.setValue(asset, forKey: "localImage")
        record.setValue(recipe.photo, forKey: "photo")
        record.setValue(recipe.description, forKey: "description")
        record.setValue(recipe.cookingTime, forKey: "cookingTime")
        record.setValue(recipe.totalServings, forKey: "totalServings")
        record.setValue(recipe.dishWeight, forKey: "dishWeight")
        record.setValue(recipe.dishWeightType, forKey: "dishWeightType")
        record.setValue(try? JSONEncoder().encode(recipe.values), forKey: "values")
        record.setValue(recipe.countries, forKey: "countries")
        record.setValue(recipe.instructions, forKey: "instructions")
        record.setValue(try? JSONEncoder().encode(recipe.ingredients), forKey: "ingredients")
        record.setValue(try? JSONEncoder().encode(recipe.eatingTags), forKey: "eatingTags")
        record.setValue(try? JSONEncoder().encode(recipe.dishTypeTags), forKey: "dishTypeTags")
        record.setValue(try? JSONEncoder().encode(recipe.processingTypeTags), forKey: "processingTypeTags")
        record.setValue(try? JSONEncoder().encode(recipe.additionalTags), forKey: "additionalTags")
        record.setValue(try? JSONEncoder().encode(recipe.dietTags), forKey: "dietTags")
        record.setValue(try? JSONEncoder().encode(recipe.exceptionTags), forKey: "exceptionTags")
        record.setValue(recipe.isDraft, forKey: "isDraft")
        record.setValue(recipe.createdAt, forKey: "createdAt")
        record.setValue(recipe.isDefaultRecipe, forKey: "isDefaultRecipe")
        record.setValue(recipe.sourceUrl, forKey: "sourceUrl")
        return record
    }
    
    static func saveCloudData(collectionModel: CollectionModel) {
        let image = prepareImageToSaveToCloud(name: collectionModel.id.asString,
                                              imageData: collectionModel.localImage)
        if collectionModel.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.collectionModel.rawValue)
            record = fillInRecord(record: record, collectionModel: collectionModel, asset: image.asset)
            
            save(record: record, imageUrl: image.url) { recordID in
                var updateCollectionModel = collectionModel
                updateCollectionModel.recordId = recordID
                CoreDataManager.shared.saveCollection(collections: [updateCollectionModel])
            }
            return
        }
        
        let recordID = CKRecord.ID(recordName: collectionModel.recordId)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if var record {
                record = fillInRecord(record: record, collectionModel: collectionModel, asset: image.asset)
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: image.url) { _ in }
                }
            }
        }
    }
    
    private static func fillInRecord(record: CKRecord, collectionModel: CollectionModel, asset: CKAsset?) -> CKRecord {
        let record = record
        record.setValue(collectionModel.id, forKey: "id")
        record.setValue(collectionModel.index, forKey: "index")
        record.setValue(collectionModel.title, forKey: "title")
        record.setValue(collectionModel.color, forKey: "color")
        record.setValue(collectionModel.isDefault, forKey: "isDefault")
        record.setValue(asset, forKey: "localImage")
        record.setValue(collectionModel.dishes, forKey: "dishes")
        record.setValue(collectionModel.isDeleteDefault, forKey: "isDeleteDefault")
        return record
    }
    
    // swiftlint:disable:next function_body_length
    static func fetchDataFromCloud(recordType: RecordType, sortKey: String, desiredKeys: [String],
                                   completion: @escaping ((Result<CKRecord, Error>) -> Void)) {
        let query = CKQuery(recordType: recordType.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: true)]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = desiredKeys
        queryOperation.resultsLimit = 10
        queryOperation.queuePriority = .veryHigh
        
        if #available(iOS 15.0, *) {
            queryOperation.recordMatchedBlock = { _, result in
                completion(result)
            }
        } else {
            queryOperation.recordFetchedBlock = { record in
                completion(.success(record))
            }
        }
        
        if #available(iOS 15.0, *) {
            queryOperation.queryResultBlock = { result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let cursor):
                    guard let cursor = cursor else {
                        return
                    }
                    let secondQueryOperation = CKQueryOperation(cursor: cursor)
                    secondQueryOperation.recordFetchedBlock = { record in
                        completion(.success(record))
                    }
                    
                    secondQueryOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                    privateCloudDataBase.add(secondQueryOperation)
                }
            }
        } else {
            queryOperation.queryCompletionBlock = { cursor, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
                guard let cursor = cursor else {
                    return
                }
                
                let secondQueryOperation = CKQueryOperation(cursor: cursor)
                secondQueryOperation.recordFetchedBlock = { record in
                    completion(.success(record))
                }
                
                secondQueryOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                privateCloudDataBase.add(secondQueryOperation)
            }
        }
        
        privateCloudDataBase.add(queryOperation)
    }
    
    static func save(record: CKRecord, imageUrl: URL? = nil,
                     completion: @escaping ((String) -> Void)) {
        privateCloudDataBase.save(record) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if let record {
                completion(record.recordID.recordName)
            }
            deleteTempImage(imageUrl: imageUrl)
        }
    }
    
    static func delete(recordType: RecordType, recordID: String) {
        guard !recordID.isEmpty else {
            return
        }
        let query = CKQuery(recordType: recordType.rawValue, predicate: NSPredicate(value: true))
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["recordId"]
        queryOperation.queuePriority = .veryHigh
        
        queryOperation.recordFetchedBlock = { record in
            if record.recordID.recordName == recordID {
                privateCloudDataBase.delete(withRecordID: record.recordID, completionHandler: { (_, error) in
                    if let error {
                        print(error.localizedDescription)
                        return
                    }
                })
            }
            
            queryOperation.queryCompletionBlock = { _, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        
        privateCloudDataBase.add(queryOperation)
    }
    
    static func prepareImageToSaveToCloud(name: String, imageData: Data?) -> (asset: CKAsset?, url: URL?) {
        guard let imageData else {
            return (nil, nil)
        }
        let scaleImage = UIImage(data: imageData)
        let imageFilePath = NSTemporaryDirectory() + name
        let imageUrl = URL(fileURLWithPath: imageFilePath)
        
        guard let dataToPath = scaleImage?.jpegData(compressionQuality: 1) else {
            return (nil, nil)
        }
        
        do {
            try dataToPath.write(to: imageUrl, options:  .atomic)
        } catch {
            print(error.localizedDescription)
        }
        
        let imageAsset = CKAsset(fileURL: imageUrl)
        return (imageAsset, imageUrl)
    }
    
    static func deleteTempImage(imageUrl: URL?) {
        guard let imageUrl else {
            return
        }
        do {
            try FileManager.default.removeItem(at: imageUrl)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func getImageData(image: Any?) -> Data? {
        guard let imageAsset = image as? CKAsset,
              let url = imageAsset.fileURL,
              let imageData = try? Data(contentsOf: url) else {
            return nil
        }
        return imageData
    }
}
