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
                    self.save(record: record) { _ in }
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

        let image = convertDataToAsset(name: product.id.uuidString,
                                              data: product.imageData)
        if product.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.product.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, product: product, asset: image)
            
            save(record: record) { recordID in
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
                record = self.fillInRecord(record: record, product: product, asset: image)
                
                DispatchQueue.main.async {
                    self.save(record: record) { _ in }
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
                    self.save(record: record) { _ in }
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
                    self.save(record: record) { _ in }
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

        var pantryModel = pantryModel
        if let dbPantry = CoreDataManager.shared.getPantry(id: pantryModel.id.uuidString) {
            pantryModel = PantryModel(dbModel: dbPantry)
        }
        
        let image = convertDataToAsset(name: pantryModel.id.uuidString,
                                              data: pantryModel.icon)
        if pantryModel.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.pantryModel.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, pantryModel: pantryModel, asset: image)
            
            save(record: record) { recordID in
                var updatePantryModel = pantryModel
                updatePantryModel.recordId = recordID
                CoreDataManager.shared.savePantry(pantry: [updatePantryModel])
            }
            return
        }

        let recordID = CKRecord.ID(recordName: pantryModel.recordId, zoneID: zoneID)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print("[CloudKit]: ", error.localizedDescription)
                return
            }
            if var record {
                record = self.fillInRecord(record: record, pantryModel: pantryModel, asset: image)
                
                DispatchQueue.main.async {
                    self.save(record: record) { _ in }
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

        let image = convertDataToAsset(name: stock.id.uuidString,
                                       data: stock.imageData)
        if stock.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.stock.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, stock: stock, asset: image)
            
            save(record: record) { recordID in
                var updateStock = stock
                updateStock.recordId = recordID
                CoreDataManager.shared.saveStock(stocks: [updateStock], for: stock.pantryId.uuidString)
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
                record = self.fillInRecord(record: record, stock: stock, asset: image)
                DispatchQueue.main.async {
                    self.save(record: record) { _ in }
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
        let image = convertDataToAsset(name: recipe.id.asString, data: recipe.localImage)
        let ingredients = convertDataToAsset(name: "ingredients" + recipe.id.asString,
                                             data: try? JSONEncoder().encode(recipe.ingredients))
        if recipe.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.recipe.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, recipe: recipe, image: image, ingredients: ingredients)

            save(record: record) { recordID in
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
                record = self.fillInRecord(record: record, recipe: recipe, image: image, ingredients: ingredients)
                DispatchQueue.main.async {
                    self.save(record: record) { _ in }
                }
            }
        }
    }
    
    func fillInRecord(record: CKRecord, recipe: Recipe, image: CKAsset?, ingredients: CKAsset?) -> CKRecord {
        let record = record
        record.setValue(recipe.id, forKey: "id")
        record.setValue(recipe.title, forKey: "title")
        record.setValue(image, forKey: "localImage")
        record.setValue(recipe.photo, forKey: "photo")
        record.setValue(recipe.description, forKey: "description")
        record.setValue(recipe.cookingTime, forKey: "cookingTime")
        record.setValue(recipe.totalServings, forKey: "totalServings")
        record.setValue(recipe.dishWeight, forKey: "dishWeight")
        record.setValue(recipe.dishWeightType, forKey: "dishWeightType")
        record.setValue(try? JSONEncoder().encode(recipe.values), forKey: "values")
        record.setValue(recipe.countries, forKey: "countries")
//        record.setValue(ingredients, forKey: "ingredients")
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

        let image = convertDataToAsset(name: collectionModel.id.asString,
                                              data: collectionModel.localImage)
        if collectionModel.recordId.isEmpty {
            var record = CKRecord(recordType: RecordType.collectionModel.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
            record = fillInRecord(record: record, collectionModel: collectionModel, asset: image)
            
            save(record: record) { recordID in
                var updateCollectionModel = collectionModel
                updateCollectionModel.recordId = recordID
                CoreDataManager.shared.saveCollection(collections: [updateCollectionModel])
            }
            return
        }
        
        let recordID = CKRecord.ID(recordName: collectionModel.recordId, zoneID: zoneID)
        privateCloudDataBase.fetch(withRecordID: recordID) { record, error in
            if let error {
                print("[CloudKit]: ", error.localizedDescription)
                return
            }
            if var record {
                record = self.fillInRecord(record: record, collectionModel: collectionModel, asset: image)
                DispatchQueue.main.async {
                    self.save(record: record) { _ in }
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
                    self.save(record: record) { _ in }
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
