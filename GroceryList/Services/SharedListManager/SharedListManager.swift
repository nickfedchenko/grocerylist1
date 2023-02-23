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
    
    init() {
        self.network = NetworkEngine()
        self.modelTransformer = DomainModelsToLocalTransformer()
    }

    deinit {
        print("sharedListManagerDeinited")
    }

    /// получаем токен и обрабатываем событие
    func gottenDeeplinkToken(token: String) {
        if let user = UserAccountManager.shared.getUser() {
            connectToList(userToken: user.token, token: token)
        } else {
            router?.goToSharingPopUp()
        }
    }
    
    /// подписываемся на лист
    private func connectToList(userToken: String, token: String) {
        NetworkEngine().groceryListRelease(userToken: userToken,
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
    
    // MARK: - отписка от списка
    func unsubscribeFromGroceryList(listId: String) {
        guard let user = UserAccountManager.shared.getUser() else { return }
        NetworkEngine().groceryListUserDelete(userToken: user.token,
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
        NetworkEngine().groceryListDelete(userToken: user.token,
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
    func fetchGroceryListUsers(listId: String) {
        guard let user = UserAccountManager.shared.getUser() else { return }
        NetworkEngine().fetchGroceryListUsers(userToken: user.token,
                                              listId: listId) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                print(result)
            }
        }
    }
    
    // MARK: - Update grocery list
    func updateGroceryList(listModel: GroceryListsModel) {
        guard let domainList = CoreDataManager.shared.getList(list: listModel.id.uuidString) else { return }
        let localList = modelTransformer.transformCoreDataModelToModel(domainList)
        
        guard let user = UserAccountManager.shared.getUser(), listModel.isShared == true else { return }
      
        NetworkEngine().updateGroceryList(userToken: user.token,
                                          listId: listModel.sharedId, listModel: localList) { result in
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
      
        network.shareGroceryList(userToken: user.token,
                                         listId: nil, listModel: listModel) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                let deepLinkToken = "groceryList://share?token=" + response.sharingToken
                compl?(deepLinkToken)
                self?.fetchMyGroceryLists()
            }
        }
    }
    
    // MARK: - преобразуем нетворк модели в локальные
    private func transformSharedModelsToLocal(response: FetchMyGroceryListsResponse) {
        var arrayOfLists: [GroceryListsModel] = []
    
        response.items.forEach { sharedModel in
            let sharedList = sharedModel.groceryList
            var localList = transform(sharedList: sharedList)
            localList.isShared = true
            localList.sharedId = sharedModel.groceryListId
            localList.isSharedListOwner = sharedModel.isOwner
            arrayOfLists.append(localList)
        }
        
        print(arrayOfLists)
        
        arrayOfLists.forEach { list in
            CoreDataManager.shared.removeSharedLists()
            CoreDataManager.shared.saveList(list: list)
            list.products.forEach { product in
                CoreDataManager.shared.createProduct(product: product)
            }
        }
        UserDefaultsManager.coldStartState = 2
        NotificationCenter.default.post(name: .sharedListDownloadedAndSaved, object: nil)

    }
    
    /// трансформим временную модель в постоянную
    private func transform(sharedList: SharedGroceryList) -> GroceryListsModel {
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
                                 typeOfSorting: sharedList.typeOfSorting)
    }
    
    /// трансформим временную модель в постоянную
    private func transform(sharedProduct: SharedProduct) -> Product {
        let dateOfProductCreation = Date(timeIntervalSinceReferenceDate: sharedProduct.dateOfCreation)
        return Product(id: sharedProduct.id,
                       listId: sharedProduct.listId,
                       name: sharedProduct.name,
                       isPurchased: sharedProduct.isPurchased,
                       dateOfCreation: dateOfProductCreation,
                       category: sharedProduct.category,
                       isFavorite: sharedProduct.isFavorite,
                       isSelected: sharedProduct.isSelected,
                       imageData: sharedProduct.imageData,
                       description: sharedProduct.description,
                       fromRecipeTitle: sharedProduct.fromRecipeTitle)
    }
}
