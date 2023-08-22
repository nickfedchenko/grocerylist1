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
        productType.title
    }
    
    private var model: GroceryListsModel
    private var allContent = TableViewContent.allCases
    private var productType: ProductType
    
    init(model: GroceryListsModel, productType: ProductType) {
        self.model = model
        self.productType = productType
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
        let typeOfSorting = productType == .products ? model.typeOfSorting
        : model.typeOfSortingPurchased
        switch content {
        case .byUsers:      return typeOfSorting == SortingType.user.rawValue
        case .byCategory:   return typeOfSorting == SortingType.category.rawValue
        case .byTime:       return typeOfSorting == SortingType.time.rawValue
        case .byRecipe:     return typeOfSorting == SortingType.recipe.rawValue
        case .byAlphabet:   return typeOfSorting == SortingType.alphabet.rawValue
        case .byStore:      return typeOfSorting == SortingType.store.rawValue
        }
    }
    
    override func cellSelected(at ind: Int) {
        guard let content = allContent[safe: ind] else { return }
        var sortingType: SortingType = .category
        switch content {
        case .byCategory:
            AmplitudeManager.shared.logEvent(.setSortCategory)
            sortingType = .category
        case .byAlphabet:
            AmplitudeManager.shared.logEvent(.setSortAbc)
            sortingType = .alphabet
        case .byTime:
            AmplitudeManager.shared.logEvent(.setSortTime)
            sortingType = .time
        case .byRecipe:
            AmplitudeManager.shared.logEvent(.setSortRecipe)
            sortingType = .recipe
        case .byUsers:
            sortingType = .user
        case .byStore:
#if RELEASE
            guard Apphud.hasActiveSubscription() else {
                showPaywall()
                return
            }
#endif
            sortingType = .store
        }
        
        if productType == .products {
            model.typeOfSorting = sortingType.rawValue
        } else {
            model.typeOfSortingPurchased = sortingType.rawValue
        }
        
        savePatametrs()
    }
    
    func updateSortOrder() {
        updateModel?(model)
    }
    
    func showPaywall() {
        router?.showPaywallVC()
    }
    
    func toggleIsAscendingOrder() {
        switch productType {
        case .products:
            model.isAscendingOrder = !model.isAscendingOrder
        case .purchased:
            let isAscendingOrder = getIsAscendingOrder()
            let isAscendingOrderPurchased: BoolWithNilForCD = !isAscendingOrder ? .itsTrue : .itsFalse
            model.isAscendingOrderPurchased = isAscendingOrderPurchased
        }
        savePatametrs()
    }
    
    func getIsAscendingOrder() -> Bool {
        switch productType {
        case .products:
            return model.isAscendingOrder
        case .purchased:
            return model.isAscendingOrderPurchased.getBool(defaultValue: model.isAscendingOrder)
        }
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
        CloudManager.saveCloudData(groceryList: model)
    }
}

extension ProductsSortViewModel {
    enum ProductType {
        case products
        case purchased
        
        var title: String {
            switch self {
            case .products:     return R.string.localizable.sorting()
            case .purchased:    return R.string.localizable.purchased()
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
            case .byStore:          return R.string.localizable.byStore()
            }
        }
    }
}
