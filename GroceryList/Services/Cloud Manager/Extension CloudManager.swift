//
//  Extension CloudManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.08.2023.
//

import CloudKit
import Foundation

// MARK: save/update Data
extension CloudManager {
    // swiftlint:disable: cyclomatic_complexity
    // swiftlint:disable:next function_body_length
    func updateData(by record: CKRecord) {
        guard let recordType = RecordType(rawValue: record.recordType) else {
            return
        }
        
        switch recordType {
        case .groceryListsModel:
            if let groceryList = GroceryListsModel(record: record) {
                CoreDataManager.shared.saveList(list: groceryList)
                NotificationCenter.default.post(name: .cloudList, object: nil)
            }
        case .product:
            let imageData = self.getImageData(image: record.value(forKey: "imageData"))
            if let product = Product(record: record, imageData: imageData) {
                CoreDataManager.shared.createProduct(product: product)
                NotificationCenter.default.post(name: .cloudProducts, object: nil)
            }
        case .categoryModel:
            if let category = CategoryModel(record: record) {
                CoreDataManager.shared.saveCategory(category: category)
            }
        case .store:
            if let store = Store(record: record) {
                CoreDataManager.shared.saveStore(store)
            }
        case .pantryModel:
            let imageData = self.getImageData(image: record.value(forKey: "icon"))
            if let pantry = PantryModel(record: record, imageData: imageData) {
                CoreDataManager.shared.savePantry(pantry: [pantry])
                NotificationCenter.default.post(name: .cloudPantry, object: nil)
            }
        case .stock:
            let imageData = self.getImageData(image: record.value(forKey: "imageData"))
            if let stock = Stock(record: record, imageData: imageData) {
                CoreDataManager.shared.saveStock(stock: [stock], for: stock.pantryId.uuidString)
                NotificationCenter.default.post(name: .cloudStock, object: nil)
            }
        case .collectionModel:
            let imageData = self.getImageData(image: record.value(forKey: "localImage"))
            if let collection = CollectionModel(record: record, imageData: imageData) {
                CoreDataManager.shared.saveCollection(collections: [collection])
                NotificationCenter.default.post(name: .cloudCollection, object: nil)
            }
        case .recipe:
            let imageData = self.getImageData(image: record.value(forKey: "icon"))
            if let recipe = Recipe(record: record, imageData: imageData) {
                CoreDataManager.shared.saveRecipes(recipes: [recipe])
                NotificationCenter.default.post(name: .cloudRecipe, object: nil)
            }
        case .settings:
            UserDefaultsManager.shared.isMetricSystem = record.value(forKey: "isMetricSystem") as? Bool ?? false
            UserDefaultsManager.shared.isHapticOn = record.value(forKey: "isHapticOn") as? Bool ?? false
            UserDefaultsManager.shared.isShowImage = record.value(forKey: "isShowImage") as? Bool ?? false
            UserDefaultsManager.shared.isActiveAutoCategory = record.value(forKey: "isActiveAutoCategory") as? Bool ?? false
            UserDefaultsManager.shared.recipeIsFolderView = record.value(forKey: "recipeIsFolderView") as? Bool ?? false
            UserDefaultsManager.shared.recipeIsTableView = record.value(forKey: "recipeIsTableView") as? Bool ?? false
            UserDefaultsManager.shared.userTokens = record.value(forKey: "userTokens") as? [String] ?? []
            UserDefaultsManager.shared.pantryUserTokens = record.value(forKey: "pantryUserTokens") as? [String] ?? []
            UserDefaultsManager.shared.favoritesRecipeIds = record.value(forKey: "favoritesRecipeIds") as? [Int] ?? []
        }
    }
}

extension CloudManager {
    func saveCloudAllData() {
        saveCloudSettings()
        
        let groceryLists = CoreDataManager.shared.getAllLists()?.compactMap({ GroceryListsModel(from: $0) }) ?? []
        groceryLists.forEach { saveCloudData(groceryList: $0) }
        
        let products = CoreDataManager.shared.getAllProducts()?.compactMap({ Product(from: $0) }) ?? []
        products.forEach { saveCloudData(product: $0) }
        
        let categories = CoreDataManager.shared.getUserCategories()?.compactMap({ CategoryModel(from: $0) }) ?? []
        categories.forEach { saveCloudData(category: $0) }
        
        let stores = CoreDataManager.shared.getAllStores()?.compactMap({ Store(from: $0) }) ?? []
        stores.forEach { saveCloudData(store: $0) }
        
        let pantries = CoreDataManager.shared.getAllPantries()?.compactMap({ PantryModel(dbModel: $0) }) ?? []
        pantries.forEach { saveCloudData(pantryModel: $0) }
        
        let stocks = CoreDataManager.shared.getAllStock()?.compactMap({ Stock(dbModel: $0) }) ?? []
        stocks.forEach { saveCloudData(stock: $0) }
        
        let collections = CoreDataManager.shared.getAllCollection()?.compactMap({ CollectionModel(from: $0) }) ?? []
        collections.forEach { saveCloudData(collectionModel: $0) }
        
        let recipes = CoreDataManager.shared.getAllRecipes()?.compactMap({ $0.isDefaultRecipe ? nil : Recipe(from: $0) }) ?? []
        recipes.forEach { saveCloudData(recipe: $0) }
    }
    
    func saveCloudData(groceryList: GroceryListsModel) {
        guard UserDefaultsManager.shared.isICloudDataBackupOn else {
            return
        }
        var groceryList = groceryList
        if let dbList = CoreDataManager.shared.getList(list: groceryList.id.uuidString),
           let list = GroceryListsModel(from: dbList) {
            groceryList = list
        }
        
        if groceryList.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.groceryListsModel.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, groceryList: groceryList)
            
            save(record: record) { recordID in
                var updateGroceryList = groceryList
                updateGroceryList.recordId = recordID
                CoreDataManager.shared.saveList(list: updateGroceryList)
            }
            return
        }
        
        let recordID = CKRecord.ID(recordName: groceryList.recordId, zoneID: zoneID)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print("[CloudKit]:", error.localizedDescription)
                return
            }
            if var record {
                record = self.fillInRecord(record: record, groceryList: groceryList)
                
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: nil) { _ in }
                }
            }
        }
    }
    
    private func fillInRecord(record: CKRecord, groceryList: GroceryListsModel) -> CKRecord {
        let record = record
        let products = groceryList.products.compactMap { try? JSONEncoder().encode($0) }
        record.setValue(groceryList.id.uuidString, forKey: "id")
        record.setValue(groceryList.name, forKey: "name")
        record.setValue(groceryList.dateOfCreation, forKey: "dateOfCreation")
        record.setValue(groceryList.isFavorite, forKey: "isFavorite")
        record.setValue(groceryList.color, forKey: "color")
        record.setValue(products, forKey: "products")
        record.setValue(groceryList.typeOfSorting, forKey: "typeOfSorting")
        record.setValue(groceryList.isShared, forKey: "isShared")
        record.setValue(groceryList.sharedId, forKey: "sharedId")
        record.setValue(groceryList.isSharedListOwner, forKey: "isSharedListOwner")
        record.setValue(groceryList.isShowImage.rawValue, forKey: "isShowImage")
        record.setValue(groceryList.isVisibleCost, forKey: "isVisibleCost")
        record.setValue(groceryList.typeOfSortingPurchased, forKey: "typeOfSortingPurchased")
        record.setValue(groceryList.isAscendingOrder, forKey: "isAscendingOrder")
        record.setValue(groceryList.isAscendingOrderPurchased.rawValue, forKey: "isAscendingOrderPurchased")
        record.setValue(groceryList.isAutomaticCategory, forKey: "isAutomaticCategory")
        return record
    }
    
    func saveCloudData(product: Product) {
        guard UserDefaultsManager.shared.isICloudDataBackupOn else {
            return
        }

        let image = prepareImageToSaveToCloud(name: product.id.uuidString,
                                              imageData: product.imageData)
        if product.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.product.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, product: product, asset: image.asset)
            
            save(record: record, imageUrl: image.url) { recordID in
                var updateProduct = product
                updateProduct.recordId = recordID
                CoreDataManager.shared.createProduct(product: updateProduct)
            }
            return
        }
        
        let recordID = CKRecord.ID(recordName: product.recordId, zoneID: zoneID)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print("[CloudKit]:", error.localizedDescription)
                return
            }
            if var record {
                record = self.fillInRecord(record: record, product: product, asset: image.asset)
                
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: image.url) { _ in }
                }
            }
        }
    }
    
    private func fillInRecord(record: CKRecord, product: Product, asset: CKAsset?) -> CKRecord {
        let record = record
        record.setValue(product.id.uuidString, forKey: "id")
        record.setValue(product.listId.uuidString, forKey: "listId")
        record.setValue(product.dateOfCreation, forKey: "dateOfCreation")
        record.setValue(product.name, forKey: "name")
        record.setValue(product.description, forKey: "description")
        record.setValue(asset, forKey: "imageData")
        record.setValue(product.category, forKey: "category")
        record.setValue(product.isFavorite, forKey: "isFavorite")
        record.setValue(product.isPurchased, forKey: "isPurchased")
        record.setValue(product.fromRecipeTitle, forKey: "fromRecipeTitle")
        record.setValue(product.unitId?.rawValue, forKey: "unitId")
        record.setValue(product.isUserImage, forKey: "isUserImage")
        record.setValue(product.userToken, forKey: "userToken")
        record.setValue(try? JSONEncoder().encode(product.store), forKey: "store")
        record.setValue(product.cost, forKey: "cost")
        record.setValue(product.quantity, forKey: "quantity")
        return record
    }
    
    func saveCloudData(category: CategoryModel) {
        guard UserDefaultsManager.shared.isICloudDataBackupOn else {
            return
        }

        if category.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.categoryModel.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, category: category)
            
            save(record: record) { recordID in
                var updateCategory = category
                updateCategory.recordId = recordID
                CoreDataManager.shared.saveCategory(category: updateCategory)
            }
            return
        }
        
        let recordID = CKRecord.ID(recordName: category.recordId, zoneID: zoneID)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print("[CloudKit]:", error.localizedDescription)
                return
            }
            if var record {
                record = self.fillInRecord(record: record, category: category)
                
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: nil) { _ in }
                }
            }
        }
    }
    
    private func fillInRecord(record: CKRecord, category: CategoryModel) -> CKRecord {
        let record = record
        record.setValue(category.ind, forKey: "ind")
        record.setValue(category.name, forKey: "name")
        return record
    }
    
    func saveCloudData(store: Store) {
        guard UserDefaultsManager.shared.isICloudDataBackupOn else {
            return
        }

        if store.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.store.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, store: store)
            
            save(record: record) { recordID in
                var updateStore = store
                updateStore.recordId = recordID
                CoreDataManager.shared.saveStore(updateStore)
            }
            return
        }
        
        let recordID = CKRecord.ID(recordName: store.recordId, zoneID: zoneID)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print("[CloudKit]:", error.localizedDescription)
                return
            }
            if var record {
                record = self.fillInRecord(record: record, store: store)
                
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: nil) { _ in }
                }
            }
        }
    }
    
    private func fillInRecord(record: CKRecord, store: Store) -> CKRecord {
        let record = record
        record.setValue(store.id.uuidString, forKey: "id")
        record.setValue(store.title, forKey: "title")
        record.setValue(store.createdAt, forKey: "createdAt")
        return record
    }
    
    func saveCloudData(pantryModel: PantryModel) {
        guard UserDefaultsManager.shared.isICloudDataBackupOn else {
            return
        }

        let image = prepareImageToSaveToCloud(name: pantryModel.id.uuidString,
                                              imageData: pantryModel.icon)
        if pantryModel.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.pantryModel.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, pantryModel: pantryModel, asset: image.asset)
            
            save(record: record, imageUrl: image.url) { recordID in
                var updatePantryModel = pantryModel
                updatePantryModel.recordId = recordID
                CoreDataManager.shared.savePantry(pantry: [updatePantryModel])
            }
            return
        }

        let recordID = CKRecord.ID(recordName: pantryModel.recordId, zoneID: zoneID)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print("[CloudKit]:", error.localizedDescription)
                return
            }
            if var record {
                record = self.fillInRecord(record: record, pantryModel: pantryModel, asset: image.asset)
                
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: image.url) { _ in }
                }
            }
        }
    }
    
    private func fillInRecord(record: CKRecord, pantryModel: PantryModel, asset: CKAsset?) -> CKRecord {
        let record = record
        record.setValue(pantryModel.id.uuidString, forKey: "id")
        record.setValue(pantryModel.name, forKey: "name")
        record.setValue(pantryModel.index, forKey: "index")
        record.setValue(pantryModel.color, forKey: "color")
        record.setValue(asset, forKey: "icon")
        record.setValue(try? JSONEncoder().encode(pantryModel.stock), forKey: "stock")
        record.setValue(try? JSONEncoder().encode(pantryModel.synchronizedLists), forKey: "synchronizedLists")
        record.setValue(pantryModel.dateOfCreation, forKey: "dateOfCreation")
        record.setValue(pantryModel.sharedId, forKey: "sharedId")
        record.setValue(pantryModel.isShared, forKey: "isShared")
        record.setValue(pantryModel.isSharedListOwner, forKey: "isSharedListOwner")
        return record
    }
    
    func saveCloudData(stock: Stock) {
        guard UserDefaultsManager.shared.isICloudDataBackupOn else {
            return
        }

        let image = prepareImageToSaveToCloud(name: stock.id.uuidString,
                                              imageData: stock.imageData)
        if stock.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.stock.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, stock: stock, asset: image.asset)
            
            save(record: record, imageUrl: image.url) { recordID in
                var updateStock = stock
                updateStock.recordId = recordID
                CoreDataManager.shared.saveStock(stock: [updateStock], for: stock.pantryId.uuidString)
            }
            return
        }
        
        let recordID = CKRecord.ID(recordName: stock.recordId, zoneID: zoneID)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print("[CloudKit]:", error.localizedDescription)
                return
            }
            if var record {
                record = self.fillInRecord(record: record, stock: stock, asset: image.asset)
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: image.url) { _ in }
                }
            }
        }
    }
    
    private func fillInRecord(record: CKRecord, stock: Stock, asset: CKAsset?) -> CKRecord {
        let record = record
        record.setValue(stock.id.uuidString, forKey: "id")
        record.setValue(stock.index, forKey: "index")
        record.setValue(stock.pantryId.uuidString, forKey: "pantryId")
        record.setValue(stock.name, forKey: "name")
        record.setValue(stock.description, forKey: "description")
        record.setValue(asset, forKey: "imageData")
        record.setValue(stock.category, forKey: "category")
        record.setValue(try? JSONEncoder().encode(stock.store), forKey: "store")
        record.setValue(stock.cost, forKey: "cost")
        record.setValue(stock.quantity, forKey: "quantity")
        record.setValue(stock.unitId?.rawValue, forKey: "unitId")
        record.setValue(stock.isAvailability, forKey: "isAvailability")
        record.setValue(stock.isAutoRepeat, forKey: "isAutoRepeat")
        record.setValue(stock.autoRepeat, forKey: "autoRepeat")
        record.setValue(stock.isReminder, forKey: "isReminder")
        record.setValue(stock.dateOfCreation, forKey: "dateOfCreation")
        record.setValue(stock.isUserImage, forKey: "isUserImage")
        record.setValue(stock.userToken, forKey: "userToken")
        record.setValue(stock.isVisibleCost, forKey: "isVisibleCost")
        return record
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
                print("[CloudKit]:", error.localizedDescription)
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
//        record.setValue(try? JSONEncoder().encode(recipe.ingredients), forKey: "ingredients")
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
                print("[CloudKit]:", error.localizedDescription)
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
    
    func saveCloudSettings() {
        guard UserDefaultsManager.shared.isICloudDataBackupOn else {
            return
        }

        if UserDefaultsManager.shared.settingsRecordId.isEmpty {
            var record = CKRecord(recordType: RecordType.settings.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecordSettings(record: record)
        
            save(record: record) { recordID in
                UserDefaultsManager.shared.settingsRecordId = recordID
            }
            return
        }
        
        let recordID = CKRecord.ID(recordName: UserDefaultsManager.shared.settingsRecordId, zoneID: zoneID)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print("[CloudKit]:", error.localizedDescription)
                return
            }
            if var record {
                record = self.fillInRecordSettings(record: record)
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: nil) { _ in }
                }
            }
        }
    }
    
    private func fillInRecordSettings(record: CKRecord) -> CKRecord {
        let record = record
        record.setValue(UserDefaultsManager.shared.isMetricSystem, forKey: "isMetricSystem")
        record.setValue(UserDefaultsManager.shared.isHapticOn, forKey: "isHapticOn")
        record.setValue(UserDefaultsManager.shared.userTokens, forKey: "userTokens")
        record.setValue(UserDefaultsManager.shared.isShowImage, forKey: "isShowImage")
        record.setValue(UserDefaultsManager.shared.isActiveAutoCategory, forKey: "isActiveAutoCategory")
        record.setValue(UserDefaultsManager.shared.pantryUserTokens, forKey: "pantryUserTokens")
        record.setValue(UserDefaultsManager.shared.recipeIsFolderView, forKey: "recipeIsFolderView")
        record.setValue(UserDefaultsManager.shared.recipeIsTableView, forKey: "recipeIsTableView")
        let favoritesRecipeIds = UserDefaultsManager.shared.favoritesRecipeIds
        record.setValue(favoritesRecipeIds.isEmpty ? nil : favoritesRecipeIds , forKey: "favoritesRecipeIds")
        return record
    }
}

// MARK: delete Data
extension CloudManager {
    func deleteData(recordId: CKRecord.ID, recordType: CKRecord.RecordType) {
        guard let recordType = RecordType(rawValue: recordType) else {
            return
        }
        
        switch recordType {
        case .groceryListsModel:
            CoreDataManager.shared.removeList(recordId: recordId.recordName)
        case .product:
            CoreDataManager.shared.removeProduct(recordId: recordId.recordName)
        case .categoryModel:
            CoreDataManager.shared.removeCategory(recordId: recordId.recordName)
        case .store:
            CoreDataManager.shared.removeStore(recordId: recordId.recordName)
        case .pantryModel:
            CoreDataManager.shared.removePantryList(recordId: recordId.recordName)
        case .stock:
            CoreDataManager.shared.removeStock(recordId: recordId.recordName)
        case .collectionModel:
            CoreDataManager.shared.removeCollection(recordId: recordId.recordName)
        case .recipe:
            CoreDataManager.shared.removeRecipe(recordId: recordId.recordName)
        case .settings:
            break
        }
    }
}
