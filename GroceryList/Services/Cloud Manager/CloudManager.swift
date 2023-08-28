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
        let createZoneGroup = DispatchGroup()
        enable(enableGroup: createZoneGroup)
    }
    
    func enable(enableGroup: DispatchGroup) {
        if UserDefaultsManager.shared.isICloudDataBackupOn {
            createCustomZone(createZoneGroup: enableGroup)
            subscribingToChangeNotifications()

            enableGroup.notify(queue: DispatchQueue.global()) {
                if UserDefaultsManager.shared.createdCustomZone {
                    self.fetchChanges()
                }
            }
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
                print("[CloudKit]:", error.localizedDescription)
            }
            if !changedZoneIDs.isEmpty {
                self.fetchZoneChanges(zoneIDs: changedZoneIDs)
            }
            if let token {
                let changeTokenData = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
                UserDefaultsManager.shared.databaseChangeTokenKey = changeTokenData
            }
        }
        
        databaseOperation.qualityOfService = .utility
        privateCloudDataBase.add(databaseOperation)
    }
    
    func getICloudStatus(completion: @escaping ((CKAccountStatus) -> Void)) {
        CKContainer.default().accountStatus { status, error in
            if let error {
                print("[CloudKit]:", error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
    
    func save(record: CKRecord, imageUrl: URL? = nil,
              completion: @escaping ((String) -> Void)) {
        privateCloudDataBase.save(record) { returnedRecord, error in
            if let error {
                print("[CloudKit]: \(String(describing: record.recordType))", error.localizedDescription)
                return
            }
            if let returnedRecord {
                completion(returnedRecord.recordID.recordName)
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
                        print("[CloudKit]:", error.localizedDescription)
                        return
                    }
                })
            }
            
            queryOperation.queryCompletionBlock = { _, error in
                if let error {
                    print("[CloudKit]:", error.localizedDescription)
                    return
                }
            }
        }
        
        privateCloudDataBase.add(queryOperation)
    }
    
    func prepareImageToSaveToCloud(name: String, imageData: Data?) -> (asset: CKAsset?, url: URL?) {
        guard let imageData,
              let image = UIImage(data: imageData) else {
            return (nil, nil)
        }
        let scale = image.size.width > 270 ? 270 / image.size.width : 1
        let scaleImage = UIImage(data: imageData, scale: scale)
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
    
    private func createCustomZone(createZoneGroup: DispatchGroup) {
        if !UserDefaultsManager.shared.createdCustomZone {
            createZoneGroup.enter()
            let customZone = CKRecordZone(zoneID: zoneID)
            let createZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [customZone], recordZoneIDsToDelete: [])
            createZoneOperation.modifyRecordZonesCompletionBlock = { _, _, error in
                if let error {
                    print("[CloudKit]: ", error.localizedDescription)
                } else {
                    UserDefaultsManager.shared.createdCustomZone = true
                }
                createZoneGroup.leave()
            }
            createZoneOperation.qualityOfService = .utility
            privateCloudDataBase.add(createZoneOperation)
        }
    }
    
    private func subscribingToChangeNotifications() {
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
                    print("[CloudKit]:", error.localizedDescription)
                } else {
                    UserDefaultsManager.shared.subscribedToPrivateChanges = true
                }
            }
            privateCloudDataBase.add(modifySubscriptionsOperation)
        }
    }
    
    private func fetchZoneChanges(zoneIDs: [CKRecordZone.ID]) {
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
                print("[CloudKit]:", error.localizedDescription)
            }
            if let changeToken {
                let changeTokenData = try? NSKeyedArchiver.archivedData(withRootObject: changeToken, requiringSecureCoding: true)
                UserDefaultsManager.shared.zoneChangeTokenKey = changeTokenData
            }
        }
        
        zoneOperation.fetchRecordZoneChangesCompletionBlock = { error in
            if let error {
                print("[CloudKit]:", error.localizedDescription)
            }
        }
        zoneOperation.qualityOfService = .utility
        privateCloudDataBase.add(zoneOperation)
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
