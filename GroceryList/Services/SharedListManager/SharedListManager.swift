//
//  SharedListManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.02.2023.
//

import Foundation

class SharedListManager {

    static let shared = SharedListManager()
    var router: RootRouter?
    private var network: NetworkEngine
    private var modelTransformer: DomainModelsToLocalTransformer
    private var tokens: [String] {
        get { UserDefaultsManager.userTokens ?? [] }
        set { UserDefaultsManager.userTokens = newValue }
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
        network.groceryListRelease(userToken: userToken,
                                           sharingToken: token) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                print(result)
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
            }
        }
    }

    var sharedListsUsers: [String: [User]] = [:]

    // MARK: - отписка от списка
    func saveListFromSocket(response: SocketResponse) {
        var list = transform(sharedList: response.groceryList)
        let dbList = CoreDataManager.shared.getList(list: list.id.uuidString)
        list.sharedId = response.groceryList.sharedId ?? ""
        list.isVisibleCost = dbList?.isVisibleCost ?? false
        removeProductsIfNeeded(list: list)
        
        CoreDataManager.shared.saveList(list: list)
        
        list.products.forEach { product in
            CoreDataManager.shared.createProduct(product: product)
        }
        
        appendToUsersDict(id: list.sharedId, users: response.listUsers)
        
        NotificationCenter.default.post(name: .sharedListDownloadedAndSaved, object: nil)
    }

    private func removeProductsIfNeeded(list: GroceryListsModel) {
        let products = CoreDataManager.shared.getProducts(for: list.id.uuidString)

        var arrayOfLocalProductId: [UUID?] = []
        products.forEach({ product in
            arrayOfLocalProductId.append(product.id)
        })

        var newArrayOfProducts: [UUID?] = []
        list.products.forEach({ product in
            newArrayOfProducts.append(product.id)
        })
        
        let arrayToDelete = arrayOfLocalProductId.filter { !newArrayOfProducts.contains($0) }
        
        arrayToDelete.forEach { id in
            guard let id = id?.uuidString else { return }
            CoreDataManager.shared.removeProduct(id: id)
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
            arrayOfLists.append(localList)
        }

        CoreDataManager.shared.removeSharedLists()

        arrayOfLists.forEach { list in
            CoreDataManager.shared.saveList(list: list)
            list.products.forEach { product in
                CoreDataManager.shared.createProduct(product: product)
            }
        }
        UserDefaultsManager.coldStartState = 2

        NotificationCenter.default.post(name: .sharedListDownloadedAndSaved, object: nil)
    }

    private func appendToUsersDict(id: String, users: [User]) {
        sharedListsUsers[id] = users
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
                       category: sharedProduct.category,
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
