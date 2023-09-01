//
//  UserDefaultsManager.shared.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 21.11.2022.
//

import Foundation

class UserDefaultsManager {
    
    enum UDKeys: String {
        case favoriteRecipes
    }
    
    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.ksens.shopp") ?? UserDefaults.standard
    
    private init() {
        migrateUserDefaultsToAppGroups()
    }
    
    var shouldShowOnboarding: Bool {
        get {
            guard let shouldShow = userDefaults.value(forKey: "shouldShowOnboarding") as? Bool else {
                return true
            }
            return shouldShow
        }
        set { userDefaults.set(newValue, forKey: "shouldShowOnboarding") }
    }
    
    var isFirstLaunch: Bool {
        get { userDefaults.bool(forKey: "isFirstLaunch") }
        set { userDefaults.set(newValue, forKey: "isFirstLaunch") }
    }
    
    var firstLaunchDate: Date? {
        get { userDefaults.object(forKey: "firstLaunchDate") as? Date }
        set { userDefaults.set(newValue, forKey: "firstLaunchDate") }
    }
    
    var coldStartState: Int {
        get { userDefaults.integer(forKey: "coldStartState") }
        set { userDefaults.set(newValue, forKey: "coldStartState") }
    }
    
    var isMetricSystem: Bool {
        get { userDefaults.bool(forKey: "isMetricSystem") }
        set { userDefaults.set(newValue, forKey: "isMetricSystem") }
    }
    
    var isHapticOn: Bool {
        get { userDefaults.bool(forKey: "isHapticOn") }
        set { userDefaults.set(newValue, forKey: "isHapticOn") }
    }
    
    var isReviewShowed: Bool {
        get { userDefaults.bool(forKey: "shouldOpenWriteReview") }
        set { userDefaults.set(newValue, forKey: "shouldOpenWriteReview") }
    }
    
    var isReviewShowedAfterSharing: Bool {
        get { userDefaults.bool(forKey: "isReviewShowedAfterSharing") }
        set { userDefaults.set(newValue, forKey: "isReviewShowedAfterSharing") }
    }
    
    var isNativeRateUsShowed: Bool {
        get { userDefaults.bool(forKey: "isNativeRateUsShowed") }
        set { userDefaults.set(newValue, forKey: "isNativeRateUsShowed") }
    }
    
    var isFirstListCreated: Bool {
        get { userDefaults.bool(forKey: "isFirstListCreated") }
        set { userDefaults.set(newValue, forKey: "isFirstListCreated") }
    }
    
    var countInfoMessage: Int {
        get { userDefaults.integer(forKey: "countInfoMessage") }
        set { userDefaults.set(newValue, forKey: "countInfoMessage") }
    }
    
    var userTokens: [String]? {
        get { userDefaults.array(forKey: "userTokens") as? [String] }
        set { userDefaults.set(newValue, forKey: "userTokens") }
    }
    
    var favoritesRecipeIds: [Int] {
        get {
            guard
                let data: Data = getValue(for: .favoriteRecipes),
                let ids = try? JSONDecoder().decode([Int].self, from: data)
            else { return [] }
            return ids
        }
        
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                setValue(value: data, for: .favoriteRecipes)
            }
        }
    }
    
    var isCollectionFilling: Bool {
        get { userDefaults.bool(forKey: "isCollectionFilling") }
        set { userDefaults.set(newValue, forKey: "isCollectionFilling") }
    }
    
    var isFillingDefaultCollection: Bool {
        get { userDefaults.bool(forKey: "isFillingDefaultCollection") }
        set { userDefaults.set(newValue, forKey: "isFillingDefaultCollection") }
    }
    
    var miscellaneousCollectionId: Int {
        get { userDefaults.integer(forKey: "miscellaneousCollectionId") }
        set { userDefaults.set(newValue, forKey: "miscellaneousCollectionId") }
    }
    
    var isShowRecipePrompting: Bool {
        get { userDefaults.bool(forKey: "isShowRecipePrompting") }
        set { userDefaults.set(newValue, forKey: "isShowRecipePrompting") }
    }
    
    var isShowImage: Bool {
        get { !userDefaults.bool(forKey: "isShowImage") }
        set { userDefaults.set(!newValue, forKey: "isShowImage") }
    }
    
    var countAutoCategoryInfo: Int {
        get { userDefaults.integer(forKey: "countAutoCategoryInfo") }
        set { userDefaults.set(newValue, forKey: "countAutoCategoryInfo") }
    }
    
    var isActiveAutoCategory: Bool? {
        get {
            guard let shouldShow = userDefaults.value(forKey: "isActiveAutoCategory") as? Bool else {
                return nil
            }
            return shouldShow
        }
        set {
            userDefaults.set(newValue, forKey: "isActiveAutoCategory")
        }
    }
    
    var isFillingDefaultPantry: Bool {
        get { userDefaults.bool(forKey: "isFillingDefaultPantry") }
        set { userDefaults.set(newValue, forKey: "isFillingDefaultPantry") }
    }
    
    var isShowPantryStarterPack: Bool {
        get { userDefaults.bool(forKey: "isShowPantryStarterPack") }
        set { userDefaults.set(newValue, forKey: "isShowPantryStarterPack") }
    }
    
    var pantryUserTokens: [String]? {
        get { userDefaults.array(forKey: "pantryUserTokens") as? [String] }
        set { userDefaults.set(newValue, forKey: "pantryUserTokens") }
    }
    
    var lastUpdateStockDate: Date? {
        get { userDefaults.object(forKey: "lastUpdateStockDate") as? Date }
        set { userDefaults.set(newValue, forKey: "lastUpdateStockDate") }
    }
    
    var lastShowStockReminderDate: Date? {
        get { userDefaults.object(forKey: "lastShowStockReminderDate") as? Date }
        set { userDefaults.set(newValue, forKey: "lastShowStockReminderDate") }
    }
    
    var recipeIsFolderView: Bool {
        get { userDefaults.bool(forKey: "recipeIsFolderView") }
        set { userDefaults.set(newValue, forKey: "recipeIsFolderView") }
    }
    
    var isFillingDefaultTechnicalCollection: Bool {
        get { userDefaults.bool(forKey: "isFillingDefaultTechnicalCollection") }
        set { userDefaults.set(newValue, forKey: "isFillingDefaultTechnicalCollection") }
    }
    
    var recipeIsTableView: Bool {
        get { userDefaults.bool(forKey: "recipeIsTableView") }
        set { userDefaults.set(newValue, forKey: "recipeIsTableView") }
    }
    
    var isUpdateRecipeWithCollection: Bool {
        get { userDefaults.bool(forKey: "isUpdateRecipeWithCollection") }
        set { userDefaults.set(newValue, forKey: "isUpdateRecipeWithCollection") }
    }
    
    var isDoneFeedBack: Bool {
        get {
            guard let shouldShow = userDefaults.value(forKey: "isDoneFeedBack") as? Bool else {
                return false
            }
            return shouldShow
        }
        set {
            userDefaults.set(newValue, forKey: "isDoneFeedBack")
        }
    }
    
    var lastShowFeedBackDate: Date? {
        get { userDefaults.object(forKey: "lastShowFeedBackDate") as? Date }
        set { userDefaults.set(newValue, forKey: "lastShowFeedBackDate") }
    }
    
    var isVisibleEditMessageView: Bool {
        get { userDefaults.bool(forKey: "isVisibleEditMessageView") }
        set { userDefaults.set(newValue, forKey: "isVisibleEditMessageView") }
    }
    
    var testOnboardingValue: String? {
        get { userDefaults.string(forKey: "testOnboardingValue") }
        set { userDefaults.set(newValue, forKey: "testOnboardingValue") }
    }
    
    var isFixReplaceCoreData: Bool {
        get { userDefaults.bool(forKey: "isFixReplaceCoreData") }
        set { userDefaults.set(newValue, forKey: "isFixReplaceCoreData") }
    }
    
    var isNewFeature: Bool {
        get { userDefaults.bool(forKey: "isNewFeatureICloud") }
        set { userDefaults.set(newValue, forKey: "isNewFeatureICloud") }
    }
    
    var countShowMessageNewFeature: Int {
        get { userDefaults.integer(forKey: "createdCustomZone") }
        set { userDefaults.set(newValue, forKey: "createdCustomZone") }
    }
    
    var settingsRecordId: String {
        get { userDefaults.string(forKey: "settingsRecordId") ?? "" }
        set { userDefaults.set(newValue, forKey: "settingsRecordId") }
    }
    
    var isICloudDataBackupOn: Bool {
        get { userDefaults.bool(forKey: "isICloudDataBackupOn") }
        set { userDefaults.set(newValue, forKey: "isICloudDataBackupOn") }
    }
    
    var createdCustomZone: Bool {
        get { userDefaults.bool(forKey: "createdCustomZone") }
        set { userDefaults.set(newValue, forKey: "createdCustomZone") }
    }
    
    var subscribedToPrivateChanges: Bool {
        get { userDefaults.bool(forKey: "subscribedToPrivateChanges") }
        set { userDefaults.set(newValue, forKey: "subscribedToPrivateChanges") }
    }
    
    var databaseChangeTokenKey: Data? {
        get { userDefaults.data(forKey: "databaseChangeTokenKey") }
        set { userDefaults.set(newValue, forKey: "databaseChangeTokenKey") }
    }
    
    var zoneChangeTokenKey: Data? {
        get { userDefaults.data(forKey: "zoneChangeTokenKey") }
        set { userDefaults.set(newValue, forKey: "zoneChangeTokenKey") }
    }
    
    private func setValue<T>(value: T, for key: UDKeys) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    private func getValue<T>(for key: UDKeys) -> T? {
        userDefaults.object(forKey: key.rawValue) as? T
    }
    
    private func migrateUserDefaultsToAppGroups() {
        let userDefaults = UserDefaults.standard
        let groupDefaults = UserDefaults(suiteName: "group.com.ksens.shopp")
        let didMigrateToAppGroups = "DidMigrateToAppGroups"
        
        if let groupDefaults = groupDefaults {
            if !groupDefaults.bool(forKey: didMigrateToAppGroups) {
                for key in userDefaults.dictionaryRepresentation().keys {
                    groupDefaults.set(userDefaults.dictionaryRepresentation()[key], forKey: key)
                }
                groupDefaults.set(true, forKey: didMigrateToAppGroups)
                groupDefaults.synchronize()
                print("Successfully migrated defaults")
            } 
        } else {
            print("Unable to create NSUserDefaults with given app group")
        }
    }
}
