//
//  ProductsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import ApphudSDK
import Foundation
import StoreKit
import UIKit

protocol ProductsViewModelDelegate: AnyObject {
    func updateController()
    func editProduct()
    func updateUIEditTab()
    func scrollToNewProduct(indexPath: IndexPath)
}

class ProductsViewModel {
    
    weak var router: RootRouter?
    weak var delegate: ProductsViewModelDelegate?
    var valueChangedCallback: (() -> Void)?
    var model: GroceryListsModel
    var dataSource: ProductsDataManager
    var selectedProduct: Product?
    var isExpandedPurchased = true
    
    private var colorManager = ColorManager.shared
    
    init(model: GroceryListsModel, dataSource: ProductsDataManager) {
        self.dataSource = dataSource
        self.model = model
        
        self.dataSource.dataChangedCallBack = { [weak self] in
            self?.valueChangedCallback?()
        }
        
        self.dataSource.createDataSourceArray()
        addObserver()
    }
    
    var arrayWithSections: [Category] {
        return dataSource.dataSourceArray
    }
    
    var sectionIndexPaths: [Int] {
        dataSource.getSectionIndex()
    }
    
    var editProducts: [Product] {
        return dataSource.editProducts
    }
    
    var isVisibleImage: Bool {
        model.isShowImage.getBool(defaultValue: UserDefaultsManager.shared.isShowImage)
    }
    
    var totalCost: Double? {
        dataSource.getTotalCost()
    }
    
    var isVisibleCost: Bool {
#if RELEASE
        guard Apphud.hasActiveSubscription() else {
            return false
        }
#endif
        return model.isVisibleCost
    }
    
    var isSelectedAllProductsForEditing: Bool {
        dataSource.products.count == dataSource.editProducts.count
    }
    
    func getColorForBackground() -> UIColor {
        colorManager.getGradient(index: model.color).light
    }
    
    func getColorForForeground() -> UIColor {
        colorManager.getGradient(index: model.color).medium
    }
    
    func getDarkColor() -> UIColor {
        colorManager.getGradient(index: model.color).dark
    }
    
    func getNameOfList() -> String {
        model.name ?? "..."
    }
    
    func goBackButtonPressed() {
        router?.popList()
        showRequest()
    }
    
    func getCellIndex(with category: Category) -> Int {
        guard let index = arrayWithSections.firstIndex(of: category ) else { return 0 }
        return index
    }
    
    func setEditState(isEdit: Bool) {
        dataSource.isEditState = isEdit
        dataSource.createDataSourceArray()
    }
    
    func settingsTapped(with snapshot: UIImage?) {
        router?.goProductsSettingsVC(snapshot: snapshot, listByText: getListByText(), model: model,
                                     compl: { [weak self] updatedModel, products in
            self?.model = updatedModel
            self?.appendToDataSourceProducts(products: products)
            self?.delegate?.updateController()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.updateList()
            }
        }, editCompl: { [weak self] content in
            guard let self else { return }
            switch content {
            case .edit:
                self.setEditState(isEdit: true)
                self.delegate?.editProduct()
            case .share:
                var shareModel = self.model
                if let dbModel = CoreDataManager.shared.getList(list: self.model.id.uuidString),
                    let model = GroceryListsModel(from: dbModel) {
                    shareModel = model
                }
                self.router?.goToSharingList(listToShare: shareModel, users: self.getSharedListsUsers())
            default: break
            }
        })
        
    }
    
    func sortTapped(productType: ProductsSortViewModel.ProductType) {
        router?.goToProductSort(model: model, productType: productType,
                                compl: { [weak self] updatedModel in
            self?.model = updatedModel
            var sortingType = SortingType(rawValue: self?.model.typeOfSorting ?? 0) ?? .category
            switch productType {
            case .products:
                self?.dataSource.isAscendingOrder = updatedModel.isAscendingOrder
                self?.dataSource.typeOfSorting = sortingType
            case .purchased:
                sortingType = SortingType(rawValue: self?.model.typeOfSortingPurchased ?? 0) ?? .category
                let isAscendingOrder = updatedModel.isAscendingOrderPurchased
                                                   .getBool(defaultValue: updatedModel.isAscendingOrder)
                self?.dataSource.isAscendingOrderPurchased = isAscendingOrder
                self?.dataSource.typeOfSortingPurchased = sortingType
            }
            self?.delegate?.updateController()
        })
    }
    
    func updatePurchasedStatus(product: Product) {
        dataSource.updatePurchasedStatus(for: product)
        updateList()
    }
    
    func updateFavoriteStatus(for product: Product) {
        dataSource.updateFavoriteStatus(for: product)
        updateList()
    }
    
    func updateStockStatus(product: Product) {
        dataSource.updateStockStatus(for: product)
        updateList()
    }
    
    func updateImage(_ image: UIImage?) {
        selectedProduct?.imageData = image?.jpegData(compressionQuality: 1)
        guard let selectedProduct else {
            return
        }
        dataSource.updateImage(for: selectedProduct)
        valueChangedCallback?()
    }
    
    func updateNameOfList(_ name: String) {
        model.name = name
        CoreDataManager.shared.saveList(list: model)
        CloudManager.shared.saveCloudData(groceryList: model)
        delegate?.updateController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.updateList()
        }
    }
    
    func delete(product: Product) {
        dataSource.delete(product: product)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateList()
        }

    }
    
    func appendToDataSourceProducts(products: [Product]) {
        dataSource.appendCopiedProducts(product: products)
    }
    
    func addNewProductTapped(_ product: Product? = nil) {
        router?.goCreateNewProductController(model: model, product: product, compl: { [weak self] product in
            guard let self else {
                return
            }
            self.dataSource.appendCopiedProducts(product: [product])
            self.updateList()
            if self.arrayWithSections.count != 0 {
                self.delegate?.scrollToNewProduct(indexPath: self.dataSource.getIndexPath(for: product))
            }
        })
    }
    
    func getSharingState() -> SharingView.SharingState {
        model.isShared ? .added : .invite
    }
    
    func getShareImages() -> [String?] {
        var arrayOfImageUrls: [String?] = []
        
        getSharedListsUsers().forEach { user in
            if user.token != UserAccountManager.shared.getUser()?.token {
                arrayOfImageUrls.append(user.avatar)
            }
        }
        return arrayOfImageUrls
    }
    
    func getUserImage(by userToken: String?, isPurchased: Bool) -> String? {
        guard let userToken else {
            return nil
        }
        
        if !isPurchased, model.typeOfSorting == SortingType.user.rawValue {
            return nil
        }
        
        var userImageUrl: String?
        getSharedListsUsers().forEach { user in
            if user.token != UserAccountManager.shared.getUser()?.token && user.token == userToken {
                userImageUrl = user.avatar ?? ""
            }
        }
        return userImageUrl
    }
    
    func getUserImage(by userName: String) -> String? {
        var userImageUrl: String?
        getSharedListsUsers().forEach { user in
            if user.username == userName || user.email == userName {
                userImageUrl = user.avatar ?? ""
            }
        }
        return userImageUrl
    }
    
    func sharingTapped() {
        guard UserAccountManager.shared.getUser() != nil else {
            router?.goToSharingPopUp()
            return
        }
        let users = SharedListManager.shared.sharedListsUsers[model.sharedId] ?? []
        var shareModel = model
        if let dbModel = CoreDataManager.shared.getList(list: model.id.uuidString),
            let model = GroceryListsModel(from: dbModel) {
            shareModel = model
        }
        router?.goToSharingList(listToShare: shareModel, users: users)
    }
    
    func resetEditProducts() {
        dataSource.resetEditProduct()
        delegate?.updateUIEditTab()
    }
    
    func addAllProductsToEdit() {
        dataSource.addEditAllProducts()
        delegate?.updateUIEditTab()
    }
    
    func updateEditProduct(_ product: Product) {
        dataSource.updateEditProduct(product)
    }
    
    func showListView(contentViewHeigh: CGFloat,
                      state: EditListState,
                      delegate: EditSelectListDelegate) {
        router?.goToEditSelectList(products: editProducts,
                                   contentViewHeigh: contentViewHeigh,
                                   delegate: delegate,
                                   state: state)
    }
    
    func moveProducts() {
        deleteProducts()
    }
    
    func deleteProducts() {
        editProducts.forEach {
            dataSource.delete(product: $0)
        }
        resetEditProducts()
        delegate?.updateUIEditTab()
        updateList()
    }
    
    func updateCostVisible(_ isVisible: Bool) {
        model.isVisibleCost = isVisible
        CoreDataManager.shared.saveList(list: model)
        CloudManager.shared.saveCloudData(groceryList: model)
        dataSource.createDataSourceArray()
    }
    
    func isInStock(product: Product) -> Bool {
        product.inStock != nil
    }
    
    func getPantryColor(product: Product) -> Theme? {
        guard let stockId = product.inStock,
              let dbStock = CoreDataManager.shared.getStock(by: stockId),
              let dbPantry = dbStock.pantry else {
            return nil
        }
        
        return colorManager.getGradient(index: Int(dbPantry.color))
    }
    
    func removeInStockInfo(_ product: Product) {
        dataSource.removeInStockInfo(product: product)
    }
    
    func getRecipeTitle(title: String?, isPurchased: Bool) -> Bool {
        guard dataSource.typeOfSorting != .recipe else {
            return false
        }
        guard !(isPurchased && dataSource.typeOfSortingPurchased == .recipe) else {
            return false
        }
        
        return title != nil
    }
    
    func getMealPlanForCell(by planId: UUID?, isPurchased: Bool) -> MealPlan? {
        guard dataSource.typeOfSorting != .recipe else {
            return nil
        }
        guard !(isPurchased && dataSource.typeOfSortingPurchased == .recipe) else {
            return nil
        }

        guard let planId,
              let dbMealPlan = CoreDataManager.shared.getMealPlan(id: planId.uuidString) else {
            return nil
        }
        return MealPlan(dbModel: dbMealPlan)
    }
    
    func getMealPlanForHeader(by product: Product?) -> Date? {
        guard let product,
              let planId = product.fromMealPlan,
              let dbMealPlan = CoreDataManager.shared.getMealPlan(id: planId.uuidString) else {
            return nil
        }
        return MealPlan(dbModel: dbMealPlan).date
    }
    
    @objc
    func reloadStorageData() {
        DispatchQueue.main.async { [weak self] in
            self?.dataSource.createDataSourceArray()
        }
    }
    
    func showPaywall() {
        router?.showPaywallVC()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(sharedListDownloaded),
                                               name: .sharedListDownloadedAndSaved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadStorageData),
                                               name: .cloudProducts, object: nil)
    }
    
    @objc
    private func sharedListDownloaded() {
        dataSource.createDataSourceArray()
    }
    
    private func updateList() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.model.isShared else { return }
            SharedListManager.shared.updateGroceryList(listId: self.model.id.uuidString)
        }
    }
    
    private func getSharedListsUsers() -> [User] {
        return SharedListManager.shared.sharedListsUsers[model.sharedId] ?? []
    }
    
    private func getListByText() -> String {
        var list = ""
        let newLine = "\n"
        let tab = "  • "
        let buy = R.string.localizable.buy().uppercased() + newLine + newLine
        list += buy
        
        arrayWithSections.forEach { category in
            var categoryName = category.name
            if categoryName == "DictionaryFavorite" {
                categoryName = R.string.localizable.favorites()
            }
            if categoryName == "alphabeticalSorted" {
                categoryName = "AlphabeticalSorted".localized
            }
            list += categoryName.uppercased() + newLine
            category.products.map { product in
                return tab + product.name.firstCharacterUpperCase() + newLine
            }.forEach { title in
                list += title
            }
            list += newLine
        }
        
        return list
    }
    
    private func showRequest() {
        guard !UserDefaultsManager.shared.isNativeRateUsShowed, UserDefaultsManager.shared.isFirstListCreated else {
            return
        }
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
        
        UserDefaultsManager.shared.isNativeRateUsShowed = true
    }
}
