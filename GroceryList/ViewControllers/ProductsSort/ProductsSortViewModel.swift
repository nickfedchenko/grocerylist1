//
//  ProductsSortViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 11.05.2023.
//

import ApphudSDK
import UIKit

class ProductsSortViewModel: ProductsSettingsViewModel {
    
    var updateModel: ((GroceryListsModel) -> Void)?
    var title: String {
        sortType.title
    }
    
    private var model: GroceryListsModel
    private var allContent = TableViewContent.allCases
    private var sortType: SortType
    
    init(model: GroceryListsModel, sortType: SortType) {
        self.model = model
        self.sortType = sortType
        super.init(model: model, snapshot: nil, listByText: "")
        
        allContent = getContentOnSharedList()
    }
    
    override func getNumberOfCells() -> Int {
        return allContent.count
    }
    
    override func getText(at ind: Int) -> String? {
        return allContent[ind].title
    }
    
    override func getImage(at ind: Int) -> UIImage? {
        return allContent[ind].image
    }
    
    override func isCheckmarkActive(at ind: Int) -> Bool {
        guard let content = allContent[safe: ind] else { return false }
        switch content {
        case .byUsers: return model.typeOfSorting == SortingType.user.rawValue
        case .byCategory: return model.typeOfSorting == SortingType.category.rawValue
        case .byTime: return model.typeOfSorting == SortingType.time.rawValue
        case .byRecipe: return model.typeOfSorting == SortingType.recipe.rawValue
        case .byAlphabet: return model.typeOfSorting == SortingType.alphabet.rawValue
        case .byStore: return model.typeOfSorting == SortingType.store.rawValue
        }
    }
    
    override func cellSelected(at ind: Int) {
        guard let content = allContent[safe: ind] else { return }
        switch content {
        case .byUsers:
            model.typeOfSorting = SortingType.user.rawValue
        case .byCategory:
            AmplitudeManager.shared.logEvent(.setSortCategory)
            model.typeOfSorting = SortingType.category.rawValue
        case .byTime:
            AmplitudeManager.shared.logEvent(.setSortTime)
            model.typeOfSorting = SortingType.time.rawValue
        case .byRecipe:
            AmplitudeManager.shared.logEvent(.setSortRecipe)
            model.typeOfSorting = SortingType.recipe.rawValue
        case .byAlphabet:
            AmplitudeManager.shared.logEvent(.setSortAbc)
            model.typeOfSorting = SortingType.alphabet.rawValue
        case .byStore:
#if RELEASE
            guard Apphud.hasActiveSubscription() else {
                showPaywall()
                return
            }
#endif
            model.typeOfSorting = SortingType.store.rawValue
        }
        savePatametrs()
    }
    
    func updateSortOrder() {
        updateModel?(model)
    }
    
    func showPaywall() {
        router?.showAlternativePaywallVC()
    }
    
    private func getContentOnSharedList() -> [TableViewContent] {
        var allContent = TableViewContent.allCases
#if RELEASE
        if Apphud.hasActiveSubscription() && !model.isVisibleCost {
            allContent.removeAll { $0 == .byStore }
        }
#else
        if !model.isVisibleCost {
            allContent.removeAll { $0 == .byStore }
        }
#endif
        guard model.isShared else {
            allContent.removeAll { $0 == .byUsers }
            return allContent
        }
        return allContent
    }
    
    private func savePatametrs() {
        delegate?.reloadController()
        updateModel?(model)
        CoreDataManager.shared.saveList(list: model)
    }
}

extension ProductsSortViewModel {
    enum SortType {
        case products
        case purchased
        
        var title: String {
            switch self {
            case .products:     return "Сортировка"
            case .purchased:    return "Купленные"
            }
        }
    }
    
    enum TableViewContent: Int, CaseIterable {
        case byCategory
        case byTime
        case byAlphabet
        case byStore
        case byUsers
        case byRecipe
        
        var image: UIImage? {
            switch self {
            case .byUsers:          return R.image.byUsers()
            case .byCategory:       return R.image.category()
            case .byRecipe:         return R.image.sortRecipe()
            case .byTime:           return R.image.time()
            case .byAlphabet:       return R.image.abC()
            case .byStore:          return R.image.shops()
            }
        }
        
        var title: String {
            switch self {
            case .byUsers:          return R.string.localizable.byUsers()
            case .byCategory:       return R.string.localizable.byCategory()
            case .byRecipe:         return R.string.localizable.byRecipe()
            case .byTime:           return R.string.localizable.byTime()
            case .byAlphabet:       return R.string.localizable.byAlphabet()
            case .byStore:          return "По магазинам"
            }
        }
    }
}
