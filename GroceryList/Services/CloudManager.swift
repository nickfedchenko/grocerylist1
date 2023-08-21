//
//  CloudManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 17.08.2023.
//

import CloudKit
import UIKit

// swiftlint:disable:next type_body_length
final class CloudManager {
    
    // TODO: перед релизом поменять на CKContainer.default().privateCloudDatabase
    private static let privateCloudDataBase = CKContainer.default().publicCloudDatabase
    
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
                let groceryList = GroceryListsModel(record: record)
                CoreDataManager.shared.saveList(list: groceryList)
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
                let product = Product(record: record, imageData: imageData)
                CoreDataManager.shared.createProduct(product: product)
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
                let store = Store(record: record)
                CoreDataManager.shared.saveStore(store)
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
                let pantry = PantryModel(record: record, imageData: imageData)
                CoreDataManager.shared.savePantry(pantry: [pantry])
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
        let desiredKeys = ["recipeIsFolderView", "recipeIsTableView", "userTokens", "pantryUserTokens"]
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
                UserDefaultsManager.shared.userTokens = (try? JSONDecoder().decode([String].self, from: record.value(forKey: "userTokens") as? Data ?? Data())) ?? []
                UserDefaultsManager.shared.pantryUserTokens = (try? JSONDecoder().decode([String].self, from: record.value(forKey: "pantryUserTokens") as? Data ?? Data())) ?? []
            }
        }
    }
    
    // MARK: save/update Data
    static func saveCloudData(groceryList: GroceryListsModel) {
        let recordID = CKRecord.ID(recordName: groceryList.recordId)
        let record = CKRecord(recordType: "GroceryListsModel")
        record.setValue(groceryList.id, forKey: "id")
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

        fetch(recordID: recordID, newRecord: record)
    }
    
    static func saveCloudData(product: Product) {
        let recordID = CKRecord.ID(recordName: product.recordId)
        let image = prepareImageToSaveToCloud(name: product.id.uuidString,
                                              imageData: product.imageData)
        let record = CKRecord(recordType: RecordType.product.rawValue)
        record.setValue(product.id, forKey: "id")
        record.setValue(product.listId, forKey: "listId")
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

        fetch(recordID: recordID, newRecord: record, imageUrl: image.url)
    }
    
    static func saveCloudData(category: CategoryModel) {
        let recordID = CKRecord.ID(recordName: category.recordId)
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

        fetch(recordID: recordID, newRecord: record)
    }
    
    static func saveCloudData(store: Store) {
        let recordID = CKRecord.ID(recordName: store.recordId)
        let record = CKRecord(recordType: RecordType.store.rawValue)
        record.setValue(store.id, forKey: "id")
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

        fetch(recordID: recordID, newRecord: record)
    }
    
    static func saveCloudData(pantryModel: PantryModel) {
        let recordID = CKRecord.ID(recordName: pantryModel.recordId)
        let image = prepareImageToSaveToCloud(name: pantryModel.id.uuidString,
                                              imageData: pantryModel.icon)
        let record = CKRecord(recordType: RecordType.pantryModel.rawValue)
        record.setValue(pantryModel.id, forKey: "id")
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

        fetch(recordID: recordID, newRecord: record, imageUrl: image.url)
    }

    static func saveCloudData(stock: Stock) {
        let recordID = CKRecord.ID(recordName: stock.recordId)
        let image = prepareImageToSaveToCloud(name: stock.id.uuidString,
                                              imageData: stock.imageData)
        let record = CKRecord(recordType: RecordType.stock.rawValue)
        record.setValue(stock.id, forKey: "id")
        record.setValue(stock.index, forKey: "index")
        record.setValue(stock.pantryId, forKey: "pantryId")
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

        fetch(recordID: recordID, newRecord: record, imageUrl: image.url)
    }

    static func saveCloudData(collectionModel: CollectionModel) {
        let recordID = CKRecord.ID(recordName: collectionModel.recordId)
        let image = prepareImageToSaveToCloud(name: collectionModel.id.asString,
                                              imageData: collectionModel.localImage)
        let record = CKRecord(recordType: RecordType.collectionModel.rawValue)
        record.setValue(collectionModel.id, forKey: "id")
        record.setValue(collectionModel.index, forKey: "index")
        record.setValue(collectionModel.title, forKey: "title")
        record.setValue(collectionModel.color, forKey: "color")
        record.setValue(collectionModel.isDefault, forKey: "isDefault")
        record.setValue(image.asset, forKey: "localImage")
        record.setValue(collectionModel.dishes, forKey: "dishes")
        record.setValue(collectionModel.isDeleteDefault, forKey: "isDeleteDefault")
        
        if collectionModel.recordId.isEmpty {
            save(record: record, imageUrl: image.url) { recordID in
                var updateCollectionModel = collectionModel
                updateCollectionModel.recordId = recordID
                CoreDataManager.shared.saveCollection(collections: [updateCollectionModel])
            }
            return
        }

        fetch(recordID: recordID, newRecord: record, imageUrl: image.url)
    }

    static func saveCloudData(recipe: Recipe) {
        let recordID = CKRecord.ID(recordName: recipe.recordId)
        let image = prepareImageToSaveToCloud(name: recipe.id.asString,
                                              imageData: recipe.localImage)
        let record = CKRecord(recordType: RecordType.recipe.rawValue)
        record.setValue(recipe.id, forKey: "id")
        record.setValue(recipe.title, forKey: "title")
        record.setValue(image.asset, forKey: "localImage")
        record.setValue(recipe.photo, forKey: "photo")
        record.setValue(recipe.description, forKey: "description")
        record.setValue(recipe.cookingTime, forKey: "cookingTime")
        record.setValue(recipe.totalServings, forKey: "totalServings")
        record.setValue(recipe.dishWeight, forKey: "dishWeight")
        record.setValue(recipe.dishWeightType, forKey: "dishWeightType")
        record.setValue(recipe.values, forKey: "values")
        record.setValue(recipe.countries, forKey: "countries")
        record.setValue(recipe.instructions, forKey: "instructions")
        record.setValue(recipe.ingredients, forKey: "ingredients")
        record.setValue(recipe.eatingTags, forKey: "eatingTags")
        record.setValue(recipe.dishTypeTags, forKey: "dishTypeTags")
        record.setValue(recipe.processingTypeTags, forKey: "processingTypeTags")
        record.setValue(recipe.additionalTags, forKey: "additionalTags")
        record.setValue(recipe.dietTags, forKey: "dietTags")
        record.setValue(recipe.exceptionTags, forKey: "exceptionTags")
        record.setValue(recipe.isDraft, forKey: "isDraft")
        record.setValue(recipe.createdAt, forKey: "createdAt")
        record.setValue(recipe.isDefaultRecipe, forKey: "isDefaultRecipe")
        record.setValue(recipe.sourceUrl, forKey: "sourceUrl")

        if recipe.recordId.isEmpty {
            save(record: record, imageUrl: image.url) { recordID in
                var updateRecipe = recipe
                updateRecipe.recordId = recordID
                CoreDataManager.shared.saveRecipes(recipes: [updateRecipe])
            }
            return
        }

        fetch(recordID: recordID, newRecord: record, imageUrl: image.url)
    }
    
    static func saveCloudSettings() {
        let recordID = CKRecord.ID(recordName: UserDefaultsManager.shared.settingsRecordId)

        let record = CKRecord(recordType: RecordType.settings.rawValue)
        record.setValue(UserDefaultsManager.shared.isMetricSystem, forKey: "isMetricSystem")
        record.setValue(UserDefaultsManager.shared.isHapticOn, forKey: "isHapticOn")
        record.setValue(UserDefaultsManager.shared.userTokens, forKey: "userTokens")
        record.setValue(UserDefaultsManager.shared.isShowImage, forKey: "isShowImage")
        record.setValue(UserDefaultsManager.shared.isActiveAutoCategory, forKey: "isActiveAutoCategory")
        record.setValue(UserDefaultsManager.shared.pantryUserTokens, forKey: "pantryUserTokens")
        record.setValue(UserDefaultsManager.shared.recipeIsFolderView, forKey: "recipeIsFolderView")
        record.setValue(UserDefaultsManager.shared.recipeIsTableView, forKey: "recipeIsTableView")
        
        if UserDefaultsManager.shared.settingsRecordId.isEmpty {
            save(record: record) { recordID in
                UserDefaultsManager.shared.settingsRecordId = recordID
            }
            return
        }

        fetch(recordID: recordID, newRecord: record)
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
    
    // swiftlint:disable:next function_body_length
    private static func fetchDataFromCloud(recordType: RecordType, sortKey: String, desiredKeys: [String],
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
    
    private static func fetch(recordID: CKRecord.ID, newRecord: CKRecord, imageUrl: URL? = nil) {
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if record != nil {
                DispatchQueue.main.async {
                    self.save(record: newRecord, imageUrl: imageUrl) { _ in }
                }
            }
        }
    }
    
    private static func save(record: CKRecord, imageUrl: URL? = nil,
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
    
    private static func delete(recordType: RecordType, recordID: String) {
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
    
    private static func prepareImageToSaveToCloud(name: String, imageData: Data?) -> (asset: CKAsset?, url: URL?) {
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
    
    private static func deleteTempImage(imageUrl: URL?) {
        guard let imageUrl else {
            return
        }
        do {
            try FileManager.default.removeItem(at: imageUrl)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private static func getImageData(image: Any?) -> Data? {
        guard let imageAsset = image as? CKAsset,
              let url = imageAsset.fileURL,
              let imageData = try? Data(contentsOf: url) else {
            return nil
        }
        return imageData
    }
}
