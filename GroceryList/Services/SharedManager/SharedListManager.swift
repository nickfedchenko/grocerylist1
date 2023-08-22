//
//  SharedListManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.02.2023.
//

import Foundation
import Kingfisher

class SharedListManager {

    static let shared = SharedListManager()
    var router: RootRouter?
    var sharedListsUsers: [String: [User]] = [:]
    
    private var network: NetworkEngine
    private var modelTransformer: DomainModelsToLocalTransformer
    private var newListId: String?
    private var isNewListId = false
    private var tokens: [String] {
        get { UserDefaultsManager.shared.userTokens ?? [] }
        set { UserDefaultsManager.shared.userTokens = newValue }
    }

    init() {
        self.network = NetworkEngine()
        self.modelTransformer = DomainModelsToLocalTransformer()
    }

    deinit {
        print("sharedListManagerDeinited")
    }

    /// получаем токен и обрабатываем событие
    func gottenDeeplinkToken(token: String) {
        tokens.append(token)
        if let user = UserAccountManager.shared.getUser() {
            connectToList(userToken: user.token, token: token)
        } else {
            router?.goToSharingPopUp()
        }
    }

    func connectToListAfterRegistration() {
        if let user = UserAccountManager.shared.getUser() {
            fetchMyGroceryLists()
            tokens.forEach { connectToList(userToken: user.token, token: $0) }
        }
    }

    /// подписываемся на лист
    private func connectToList(userToken: String, token: String) {
        NotificationCenter.default.post(name: .sharedListLoading, object: nil)
        isNewListId = true
        network.groceryListRelease(userToken: userToken,
                                   sharingToken: token) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                print(result)
                if let listId = result.id {
                    self.newListId = listId
                }
                DispatchQueue.main.async { [weak self] in
                    self?.fetchMyGroceryLists()
                }
            }
        }
    }

    /// получаем список листов на которые подписаны
    func fetchMyGroceryLists() {
        guard let user = UserAccountManager.shared.getUser() else { return }
        network.fetchMyGroceryLists(userToken: user.token) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                self.transformSharedModelsToLocal(response: response)
                self.showProductViewController()
            }
        }
    }

    // MARK: - сохранение листа из сокета
    func saveListFromSocket(response: SocketResponse) {
        var list = transform(sharedList: response.groceryList)
        let dbList = CoreDataManager.shared.getList(list: list.id.uuidString)
        list.isShared = true
        list.sharedId = response.listId
        list.isVisibleCost = dbList?.isVisibleCost ?? false
        list.isAutomaticCategory = dbList?.isAutomaticCategory ?? true
        list.typeOfSortingPurchased = Int(dbList?.typeOfSortingPurchased ?? 0)
        list.isAscendingOrderPurchased = BoolWithNilForCD(rawValue: dbList?.isAscendingOrderPurchased ?? 0) ?? .nothing
        list.isAscendingOrder = dbList?.isAscendingOrder ?? true
        removeProductsIfNeeded(list: list)
        
        CoreDataManager.shared.saveList(list: list)
        CloudManager.saveCloudData(groceryList: list)
        
        list.products.forEach { product in
            CoreDataManager.shared.createProduct(product: product)
            CloudManager.saveCloudData(product: product)
        }
        
        appendToUsersDict(id: response.listId, users: response.listUsers)
        
        NotificationCenter.default.post(name: .sharedListDownloadedAndSaved, object: nil)
        if isNewListId {
            self.newListId = list.id.uuidString
            showProductViewController()
        }
    }
    
    // MARK: - удаление листа из сокета
    func deleteListFromSocket(response: SocketDeleteResponse) {
        CoreDataManager.shared.removeSharedList(by: response.listId)
        NotificationCenter.default.post(name: .sharedListDownloadedAndSaved, object: nil)
    }

    private func removeProductsIfNeeded(list: GroceryListsModel) {
        let products = CoreDataManager.shared.getProducts(for: list.id.uuidString)

        var arrayOfLocalProductId: [(id: UUID?, recordId: String?)] = []
        products.forEach({ product in
            arrayOfLocalProductId.append((product.id, product.recordId))
        })

        var newArrayOfProducts: [UUID?] = []
        list.products.forEach({ product in
            newArrayOfProducts.append(product.id)
        })
        
        let arrayToDelete = arrayOfLocalProductId.filter { !newArrayOfProducts.contains($0.id) }
        
        arrayToDelete.forEach { product in
            guard let id = product.id?.uuidString else { return }
            CoreDataManager.shared.removeProduct(id: id)
            CloudManager.deleteProduct(recordId: product.recordId ?? "")
        }
    }

    // MARK: - отписка от списка
    func unsubscribeFromGroceryList(listId: String) {
        guard let user = UserAccountManager.shared.getUser() else { return }
        network.groceryListUserDelete(userToken: user.token,
                                              listId: listId) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                print(result)
            }
        }
    }

    // MARK: - Delete grocery list
    func deleteGroceryList(listId: String) {
        let listId = listId == "-1" ? "" : listId
        guard let user = UserAccountManager.shared.getUser() else { return }
        network.groceryListDelete(userToken: user.token,
                                              listId: listId) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                print(result)
            }
        }
    }

    // MARK: - Fetch grocery list users
    func fetchGroceryListUsers(listId: String, completion: @escaping ((FetchGroceryListUsersResponse) -> Void)) {
        guard let user = UserAccountManager.shared.getUser() else { return }
        network.fetchGroceryListUsers(userToken: user.token,
                                              listId: listId) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                completion(result)
                print(result)
            }
        }
    }

    // MARK: - Update grocery list
    func updateGroceryList(listId: String) {
        guard let domainList = CoreDataManager.shared.getList(list: listId) else { return }
        var localList = modelTransformer.transformCoreDataModelToModel(domainList)

        guard let user = UserAccountManager.shared.getUser(),
              localList.isShared == true else { return }

        localList.products.enumerated().forEach { index, product in
            if product.userToken == nil {
                localList.products[index].userToken = user.token
            }
        }
        
        network.updateGroceryList(userToken: user.token,
                                          listId: localList.sharedId, listModel: localList) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                print(result)
            }
        }
    }

    // MARK: - Share grocery list

    func shareGroceryList(listModel: GroceryListsModel, compl: ((String) -> Void)?) {
        guard let user = UserAccountManager.shared.getUser() else { return }
        let sharedId = listModel.sharedId.isEmpty ? nil : listModel.sharedId
        
        var listModel = listModel
        listModel.products.enumerated().forEach { index, product in
            if product.userToken == nil {
                listModel.products[index].userToken = user.token
            }
        }
        
        network.shareGroceryList(userToken: user.token,
                                 listId: sharedId, listModel: listModel) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                let deepLinkToken = response.url
                compl?(deepLinkToken)
                self?.fetchMyGroceryLists()
            }
        }
    }

    // MARK: - преобразуем нетворк модели в локальные
    private func transformSharedModelsToLocal(response: FetchMyGroceryListsResponse) {
        var arrayOfLists: [GroceryListsModel] = []

        response.items.forEach { sharedModel in
            appendToUsersDict(id: sharedModel.groceryListId, users: sharedModel.users)
            let sharedList = sharedModel.groceryList
            var localList = transform(sharedList: sharedList)
            let dbList = CoreDataManager.shared.getList(list: localList.id.uuidString)
            localList.isShared = true
            localList.sharedId = sharedModel.groceryListId
            localList.isSharedListOwner = sharedModel.isOwner
            localList.isShowImage = sharedList.isShowImage ?? .nothing
            localList.isVisibleCost = dbList?.isVisibleCost ?? false
            localList.isAutomaticCategory = dbList?.isAutomaticCategory ?? true
            localList.typeOfSortingPurchased = Int(dbList?.typeOfSortingPurchased ?? 0)
            localList.isAscendingOrderPurchased = BoolWithNilForCD(rawValue: dbList?.isAscendingOrderPurchased ?? 0) ?? .nothing
            localList.isAscendingOrder = dbList?.isAscendingOrder ?? true
            
            arrayOfLists.append(localList)
        }

        CoreDataManager.shared.removeSharedLists()

        arrayOfLists.forEach { list in
            CoreDataManager.shared.saveList(list: list)
            CloudManager.saveCloudData(groceryList: list)
            list.products.forEach { product in
                CoreDataManager.shared.createProduct(product: product)
                CloudManager.saveCloudData(product: product)
            }
        }
        UserDefaultsManager.shared.coldStartState = 2

        NotificationCenter.default.post(name: .sharedListDownloadedAndSaved, object: nil)
    }

    private func appendToUsersDict(id: String, users: [User]) {
        sharedListsUsers[id] = users
        DispatchQueue.main.async {
            users.forEach {
                if let stringUrl = $0.avatar,
                   let url = URL(string: stringUrl) {
                    _ = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
                }
            }
        }
    }
    
    private func showProductViewController() {
        if !(self.router?.topViewController is ProductsViewController),
           let newListId = self.newListId,
           let dbModel = CoreDataManager.shared.getList(list: newListId) {
            let model = DomainModelsToLocalTransformer().transformCoreDataModelToModel(dbModel)
            self.router?.popToRoot()
            self.router?.goProductsVC(model: model, compl: { })
            self.newListId = nil
            isNewListId = false
        }
    }

    /// трансформим временную модель в постоянную
    func transform(sharedList: SharedGroceryList) -> GroceryListsModel {
        var arrayOfProducts: [Product] = []

        sharedList.products.forEach { sharedProduct in
            let localProduct = transform(sharedProduct: sharedProduct)
            arrayOfProducts.append(localProduct)
        }

        let dateOfListCreation = Date(timeIntervalSinceReferenceDate: sharedList.dateOfCreation)

        return GroceryListsModel(id: sharedList.id,
                                 dateOfCreation: dateOfListCreation,
                                 name: sharedList.name,
                                 color: sharedList.color,
                                 isFavorite: sharedList.isFavorite,
                                 products: arrayOfProducts,
                                 typeOfSorting: sharedList.typeOfSorting,
                                 isShared: sharedList.isShared ?? true,
                                 sharedId: sharedList.sharedId ?? "",
                                 isSharedListOwner: sharedList.isSharedListOwner,
                                 isShowImage: sharedList.isShowImage ?? .nothing)
    }

    /// трансформим временную модель в постоянную
    private func transform(sharedProduct: SharedProduct) -> Product {
        let dateOfProductCreation = Date(timeIntervalSinceReferenceDate: sharedProduct.dateOfCreation)
        var userToken = sharedProduct.userToken ?? "0"
        var cost = -1.0
        var quantity = -1.0
        var store: Store? = Store(title: "")
        if let product = CoreDataManager.shared.getProduct(id: sharedProduct.id) {
            cost = product.cost
            quantity = product.quantity
            store = (try? JSONDecoder().decode(Store.self, from: product.store ?? Data()))
            if let token = product.userToken {
                userToken = token
            }
        }
        
        return Product(id: sharedProduct.id,
                       listId: sharedProduct.listId,
                       name: sharedProduct.name,
                       isPurchased: sharedProduct.isPurchased,
                       dateOfCreation: dateOfProductCreation,
                       category: sharedProduct.category ?? "",
                       isFavorite: sharedProduct.isFavorite,
                       isSelected: sharedProduct.isSelected,
                       imageData: sharedProduct.imageData,
                       description: sharedProduct.description ?? "",
                       fromRecipeTitle: sharedProduct.fromRecipeTitle,
                       isUserImage: sharedProduct.isUserImage,
                       userToken: userToken,
                       store: sharedProduct.store ?? store,
                       cost: sharedProduct.cost ?? cost,
                       quantity: sharedProduct.quantity ?? quantity)
    }
}
