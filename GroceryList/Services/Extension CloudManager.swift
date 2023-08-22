//
//  Extension CloudManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.08.2023.
//

import CloudKit
import Foundation

extension CloudManager {
    
    // MARK: fetch Data
    static func fetchGroceryListFromCloud() {
        let desiredKeys = ["recordId", "id", "sharedId", "dateOfCreation", "name", "color",
                           "isFavorite", "isShared"]
        fetchDataFromCloud(recordType: .groceryListsModel, sortKey: "dateOfCreation",
                           desiredKeys: desiredKeys) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let record):
                if let groceryList = GroceryListsModel(record: record) {
                    CoreDataManager.shared.saveList(list: groceryList)
                }
            }
        }
    }
    
    static func fetchProductFromCloud() {
        let desiredKeys = ["recordId", "id", "listId", "dateOfCreation", "description", "category",
                           "fromRecipeTitle", "unitId", "isFavorite", "isPurchased"]
        fetchDataFromCloud(recordType: .product, sortKey: "dateOfCreation",
                           desiredKeys: desiredKeys) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let record):
                let imageData = getImageData(image: record.value(forKey: "imageData"))
                if let product = Product(record: record, imageData: imageData) {
                    CoreDataManager.shared.createProduct(product: product)
                }
            }
        }
    }
    
    static func fetchCategoryFromCloud() {
        let desiredKeys = ["recordId", "ind", "name"]
        fetchDataFromCloud(recordType: .categoryModel, sortKey: "ind",
                           desiredKeys: desiredKeys) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let record):
                if let category = CategoryModel(record: record) {
                    CoreDataManager.shared.saveCategory(category: category)
                }
            }
        }
    }
    
    static func fetchStoreFromCloud() {
        let desiredKeys = ["recordId", "id", "title", "createdAt"]
        fetchDataFromCloud(recordType: .store, sortKey: "createdAt",
                           desiredKeys: desiredKeys) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let record):
                if let store = Store(record: record) {
                    CoreDataManager.shared.saveStore(store)
                }
            }
        }
    }
    
    static func fetchPantryFromCloud() {
        let desiredKeys = ["recordId", "id", "name", "index", "color", "dateOfCreation",
                           "sharedId", "isShared", "isSharedListOwner"]
        fetchDataFromCloud(recordType: .pantryModel, sortKey: "index",
                           desiredKeys: desiredKeys) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let record):
                let imageData = getImageData(image: record.value(forKey: "icon"))
                if let pantry = PantryModel(record: record, imageData: imageData) {
                    CoreDataManager.shared.savePantry(pantry: [pantry])
                }
            }
        }
    }
    
    static func fetchStockFromCloud() {
        let desiredKeys = ["recordId", "id", "pantryId", "name", "index", "description", "category", "dateOfCreation"]
        fetchDataFromCloud(recordType: .stock, sortKey: "index",
                           desiredKeys: desiredKeys) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let record):
                let imageData = getImageData(image: record.value(forKey: "imageData"))
                if let stock = Stock(record: record, imageData: imageData) {
                    CoreDataManager.shared.saveStock(stock: [stock], for: stock.pantryId.uuidString)
                }
            }
        }
    }
    
    static func fetchCollectionFromCloud() {
        let desiredKeys = ["recordId", "id", "title", "index", "color", "isDefault", "isDeleteDefault"]
        fetchDataFromCloud(recordType: .collectionModel, sortKey: "index",
                           desiredKeys: desiredKeys) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let record):
                let imageData = getImageData(image: record.value(forKey: "localImage"))
                if let collection = CollectionModel(record: record, imageData: imageData) {
                    CoreDataManager.shared.saveCollection(collections: [collection])
                }
            }
        }
    }
    
    static func fetchRecipeFromCloud() {
        let desiredKeys = ["recordId", "id", "title", "photo", "description", "cookingTime",
                           "values", "createdAt"]
        fetchDataFromCloud(recordType: .recipe, sortKey: "createdAt",
                           desiredKeys: desiredKeys) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let record):
                let imageData = getImageData(image: record.value(forKey: "icon"))
                if let recipe = Recipe(record: record, imageData: imageData) {
                    CoreDataManager.shared.saveRecipes(recipes: [recipe])
                }
            }
        }
    }
    
    static func fetchSettingsFromCloud() {
        //        let desiredKeys = ["recipeIsFolderView", "recipeIsTableView", "userTokens", "pantryUserTokens"]
        fetchDataFromCloud(recordType: .settings, sortKey: "",
                           desiredKeys: []) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let record):
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
    
    // MARK: save/update Data
    static func saveCloudData(groceryList: GroceryListsModel) {
        let record = CKRecord(recordType: "GroceryListsModel")
        record.setValue(groceryList.id.int64, forKey: "id")
        record.setValue(groceryList.name, forKey: "name")
        record.setValue(groceryList.dateOfCreation, forKey: "dateOfCreation")
        record.setValue(groceryList.isFavorite, forKey: "isFavorite")
        record.setValue(groceryList.color, forKey: "color")
        record.setValue(groceryList.products, forKey: "products")
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
        
        if groceryList.recordId.isEmpty {
            save(record: record) { recordID in
                var updateGroceryList = groceryList
                updateGroceryList.recordId = recordID
                CoreDataManager.shared.saveList(list: updateGroceryList)
            }
            return
        }
        updateCloudData(groceryList: groceryList)
    }
    
    static func updateCloudData(groceryList: GroceryListsModel) {
        let recordID = CKRecord.ID(recordName: groceryList.recordId)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if let record {
                record.setValue(groceryList.id.int64, forKey: "id")
                record.setValue(groceryList.name, forKey: "name")
                record.setValue(groceryList.dateOfCreation, forKey: "dateOfCreation")
                record.setValue(groceryList.isFavorite, forKey: "isFavorite")
                record.setValue(groceryList.color, forKey: "color")
                record.setValue(groceryList.products, forKey: "products")
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
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: nil) { _ in }
                }
            }
        }
    }
    
    static func saveCloudData(product: Product) {
        let image = prepareImageToSaveToCloud(name: product.id.uuidString,
                                              imageData: product.imageData)
        let record = CKRecord(recordType: RecordType.product.rawValue)
        record.setValue(product.id.int64, forKey: "id")
        record.setValue(product.listId.int64, forKey: "listId")
        record.setValue(product.dateOfCreation, forKey: "dateOfCreation")
        record.setValue(product.name, forKey: "name")
        record.setValue(product.description, forKey: "description")
        record.setValue(image.asset, forKey: "imageData")
        record.setValue(product.category, forKey: "category")
        record.setValue(product.isFavorite, forKey: "isFavorite")
        record.setValue(product.isPurchased, forKey: "isPurchased")
        record.setValue(product.fromRecipeTitle, forKey: "fromRecipeTitle")
        record.setValue(product.unitId?.rawValue, forKey: "unitId")
        record.setValue(product.isUserImage, forKey: "isUserImage")
        record.setValue(product.userToken, forKey: "userToken")
        record.setValue(product.store, forKey: "store")
        record.setValue(product.cost, forKey: "cost")
        record.setValue(product.quantity, forKey: "quantity")
        
        if product.recordId.isEmpty {
            save(record: record, imageUrl: image.url) { recordID in
                var updateProduct = product
                updateProduct.recordId = recordID
                CoreDataManager.shared.createProduct(product: updateProduct)
            }
            return
        }
        updateCloudData(product: product, image: image)
    }
    
    static func updateCloudData(product: Product, image: (asset: CKAsset?, url: URL?)) {
        let recordID = CKRecord.ID(recordName: product.recordId)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if let record {
                record.setValue(product.id.int64, forKey: "id")
                record.setValue(product.listId.int64, forKey: "listId")
                record.setValue(product.dateOfCreation, forKey: "dateOfCreation")
                record.setValue(product.name, forKey: "name")
                record.setValue(product.description, forKey: "description")
                record.setValue(image.asset, forKey: "imageData")
                record.setValue(product.category, forKey: "category")
                record.setValue(product.isFavorite, forKey: "isFavorite")
                record.setValue(product.isPurchased, forKey: "isPurchased")
                record.setValue(product.fromRecipeTitle, forKey: "fromRecipeTitle")
                record.setValue(product.unitId?.rawValue, forKey: "unitId")
                record.setValue(product.isUserImage, forKey: "isUserImage")
                record.setValue(product.userToken, forKey: "userToken")
                record.setValue(product.store, forKey: "store")
                record.setValue(product.cost, forKey: "cost")
                record.setValue(product.quantity, forKey: "quantity")
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: image.url) { _ in }
                }
            }
        }
    }
    
    static func saveCloudData(category: CategoryModel) {
        let record = CKRecord(recordType: RecordType.categoryModel.rawValue)
        record.setValue(category.ind, forKey: "ind")
        record.setValue(category.name, forKey: "name")
        
        if category.recordId.isEmpty {
            save(record: record) { recordID in
                var updateCategory = category
                updateCategory.recordId = recordID
                CoreDataManager.shared.saveCategory(category: updateCategory)
            }
            return
        }
        updateCloudData(category: category)
    }
    
    static func updateCloudData(category: CategoryModel) {
        let recordID = CKRecord.ID(recordName: category.recordId)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if let record {
                record.setValue(category.ind, forKey: "ind")
                record.setValue(category.name, forKey: "name")
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: nil) { _ in }
                }
            }
        }
    }
    
    static func saveCloudData(store: Store) {
        let record = CKRecord(recordType: RecordType.store.rawValue)
        record.setValue(store.id.int64, forKey: "id")
        record.setValue(store.title, forKey: "title")
        record.setValue(store.createdAt, forKey: "createdAt")
        
        if store.recordId.isEmpty {
            save(record: record) { recordID in
                var updateStore = store
                updateStore.recordId = recordID
                CoreDataManager.shared.saveStore(updateStore)
            }
            return
        }
        updateCloudData(store: store)
    }
    
    static func updateCloudData(store: Store) {
        let recordID = CKRecord.ID(recordName: store.recordId)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if let record {
                record.setValue(store.id.int64, forKey: "id")
                record.setValue(store.title, forKey: "title")
                record.setValue(store.createdAt, forKey: "createdAt")
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: nil) { _ in }
                }
            }
        }
    }
    
    static func saveCloudData(pantryModel: PantryModel) {
        let image = prepareImageToSaveToCloud(name: pantryModel.id.uuidString,
                                              imageData: pantryModel.icon)
        let record = CKRecord(recordType: RecordType.pantryModel.rawValue)
        record.setValue(pantryModel.id.int64, forKey: "id")
        record.setValue(pantryModel.name, forKey: "name")
        record.setValue(pantryModel.index, forKey: "index")
        record.setValue(pantryModel.color, forKey: "color")
        record.setValue(image.asset, forKey: "icon")
        record.setValue(pantryModel.stock, forKey: "stock")
        record.setValue(pantryModel.synchronizedLists, forKey: "synchronizedLists")
        record.setValue(pantryModel.dateOfCreation, forKey: "dateOfCreation")
        record.setValue(pantryModel.sharedId, forKey: "sharedId")
        record.setValue(pantryModel.isShared, forKey: "isShared")
        record.setValue(pantryModel.isSharedListOwner, forKey: "isSharedListOwner")
        
        if pantryModel.recordId.isEmpty {
            save(record: record, imageUrl: image.url) { recordID in
                var updatePantryModel = pantryModel
                updatePantryModel.recordId = recordID
                CoreDataManager.shared.savePantry(pantry: [updatePantryModel])
            }
            return
        }
        updateCloudData(pantryModel: pantryModel, image: image)
    }
    
    static func updateCloudData(pantryModel: PantryModel, image: (asset: CKAsset?, url: URL?)) {
        let recordID = CKRecord.ID(recordName: pantryModel.recordId)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if let record {
                record.setValue(pantryModel.id.int64, forKey: "id")
                record.setValue(pantryModel.name, forKey: "name")
                record.setValue(pantryModel.index, forKey: "index")
                record.setValue(pantryModel.color, forKey: "color")
                record.setValue(image.asset, forKey: "icon")
                record.setValue(pantryModel.stock, forKey: "stock")
                record.setValue(pantryModel.synchronizedLists, forKey: "synchronizedLists")
                record.setValue(pantryModel.dateOfCreation, forKey: "dateOfCreation")
                record.setValue(pantryModel.sharedId, forKey: "sharedId")
                record.setValue(pantryModel.isShared, forKey: "isShared")
                record.setValue(pantryModel.isSharedListOwner, forKey: "isSharedListOwner")
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: image.url) { _ in }
                }
            }
        }
    }
    
    static func saveCloudData(stock: Stock) {
        let image = prepareImageToSaveToCloud(name: stock.id.uuidString,
                                              imageData: stock.imageData)
        let record = CKRecord(recordType: RecordType.stock.rawValue)
        record.setValue(stock.id.int64, forKey: "id")
        record.setValue(stock.index, forKey: "index")
        record.setValue(stock.pantryId.int64, forKey: "pantryId")
        record.setValue(stock.name, forKey: "name")
        record.setValue(stock.description, forKey: "description")
        record.setValue(image.asset, forKey: "imageData")
        record.setValue(stock.category, forKey: "category")
        record.setValue(stock.store, forKey: "store")
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
        
        if stock.recordId.isEmpty {
            save(record: record, imageUrl: image.url) { recordID in
                var updateStock = stock
                updateStock.recordId = recordID
                CoreDataManager.shared.saveStock(stock: [updateStock], for: stock.pantryId.uuidString)
            }
            return
        }
        updateCloudData(stock: stock, image: image)
    }
    
    static func updateCloudData(stock: Stock, image: (asset: CKAsset?, url: URL?)) {
        let recordID = CKRecord.ID(recordName: stock.recordId)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if let record {
                record.setValue(stock.id.int64, forKey: "id")
                record.setValue(stock.index, forKey: "index")
                record.setValue(stock.pantryId.int64, forKey: "pantryId")
                record.setValue(stock.name, forKey: "name")
                record.setValue(stock.description, forKey: "description")
                record.setValue(image.asset, forKey: "imageData")
                record.setValue(stock.category, forKey: "category")
                record.setValue(stock.store, forKey: "store")
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
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: image.url) { _ in }
                }
            }
        }
    }
    
    static func saveCloudSettings() {
        let record = CKRecord(recordType: RecordType.settings.rawValue)
        record.setValue(UserDefaultsManager.shared.isMetricSystem, forKey: "isMetricSystem")
        record.setValue(UserDefaultsManager.shared.isHapticOn, forKey: "isHapticOn")
        record.setValue(UserDefaultsManager.shared.userTokens, forKey: "userTokens")
        record.setValue(UserDefaultsManager.shared.isShowImage, forKey: "isShowImage")
        record.setValue(UserDefaultsManager.shared.isActiveAutoCategory, forKey: "isActiveAutoCategory")
        record.setValue(UserDefaultsManager.shared.pantryUserTokens, forKey: "pantryUserTokens")
        record.setValue(UserDefaultsManager.shared.recipeIsFolderView, forKey: "recipeIsFolderView")
        record.setValue(UserDefaultsManager.shared.recipeIsTableView, forKey: "recipeIsTableView")
        record.setValue(UserDefaultsManager.shared.favoritesRecipeIds, forKey: "favoritesRecipeIds")
        
        if UserDefaultsManager.shared.settingsRecordId.isEmpty {
            save(record: record) { recordID in
                UserDefaultsManager.shared.settingsRecordId = recordID
            }
            return
        }
        updateCloudSettings()
    }
    
    static func updateCloudSettings() {
        let recordID = CKRecord.ID(recordName: UserDefaultsManager.shared.settingsRecordId)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if let record {
                record.setValue(UserDefaultsManager.shared.isMetricSystem, forKey: "isMetricSystem")
                record.setValue(UserDefaultsManager.shared.isHapticOn, forKey: "isHapticOn")
                record.setValue(UserDefaultsManager.shared.userTokens, forKey: "userTokens")
                record.setValue(UserDefaultsManager.shared.isShowImage, forKey: "isShowImage")
                record.setValue(UserDefaultsManager.shared.isActiveAutoCategory, forKey: "isActiveAutoCategory")
                record.setValue(UserDefaultsManager.shared.pantryUserTokens, forKey: "pantryUserTokens")
                record.setValue(UserDefaultsManager.shared.recipeIsFolderView, forKey: "recipeIsFolderView")
                record.setValue(UserDefaultsManager.shared.recipeIsTableView, forKey: "recipeIsTableView")
                record.setValue(UserDefaultsManager.shared.favoritesRecipeIds, forKey: "favoritesRecipeIds")
                DispatchQueue.main.async {
                    self.save(record: record, imageUrl: nil) { _ in }
                }
            }
        }
    }
    
    // MARK: delete Data
    static func deleteGroceryList(recordId: String) {
        delete(recordType: .groceryListsModel, recordID: recordId)
    }
    
    static func deleteProduct(recordId: String) {
        delete(recordType: .product, recordID: recordId)
    }
    
    static func deleteCategory(recordId: String) {
        delete(recordType: .categoryModel, recordID: recordId)
    }
    
    static func deleteStore(recordId: String) {
        delete(recordType: .store, recordID: recordId)
    }
    
    static func deletePantry(recordId: String) {
        delete(recordType: .pantryModel, recordID: recordId)
    }
    
    static func deleteStock(recordId: String) {
        delete(recordType: .stock, recordID: recordId)
    }
    
    static func deleteCollection(recordId: String) {
        delete(recordType: .collectionModel, recordID: recordId)
    }
    
    static func deleteRecipe(recordId: String) {
        delete(recordType: .recipe, recordID: recordId)
    }
}
