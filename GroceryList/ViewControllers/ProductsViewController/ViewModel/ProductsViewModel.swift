//
//  ProductsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import Foundation
import UIKit

protocol ProductsViewModelDelegate: AnyObject {
    func updateController()
    func editProduct()
    func updateUIEditTab()
}

class ProductsViewModel {
    
    weak var router: RootRouter?
    weak var delegate: ProductsViewModelDelegate?
    var valueChangedCallback: (() -> Void)?
    var model: GroceryListsModel
    var dataSource: ProductsDataManager
    var selectedProduct: Product?
    
    private var colorManager = ColorManager()
    
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
    
    var editProducts: [Product] {
        return dataSource.editProducts
    }
    
    var isVisibleImage: Bool {
        switch model.isShowImage {
        case .nothing:      return UserDefaultsManager.isShowImage
        case .switchOn:     return true
        case .switchOff:    return false
        }
    }
    
    var totalCost: Double? {
        dataSource.getTotalCost()
    }
    
    var isVisibleCost: Bool {
        model.isVisibleCost
    }
    
    var isSelectedAllProductsForEditing: Bool {
        dataSource.products.count == dataSource.editProducts.count
    }
    
    func getColorForBackground() -> UIColor {
        colorManager.getGradient(index: model.color).1
    }
    
    func getColorForForeground() -> UIColor {
        colorManager.getGradient(index: model.color).0
    }
    
    func getNameOfList() -> String {
        model.name ?? "..."
    }
    
    func goBackButtonPressed() {
        router?.pop()
        router?.goReviewController()
    }
    
    func getCellIndex(with category: Category) -> Int {
        guard let index = arrayWithSections.firstIndex(of: category ) else { return 0 }
        return index
    }
    
    func settingsTapped(with snapshot: UIImage?) {
        router?.goProductsSettingsVC(snapshot: snapshot, listByText: getListByText(), model: model,
                                     compl: { [weak self] updatedModel, products in
            self?.model = updatedModel
            self?.appendToDataSourceProducts(products: products)
            self?.dataSource.typeOfSorting = SortingType(rawValue: self?.model.typeOfSorting ?? 0) ?? .category
            self?.delegate?.updateController()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.updateList()
            }
        }, editCompl: { [weak self] content in
            guard let self else { return }
            switch content {
            case .edit:
                self.delegate?.editProduct()
            case .share:
                self.router?.goToSharingList(listToShare: self.model, users: self.getSharedListsUsers())
            default: break
            }
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
    
    func updateImage(_ image: UIImage?) {
        selectedProduct?.imageData = image?.jpegData(compressionQuality: 1)
        guard let selectedProduct else {
            return
        }
        dataSource.updateImage(for: selectedProduct)
        valueChangedCallback?()
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
            self?.dataSource.appendCopiedProducts(product: [product])
            self?.updateList()
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
        router?.goToSharingList(listToShare: model, users: users)
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
                      state: EditSelectListViewController.State,
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
        dataSource.createDataSourceArray()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sharedListDownloaded),
            name: .sharedListDownloadedAndSaved,
            object: nil
        )
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
            list += category.name.uppercased() + newLine
            category.products.map { product in
                return tab + product.name.firstCharacterUpperCase() + newLine
            }.forEach { title in
                list += title
            }
            list += newLine
        }
        
        return list
    }
}
