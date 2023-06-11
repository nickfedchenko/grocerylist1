//
//  MainTabBarViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import UIKit

protocol MainTabBarViewModelDelegate: AnyObject {
    func updateRecipeUI(_ recipe: Recipe?)
    func updatePantryUI(_ pantry: PantryModel)
}

final class MainTabBarViewModel {
    
    weak var router: RootRouter?
    weak var delegate: MainTabBarViewModelDelegate?
    
    private var isRightHanded: Bool
    private let viewControllers: [UIViewController]
    
    var initialViewController: UIViewController? {
        viewControllers.first
    }
    
    // user
    var userPhoto: (url: String?, data: Data?) {
        (UserAccountManager.shared.getUser()?.avatar,
         UserAccountManager.shared.getUser()?.avatarAsData)
    }
    
    var userName: String? {
        UserAccountManager.shared.getUser()?.username
    }
    
    init(isRightHanded: Bool, viewControllers: [UIViewController]) {
        self.isRightHanded = isRightHanded
        self.viewControllers = viewControllers
    }
    
    func getIsRightHanded() -> Bool {
        return isRightHanded
    }
    
    func getViewControllers() -> [UIViewController] {
        viewControllers
    }
    
    func createNewRecipeTapped() {
        router?.goToCreateNewRecipe(compl: { [weak self] recipe in
            self?.delegate?.updateRecipeUI(recipe)
        })
    }
    
    func createNewCollectionTapped() {
        router?.goToCreateNewCollection(compl: { [weak self] _ in
            self?.delegate?.updateRecipeUI(nil)
        })
    }
    
    func showCollection() {
        router?.goToShowCollection(state: .edit, updateUI: { [weak self] in
            self?.delegate?.updateRecipeUI(nil)
        })
    }
    
    func showSearchProductsInList() {
        router?.goToSearchInList()
    }
    
    func showSearchProductsInRecipe() {
        router?.goToSearchInRecipe()
    }

    func showFeedback() {
        if FeedbackManager.shared.isShowFeedbackScreen() {
            router?.goToFeedback()
        }
    }
    
    func settingsTapped() {
        router?.goToSettingsController()
    }
    
    func showPaywall() {
        router?.showPaywallVC()
    }
    
    func showStockReminderIfNeeded() {
        let today = Date()
        if today.todayWithSetting(hour: 10) <= today,
           isShowStockReminderRequired() {
            router?.goToStockReminder()
            UserDefaultsManager.lastShowStockReminderDate = today.todayWithSetting(hour: 10)
        }
    }
    
    func analytic() {
        let lists = CoreDataManager.shared.getAllLists()
        var initialLists: [GroceryListsModel] = []
        var selectedItemsCount = 0
        var unselectedItemsCount = 0
        var favoriteItemsCount = 0
        var favoriteListsCount = 0
        var sharedListsCount = 0
        var sharedUserMax = 0
        
        initialLists = lists?.compactMap({ GroceryListsModel(from: $0) }) ?? []
        initialLists.forEach { list in
            let purchasedProducts = list.products.filter { $0.isPurchased }
            let nonPurchasedProducts = list.products.filter { !$0.isPurchased }
            let favoriteProducts = list.products.filter { $0.isFavorite }
            selectedItemsCount += purchasedProducts.count
            unselectedItemsCount += nonPurchasedProducts.count
            favoriteItemsCount += favoriteProducts.count
            if list.isFavorite {
                favoriteListsCount += 1
            }
            if list.isShared {
                sharedListsCount += 1
                if var sharedUserCount = SharedListManager.shared.sharedListsUsers[list.sharedId]?.count {
                    sharedUserCount -= 1
                    sharedUserMax = sharedUserCount > sharedUserMax ? sharedUserCount : sharedUserMax
                }
            }
        }
        
        AmplitudeManager.shared.logEvent(.listsCountStart, properties: [.count: "\(initialLists.count)"])
        AmplitudeManager.shared.logEvent(.itemsCountStart, properties: [.count: "\(unselectedItemsCount)"])
        AmplitudeManager.shared.logEvent(.itemsCheckedCountStart,  properties: [.count: "\(selectedItemsCount)"])
        AmplitudeManager.shared.logEvent(.listsPinned, properties: [.count: "\(favoriteListsCount)"])
        AmplitudeManager.shared.logEvent(.itemsPinned, properties: [.count: "\(favoriteItemsCount)"])
        AmplitudeManager.shared.logEvent(.sharedLists, properties: [.count: "\(sharedListsCount)"])
        AmplitudeManager.shared.logEvent(.sharedUsersMaxCount, properties: [.count: "\(sharedUserMax)"])
    }
    
    private func isShowStockReminderRequired() -> Bool {
        guard let lastRefreshDate = UserDefaultsManager.lastShowStockReminderDate else {
            return true
        }
        if let diff = Calendar.current.dateComponents(
            [.hour], from: lastRefreshDate, to: Date()
        ).hour {
            return diff > 24
        }
        return false
    }
}
