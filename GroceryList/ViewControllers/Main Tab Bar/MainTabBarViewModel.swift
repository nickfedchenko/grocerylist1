//
//  MainTabBarViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import ApphudSDK
import UIKit

protocol MainTabBarViewModelDelegate: AnyObject {
    func updateRecipeUI(_ recipe: Recipe?)
    func updatePantryUI(_ pantry: PantryModel)
    func updateListUI()
}

final class MainTabBarViewModel {
    
    weak var router: RootRouter?
    weak var delegate: MainTabBarViewModelDelegate?
    
    private var isRightHanded: Bool
    private let viewControllers: [UIViewController]
    private(set) var outOfStocks: [Stock] = []
    private let stocksUpdateHours = 7
    
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
        DispatchQueue.main.async {
            self.router?.goToCreateNewRecipe(compl: { [weak self] recipe in
                self?.delegate?.updateRecipeUI(recipe)
            })
        }
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
    
    func showSearch(_ selectedController: UIViewController?) {
        if selectedController == router?.listNavController {
            router?.goToSearchInList()
        } else if selectedController is MainRecipeViewController {
            router?.goToSearchInRecipe()
        }
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
    
    func showPantryStarterPack() {
#if RELEASE
        if !UserDefaultsManager.isShowPantryStarterPack {
            router?.goToPantryStarterPack()
            UserDefaultsManager.isShowPantryStarterPack = true
        } else if !Apphud.hasActiveSubscription() {
            router?.goToPantryStarterPack()
        }
#endif
    }
    
    func showStockReminderIfNeeded() {
        let today = Date()
        checkThatItemIsOutOfStock()
        if today.todayWithSetting(hour: stocksUpdateHours) <= today,
           isShowStockReminderRequired(),
            !outOfStocks.isEmpty {
            router?.goToStockReminder(outOfStocks: outOfStocks,
                                      updateUI: { [weak self] in
                self?.delegate?.updateListUI()
            })
            
            UserDefaultsManager.lastShowStockReminderDate = today.todayWithSetting(hour: stocksUpdateHours)
        }
    }
    
    func groceryAnalytics() {
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
    
    func pantryAnalytics() {
        let lists = CoreDataManager.shared.getAllPantries() ?? []
        let stocks = CoreDataManager.shared.getAllStock() ?? []
        let stocksReminder = stocks.filter { $0.isReminder }
        
        AmplitudeManager.shared.setUserProperty(properties: ["pantry_list_count": lists.count])
        AmplitudeManager.shared.setUserProperty(properties: ["pantry_items_count": stocks.count])
        AmplitudeManager.shared.setUserProperty(properties: ["pantry_reminders_count": stocksReminder.count])
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
    
    private func checkThatItemIsOutOfStock() {
        let today = Date()
        let allStocks = CoreDataManager.shared.getAllStock() ?? []
        let reminderStock = allStocks.filter { $0.isReminder }
        let dbStock = reminderStock.filter({ !$0.isAvailability })

        var outOfStocks = dbStock.map({ Stock(dbModel: $0) })
        
        for stock in outOfStocks {
            guard let autoRepeat = stock.autoRepeat else { break }
            let startDate = stock.dateOfCreation.onlyDate
            let resetDay = today.todayWithSetting(hour: 7)
            switch autoRepeat.state {
            case .daily:
                self.outOfStocks.append(stock)
            case .weekly:
                if startDate.dayNumberOfWeek == today.dayNumberOfWeek {
                    self.outOfStocks.append(stock)
                }
            case .monthly:
                if startDate.day == today.day {
                    self.outOfStocks.append(stock)
                }
            case .yearly:
                if startDate.month == today.month,
                   startDate.day == today.day {
                    self.outOfStocks.append(stock)
                }
            case .custom:
                if checkCustomAutoRepeat(autoRepeat: autoRepeat,
                                         today: today, startDate: startDate) {
                    self.outOfStocks.append(stock)
                }
            }
        }
    }
    
    private func checkCustomAutoRepeat(autoRepeat: AutoRepeatModel,
                                       today: Date, startDate: Date) -> Bool {
        guard autoRepeat.state == .custom,
              let period = autoRepeat.period else {
            return false
        }

        let times = (autoRepeat.times ?? 1) + 1
        switch period {
        case .days:
            let days = today.days(sinceDate: startDate)
            if days > 0 {
                return days % times == 0
            }
        case .weeks:
            let weekDates = Date().getListDatesOfWeek(date: startDate)
            guard let weekday = autoRepeat.weekday,
                  let startWeekDate = weekDates[safe: weekday] else {
                return false
            }
            if startWeekDate.dayNumberOfWeek == today.dayNumberOfWeek {
                let weeks = today.weeks(from: startWeekDate)
                if weeks >= 0 {
                    return weeks % times == 0
                }
            }
        case .months:
            let months = today.months(from: startDate)
            if months > 0 && months % times == 0 {
                return today.day == startDate.day
            }
        case .years:
            let years = today.years(from: startDate)
            if years > 0 && years % times == 0 {
                return today.day == startDate.day && today.month == startDate.month
            }
        }
        return false
    }
}
