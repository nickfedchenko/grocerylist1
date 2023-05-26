//
//  MainTabBarViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import UIKit

protocol MainTabBarViewModelDelegate: AnyObject {
    func updateRecipeUI(_ recipe: Recipe?)
}

final class MainTabBarViewModel {
    
    weak var router: RootRouter?
    weak var recipeDelegate: MainTabBarViewModelDelegate?
    
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
    
    func tappedAddItem(state: TabBarItemView.Item) {
        switch state {
        case .list, .recipe:
            router?.goCreateNewList(compl: { [weak self] model, _  in
                self?.router?.goProductsVC(model: model, compl: { })
            })
        case .pantry:
            router?.goToCreateNewPantry()
        }
    }
    
    func createNewRecipeTapped() {
        router?.goToCreateNewRecipe(compl: { [weak self] recipe in
            self?.recipeDelegate?.updateRecipeUI(recipe)
        })
    }
    
    func createNewCollectionTapped() {
        router?.goToCreateNewCollection(compl: { [weak self] _ in
            self?.recipeDelegate?.updateRecipeUI(nil)
        })
    }
    
    func showCollection() {
        router?.goToShowCollection(state: .edit, updateUI: { [weak self] in
            self?.recipeDelegate?.updateRecipeUI(nil)
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
}
