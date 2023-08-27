//
//  CloudManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 17.08.2023.
//

import CloudKit
import UIKit

final class CloudManager {
    static let shared = CloudManager()

    let privateCloudDataBase = CKContainer.default().privateCloudDatabase
    let privateSubscriptionID = "private-changes"
    let zoneID = CKRecordZone.ID(zoneName: "GroceryList", ownerName: CKCurrentUserDefaultName)
    
    enum RecordType: String, CaseIterable {
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
    
    private init() {
        enable()
    }
    
    func enable() {
        if UserDefaultsManager.shared.isICloudDataBackupOn {
            // https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitQuickStart/MaintainingaLocalCacheofCloudKitRecords/MaintainingaLocalCacheofCloudKitRecords.html#//apple_ref/doc/uid/TP40014987-CH12-SW7

            let createZoneGroup = DispatchGroup()
            createCustomZone(createZoneGroup: createZoneGroup)
            subscribingToChangeNotifications()
            
            createZoneGroup.notify(queue: DispatchQueue.global()) {
                if UserDefaultsManager.shared.createdCustomZone {
                    self.fetchChanges()
                }
            }
        }
    }
    
    func createCustomZone(createZoneGroup: DispatchGroup) {
        if !UserDefaultsManager.shared.createdCustomZone {
            createZoneGroup.enter()
            let customZone = CKRecordZone(zoneID: zoneID)
            let createZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [customZone], recordZoneIDsToDelete: [])
            createZoneOperation.modifyRecordZonesCompletionBlock = { _, _, error in
                if let error {
                    print("Error creating custom zone: \(error.localizedDescription)")
                } else {
                    UserDefaultsManager.shared.createdCustomZone = true
                }
                createZoneGroup.leave()
            }
            createZoneOperation.qualityOfService = .userInitiated
            privateCloudDataBase.add(createZoneOperation)
        }
    }
    
    func subscribingToChangeNotifications() {
        if !UserDefaultsManager.shared.subscribedToPrivateChanges {
            let subscription = CKDatabaseSubscription(subscriptionID: privateSubscriptionID)
            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            subscription.notificationInfo = notificationInfo
            
            let modifySubscriptionsOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription],
                                                                              subscriptionIDsToDelete: [])
            modifySubscriptionsOperation.qualityOfService = .utility
            modifySubscriptionsOperation.modifySubscriptionsCompletionBlock = { _, _, error in
                if let error {
                    print("Error creating subscription to private database: \(error.localizedDescription)")
                } else {
                    UserDefaultsManager.shared.subscribedToPrivateChanges = true
                }
            }
            privateCloudDataBase.add(modifySubscriptionsOperation)
        }
    }
    
    func fetchChanges() {
        var changedZoneIDs: [CKRecordZone.ID] = []
        var serverChangeToken = getToken(changeTokenKey: UserDefaultsManager.shared.databaseChangeTokenKey)
        let databaseOperation = CKFetchDatabaseChangesOperation(previousServerChangeToken: serverChangeToken)
        
        databaseOperation.recordZoneWithIDChangedBlock = { zoneID in
            changedZoneIDs.append(zoneID)
        }
        
        databaseOperation.changeTokenUpdatedBlock = { token in
            let changeTokenData = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
            UserDefaultsManager.shared.databaseChangeTokenKey = changeTokenData
        }
        
        databaseOperation.fetchDatabaseChangesCompletionBlock = { token, _, error in
            if let error = error {
                print("Error during fetch database changes operation", error.localizedDescription)
            }
            if let token {
                let changeTokenData = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
                UserDefaultsManager.shared.databaseChangeTokenKey = changeTokenData
            }
            if !changedZoneIDs.isEmpty {
                self.fetchZoneChanges(zoneIDs: changedZoneIDs)
            }
        }
        
        databaseOperation.qualityOfService = .userInitiated
        privateCloudDataBase.add(databaseOperation)
    }
    
    func fetchZoneChanges(zoneIDs: [CKRecordZone.ID]) {
        var serverChangeToken = getToken(changeTokenKey: UserDefaultsManager.shared.zoneChangeTokenKey)
        var configurations = [CKRecordZone.ID: CKFetchRecordZoneChangesOperation.ZoneConfiguration]()
        for zoneID in zoneIDs {
            let options = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
            options.previousServerChangeToken = serverChangeToken
            configurations[zoneID] = options
        }

        let zoneOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: zoneIDs,
                                                              configurationsByRecordZoneID: configurations)
        
        zoneOperation.recordChangedBlock = { record in
            self.updateData(by: record)
        }
        
        zoneOperation.recordWithIDWasDeletedBlock = { recordId, recordType in
            self.deleteData(recordId: recordId, recordType: recordType)
        }
        
        zoneOperation.recordZoneChangeTokensUpdatedBlock = { _, token, _ in
            if let token {
                let changeTokenData = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
                UserDefaultsManager.shared.zoneChangeTokenKey = changeTokenData
            }
        }
        
        zoneOperation.recordZoneFetchCompletionBlock = { (_, changeToken, _, _, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let changeToken {
                let changeTokenData = try? NSKeyedArchiver.archivedData(withRootObject: changeToken, requiringSecureCoding: true)
                UserDefaultsManager.shared.zoneChangeTokenKey = changeTokenData
            }
        }
        
        zoneOperation.fetchRecordZoneChangesCompletionBlock = { error in
            if let error {
                print(error.localizedDescription)
            }
        }
        zoneOperation.qualityOfService = .userInitiated
        privateCloudDataBase.add(zoneOperation)
    }
    
    func getICloudStatus(completion: @escaping ((CKAccountStatus) -> Void)) {
        CKContainer.default().accountStatus { status, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
    
    func saveCloudData(recipe: Recipe) {
        guard UserDefaultsManager.shared.isICloudDataBackupOn else {
            return
        }

        let image = prepareImageToSaveToCloud(name: recipe.id.asString,
                                              imageData: recipe.localImage)
        if recipe.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.recipe.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, recipe: recipe, asset: image.asset)

            save(record: record, imageUrl: image.url) { recordID in
                var updateRecipe = recipe
                updateRecipe.recordId = recordID
                CoreDataManager.shared.saveRecipes(recipes: [updateRecipe])
            }
            return
        }
        
        let recordID = CKRecord.ID(recordName: recipe.recordId, zoneID: zoneID)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if var record {
                record = self.fillInRecord(record: record, recipe: recipe, asset: image.asset)
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: image.url) { _ in }
                }
            }
        }
    }
    
    func fillInRecord(record: CKRecord, recipe: Recipe, asset: CKAsset?) -> CKRecord {
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
    
    func saveCloudData(collectionModel: CollectionModel) {
        guard UserDefaultsManager.shared.isICloudDataBackupOn else {
            return
        }

        let image = prepareImageToSaveToCloud(name: collectionModel.id.asString,
                                              imageData: collectionModel.localImage)
        if collectionModel.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.collectionModel.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, collectionModel: collectionModel, asset: image.asset)
            
            save(record: record, imageUrl: image.url) { recordID in
                var updateCollectionModel = collectionModel
                updateCollectionModel.recordId = recordID
                CoreDataManager.shared.saveCollection(collections: [updateCollectionModel])
            }
            return
        }
        
        let recordID = CKRecord.ID(recordName: collectionModel.recordId, zoneID: zoneID)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if var record {
                record = self.fillInRecord(record: record, collectionModel: collectionModel, asset: image.asset)
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: image.url) { _ in }
                }
            }
        }
    }
    
    private func fillInRecord(record: CKRecord, collectionModel: CollectionModel, asset: CKAsset?) -> CKRecord {
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
    func fetchDataFromCloud(recordType: RecordType, sortKey: String, desiredKeys: [String]? = nil,
                            completion: @escaping ((Result<CKRecord, Error>) -> Void)) {
        guard UserDefaultsManager.shared.isICloudDataBackupOn else {
            return
        }
        let query = CKQuery(recordType: recordType.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: true)]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.zoneID = zoneID
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
                    self.privateCloudDataBase.add(secondQueryOperation)
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
                self.privateCloudDataBase.add(secondQueryOperation)
            }
        }
        
        privateCloudDataBase.add(queryOperation)
    }
    
    func save(record: CKRecord, imageUrl: URL? = nil,
              completion: @escaping ((String) -> Void)) {
        privateCloudDataBase.save(record) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if let record {
                completion(record.recordID.recordName)
            }
            self.deleteTempImage(imageUrl: imageUrl)
        }
    }
    
    func delete(recordType: RecordType, recordID: String) {
        guard UserDefaultsManager.shared.isICloudDataBackupOn else {
            return
        }
        guard !recordID.isEmpty else {
            return
        }
        let query = CKQuery(recordType: recordType.rawValue, predicate: NSPredicate(value: true))
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.zoneID = zoneID
        queryOperation.desiredKeys = ["recordId"]
        queryOperation.queuePriority = .veryHigh
        
        queryOperation.recordFetchedBlock = { record in
            if record.recordID.recordName == recordID {
                self.privateCloudDataBase.delete(withRecordID: record.recordID, completionHandler: { (_, error) in
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
    
    func prepareImageToSaveToCloud(name: String, imageData: Data?) -> (asset: CKAsset?, url: URL?) {
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
    
    func deleteTempImage(imageUrl: URL?) {
        guard let imageUrl else {
            return
        }
        do {
            try FileManager.default.removeItem(at: imageUrl)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getImageData(image: Any?) -> Data? {
        guard let imageAsset = image as? CKAsset,
              let url = imageAsset.fileURL,
              let imageData = try? Data(contentsOf: url) else {
            return nil
        }
        return imageData
    }
    
    private func getToken(changeTokenKey: Data?) -> CKServerChangeToken? {
        var serverChangeToken: CKServerChangeToken?
        let changeTokenData = changeTokenKey
        if let changeTokenData {
            serverChangeToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: changeTokenData)
        }
        return serverChangeToken
    }
}
