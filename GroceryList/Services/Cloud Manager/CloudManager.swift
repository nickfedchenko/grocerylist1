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
    
    var router: RootRouter?
    let privateCloudDataBase = CKContainer.default().privateCloudDatabase
    let privateSubscriptionID = "private-changes"
    let zoneID = CKRecordZone.ID(zoneName: "GroceryList", ownerName: CKCurrentUserDefaultName)

    private let controller = SynchronizationViewController()
    private var groceryLists: [CKRecord] = []
    private var products: [CKRecord] = []
    private var categories: [CKRecord] = []
    private var stores: [CKRecord] = []
    private var pantries: [CKRecord] = []
    private var stocks: [CKRecord] = []
    private var collections: [CKRecord] = []
    private var recipes: [CKRecord] = []
    private let recordsQueue = DispatchQueue(label: "com.ksens.shopp.recordsQueue", attributes: .concurrent)

    private init() {
        enable()
    }
    
    func enable() {
        let enableGroup = DispatchGroup()
        if UserDefaultsManager.shared.isICloudDataBackupOn {
            createCustomZone(createZoneGroup: enableGroup)
            subscribingToChangeNotifications()
            
            enableGroup.notify(queue: DispatchQueue.global()) {
                if UserDefaultsManager.shared.createdCustomZone {
                    self.syncAllDataWithICloud()
                    self.fetchChanges(isShowSyncController: true)
                }
            }
        }
    }
    
    func fetchChanges(isShowSyncController: Bool = false) {
        var changedZoneIDs: [CKRecordZone.ID] = []
        let serverChangeToken = getToken(changeTokenKey: UserDefaultsManager.shared.databaseChangeTokenKey)
        let databaseOperation = CKFetchDatabaseChangesOperation(previousServerChangeToken: serverChangeToken)
        
        databaseOperation.recordZoneWithIDChangedBlock = { zoneID in
            changedZoneIDs.append(zoneID)
        }
        
        databaseOperation.recordZoneWithIDWasDeletedBlock = { zoneID in
            if zoneID.zoneName == self.zoneID.zoneName {
                self.iCloudBackupOff()
            }
        }
        
        databaseOperation.changeTokenUpdatedBlock = { token in
            let changeTokenData = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
            UserDefaultsManager.shared.databaseChangeTokenKey = changeTokenData
        }
        
        databaseOperation.fetchDatabaseChangesCompletionBlock = { token, _, error in
            if let error = error {
                print("[CloudKit]: ", error.localizedDescription)
                return
            }
            if !changedZoneIDs.isEmpty {
                self.presentSyncController(isShowSyncController: isShowSyncController)
                self.fetchZoneChanges(zoneIDs: changedZoneIDs) { [weak self] in
                    self?.saveRecords()
                    if let token {
                        let changeTokenData = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
                        UserDefaultsManager.shared.databaseChangeTokenKey = changeTokenData
                    }
                    self?.dismissSyncController(isShowSyncController: isShowSyncController)
                }
            }
        }
        
        databaseOperation.qualityOfService = .userInteractive
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
    
    func save(record: CKRecord, completion: @escaping ((String) -> Void)) {
        privateCloudDataBase.save(record) { returnedRecord, error in
            if let error {
                print("[CloudKit]: \(String(describing: record.recordType))", error.localizedDescription)
                return
            }
            if let returnedRecord {
                completion(returnedRecord.recordID.recordName)
            }
        }
    }
    
    func delete(recordType: RecordType, recordID: String) {
        guard UserDefaultsManager.shared.isICloudDataBackupOn else {
            return
        }
        guard !recordID.isEmpty else {
            return
        }
        let recordID = CKRecord.ID(recordName: recordID, zoneID: zoneID)
        self.privateCloudDataBase.delete(withRecordID: recordID, completionHandler: { (_, error) in
            if let error {
                print("[CloudKit]: ", error.localizedDescription)
                return
            }
        })
    }
    
    func convertDataToAsset(name: String, data: Data?) -> CKAsset? {
        guard let data,
              let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(name) else {
            return nil
        }
        
        do {
            try data.write(to: url)
        } catch {
            print(error.localizedDescription)
        }

        return CKAsset(fileURL: url)
    }
    
    func convertAssetToData(asset: Any?) -> Data? {
        guard let ckAsset = asset as? CKAsset,
              let url = ckAsset.fileURL,
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return data
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
            createZoneOperation.qualityOfService = .userInteractive
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
            modifySubscriptionsOperation.modifySubscriptionsCompletionBlock = { _, _, error in
                if let error {
                    print("[CloudKit]:", error.localizedDescription)
                } else {
                    UserDefaultsManager.shared.subscribedToPrivateChanges = true
                }
            }
            modifySubscriptionsOperation.qualityOfService = .userInteractive
            privateCloudDataBase.add(modifySubscriptionsOperation)
        }
    }
    
    private func fetchZoneChanges(zoneIDs: [CKRecordZone.ID], completion: @escaping (() -> Void)) {
        let serverChangeToken = getToken(changeTokenKey: UserDefaultsManager.shared.zoneChangeTokenKey)
        var configurations = [CKRecordZone.ID: CKFetchRecordZoneChangesOperation.ZoneConfiguration]()
        for zoneID in zoneIDs {
            let options = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
            options.previousServerChangeToken = serverChangeToken
            configurations[zoneID] = options
        }
        let zoneOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: zoneIDs, configurationsByRecordZoneID: configurations)
        
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
                return
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
            completion()
        }
        zoneOperation.qualityOfService = .userInteractive
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
    
    private func updateData(by record: CKRecord) {
        DispatchQueue.global(qos: .background).async {
            guard let recordType = RecordType(rawValue: record.recordType) else {
                return
            }
            self.recordsQueue.async(flags: .barrier) {
                switch recordType {
                case .groceryListsModel:   self.groceryLists.append(record)
                case .product:             self.products.append(record)
                case .categoryModel:       self.categories.append(record)
                case .store:               self.stores.append(record)
                case .pantryModel:         self.pantries.append(record)
                case .stock:               self.stocks.append(record)
                case .collectionModel:     self.collections.append(record)
                case .recipe:              self.recipes.append(record)
                case .settings:            self.setupSettings(record: record)
                }
            }
        }
    }
    
    private func saveRecords() {
        groceryLists.forEach { setupGroceryList(record: $0) }
        products.forEach { setupProduct(record: $0) }
        categories.forEach { setupCategory(record: $0) }
        stores.forEach { setupStore(record: $0) }
        
        let pantries = pantries.compactMap { record in
            let imageData = self.convertAssetToData(asset: record.value(forKey: "icon"))
            return PantryModel(record: record, imageData: imageData)
        }
        CoreDataManager.shared.savePantry(pantry: pantries)
        
        let collections = collections.compactMap { record in
            let imageData = self.convertAssetToData(asset: record.value(forKey: "localImage"))
            return CollectionModel(record: record, imageData: imageData)
        }
        CoreDataManager.shared.saveCollection(collections: collections)

        let recipes = recipes.compactMap { record in
            let imageData = self.convertAssetToData(asset: record.value(forKey: "localImage"))
            let ingredients = self.convertAssetToData(asset: record.value(forKey: "ingredients"))
            return Recipe(record: record, imageData: imageData, ingredientsData: ingredients)
        }
        CoreDataManager.shared.saveRecipes(recipes: recipes)
        
        if !collections.isEmpty || !recipes.isEmpty {
            NotificationCenter.default.post(name: .cloudCollection, object: nil)
            NotificationCenter.default.post(name: .cloudRecipe, object: nil)
        }
        
        setupStock()
    }
    
    private func setupGroceryList(record: CKRecord) {
        if let groceryList = GroceryListsModel(record: record) {
            CoreDataManager.shared.saveList(list: groceryList)
            NotificationCenter.default.post(name: .cloudList, object: nil)
        }
    }
    
    private func setupProduct(record: CKRecord) {
        let imageData = self.convertAssetToData(asset: record.value(forKey: "imageData"))
        if let product = Product(record: record, imageData: imageData) {
            CoreDataManager.shared.createProduct(product: product)
            NotificationCenter.default.post(name: .cloudProducts, object: nil)
        }
    }
    
    private func setupCategory(record: CKRecord) {
        if let category = CategoryModel(record: record) {
            CoreDataManager.shared.saveCategory(category: category)
        }
    }
    
    private func setupStore(record: CKRecord) {
        if let store = Store(record: record) {
            CoreDataManager.shared.saveStore(store)
        }
    }
    
    private func setupStock() {
        if stocks.isEmpty { return }
        let stocksFromCloud = stocks.compactMap { record in
            let imageData = self.convertAssetToData(asset: record.value(forKey: "imageData"))
            return Stock(record: record, imageData: imageData)
        }
        let stocksFromDB = CoreDataManager.shared.getAllStock()?.compactMap({ Stock(dbModel: $0) }) ?? []
        for stockDB in stocksFromDB where stockDB.isDefault {
            stocksFromCloud.forEach { stockFromCloud in
                if stockDB.isEqual(to: stockFromCloud) {
                    CoreDataManager.shared.deleteStock(by: stockDB.id)
                }
            }
        }
        
        let stocksDistributedByPantries = Dictionary(grouping: stocksFromCloud, by: \.pantryId)
        stocksDistributedByPantries.forEach { pantryId, stocks in
            self.recordsQueue.async(flags: .barrier) {
                CoreDataManager.shared.saveStock(stocks: stocks, for: pantryId.uuidString)
            }
        }
    }
    
    private func setupSettings(record: CKRecord) {
        UserDefaultsManager.shared.isMetricSystem = (record.value(forKey: "isMetricSystem") as? Int64 ?? 0).boolValue
        UserDefaultsManager.shared.isHapticOn = (record.value(forKey: "isHapticOn") as? Int64 ?? 0).boolValue
        UserDefaultsManager.shared.isShowImage = (record.value(forKey: "isShowImage") as? Int64 ?? 0).boolValue
        UserDefaultsManager.shared.isActiveAutoCategory = (record.value(forKey: "isActiveAutoCategory") as? Int64 ?? 0).boolValue
        UserDefaultsManager.shared.recipeIsFolderView = (record.value(forKey: "recipeIsFolderView") as? Int64 ?? 0).boolValue
        UserDefaultsManager.shared.recipeIsTableView = (record.value(forKey: "recipeIsTableView") as? Int64 ?? 0).boolValue
        UserDefaultsManager.shared.favoritesRecipeIds = record.value(forKey: "favoritesRecipeIds") as? [Int] ?? []
    }
    
    private func deleteData(recordId: CKRecord.ID, recordType: CKRecord.RecordType) {
        DispatchQueue.global(qos: .background).async {
            guard let recordType = RecordType(rawValue: recordType) else {
                return
            }
            let coreData = CoreDataManager.shared
            self.recordsQueue.async(flags: .barrier) {
                switch recordType {
                case .groceryListsModel:    coreData.removeList(recordId: recordId.recordName)
                case .product:              coreData.removeProduct(recordId: recordId.recordName)
                case .categoryModel:        coreData.removeCategory(recordId: recordId.recordName)
                case .store:                coreData.removeStore(recordId: recordId.recordName)
                case .pantryModel:          coreData.removePantryList(recordId: recordId.recordName)
                case .stock:                coreData.removeStock(recordId: recordId.recordName)
                case .collectionModel:      coreData.removeCollection(recordId: recordId.recordName)
                case .recipe:               coreData.removeRecipe(recordId: recordId.recordName)
                case .settings:             break
                }
            }
        }
    }
    
    private func iCloudBackupOff() {
        UserDefaultsManager.shared.isICloudDataBackupOn = false
        UserDefaultsManager.shared.createdCustomZone = false
        UserDefaultsManager.shared.subscribedToPrivateChanges = false
        CoreDataManager.shared.resetRecordIdForAllData()
    }
}

extension CloudManager {
    private func syncAllDataWithICloud() {
        if UserDefaultsManager.shared.settingsRecordId.isEmpty {
            saveCloudSettings()
        }
        
        saveCloudAllGroceryLists()
        saveCloudAllPantryLists()
        
        let collections = CoreDataManager.shared.getAllCollection()?.compactMap({
            ($0.recordId?.isEmpty ?? true) ? CollectionModel(from: $0) : nil
        }) ?? []
        collections.forEach { saveCloudData(collectionModel: $0) }
        
        let recipes = CoreDataManager.shared.getAllRecipes()?.compactMap({
            $0.isDefaultRecipe ? nil : ($0.recordId?.isEmpty ?? true) ? Recipe(from: $0) : nil
        }) ?? []
        recipes.forEach { saveCloudData(recipe: $0) }
    }
    
    private func saveCloudAllGroceryLists() {
        let groceryLists = CoreDataManager.shared.getAllLists()?.compactMap({
            ($0.recordId?.isEmpty ?? true) ? GroceryListsModel(from: $0) : nil
        }) ?? []
        groceryLists.forEach {
            if $0.isShared {
                if $0.isSharedListOwner {
                    saveCloudData(groceryList: $0)
                }
            } else {
                saveCloudData(groceryList: $0)
            }
        }
        
        let products = CoreDataManager.shared.getAllProducts()?.compactMap({
            ($0.recordId?.isEmpty ?? true) ? Product(from: $0) : nil
        }) ?? []
        products.forEach { saveCloudData(product: $0) }
        
        let categories = CoreDataManager.shared.getUserCategories()?.compactMap({
            ($0.recordId?.isEmpty ?? true) ? CategoryModel(from: $0) : nil
        }) ?? []
        categories.forEach { saveCloudData(category: $0) }
        
        let stores = CoreDataManager.shared.getAllStores()?.compactMap({
            ($0.recordId?.isEmpty ?? true) ? Store(from: $0) : nil
        }) ?? []
        stores.forEach { saveCloudData(store: $0) }
    }
    
    private func saveCloudAllPantryLists() {
        let pantries = CoreDataManager.shared.getAllPantries()?.compactMap({
            ($0.recordId?.isEmpty ?? true) ? PantryModel(dbModel: $0) : nil
        }) ?? []
        pantries.forEach {
            if $0.isShared {
                if $0.isSharedListOwner {
                    saveCloudData(pantryModel: $0)
                }
            } else {
                saveCloudData(pantryModel: $0)
            }
        }
        
        let stocks = CoreDataManager.shared.getAllStock()?.compactMap({
            $0.isDefault ? nil : ($0.recordId?.isEmpty ?? true) ? Stock(dbModel: $0) : nil
        }) ?? []
        stocks.forEach { saveCloudData(stock: $0) }
    }
}

extension CloudManager {
    private func presentSyncController(isShowSyncController: Bool) {
        guard isShowSyncController else {
            return
        }
        DispatchQueue.main.async {
            self.controller.loadingIndicator(isVisible: true)
            self.controller.modalTransitionStyle = .crossDissolve
            self.controller.modalPresentationStyle = .overCurrentContext
            self.router?.topViewController?.present(self.controller, animated: true, completion: nil)
        }
    }
    
    private func dismissSyncController(isShowSyncController: Bool) {
        guard isShowSyncController else {
            return
        }
        DispatchQueue.main.async {
            self.controller.loadingIndicator(isVisible: false)
            self.controller.dismiss(animated: true)
        }
    }
}
