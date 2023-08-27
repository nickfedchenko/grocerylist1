//
//  SearchViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.03.2023.
//

import Foundation

final class SearchInListViewModel {
    
    struct SearchList {
        var groceryList: GroceryListsModel
        var products: [Product]
    }
    
    var router: RootRouter?
    var updateData: (() -> Void)?
    var listCount: Int {
        editableLists.count
    }
    
    private var lists: [GroceryListsModel] = []
    private var searchText = ""
    private var editableLists: [SearchList] = [] {
        didSet { updateData?() }
    }
    
    init() {
        updateList()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sharedListDownloaded),
                                               name: .sharedListDownloadedAndSaved, object: nil)
    }
    
    func search(text: String?) {
        editableLists.removeAll()
        var filteredLists: [SearchList] = []
        guard let text = text?.lowercased().trimmingCharacters(in: .whitespaces),
              text.count >= 3 else {
            searchText = ""
            editableLists = filteredLists
            return
        }
        lists.forEach { list in
            let filteredProducts = list.products.filter { $0.name.smartContains(text) }
            if !filteredProducts.isEmpty {
                filteredLists.append(SearchList(groceryList: list,
                                                products: filteredProducts))
            }
        }
        searchText = text
        editableLists = filteredLists
    }
    
    func getList(by index: Int) -> GroceryListsModel? {
        editableLists[safe: index]?.groceryList
    }
    
    func getProducts(by index: Int) -> [Product]? {
        editableLists[safe: index]?.products
    }
    
    func showList(_ list: GroceryListsModel) {
        router?.goProductsVC(model: list, compl: { })
    }
    
    func showSharing(_ list: GroceryListsModel) {
        guard UserAccountManager.shared.getUser() != nil else {
            router?.goToSharingPopUp { [weak self] in
                self?.router?.navigationDismiss()
            }
            return
        }
        let users = SharedListManager.shared.sharedListsUsers[list.sharedId] ?? []
        var shareModel = list
        if let dbModel = CoreDataManager.shared.getList(list: list.id.uuidString),
            let model = GroceryListsModel(from: dbModel) {
            shareModel = model
        }
        router?.goToSharingList(listToShare: shareModel, users: users)
    }
    
    func updatePurchasedStatus(product: Product) {
        var newProduct = product
        newProduct.isPurchased = !product.isPurchased
        CoreDataManager.shared.createProduct(product: newProduct)
        CloudManager.shared.saveCloudData(product: newProduct)
        updateList()
        search(text: searchText)
    }
    
    private func updateList() {
        guard let dbLists = CoreDataManager.shared.getAllLists() else {
            lists = []
            return
        }
        lists = dbLists.compactMap({ GroceryListsModel(from: $0) })
    }
    
    @objc
    private func sharedListDownloaded() {
        updateList()
        search(text: searchText)
    }
}
