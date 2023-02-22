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
    
    init() {
        self.network = NetworkEngine()
    }

    deinit {
        print("sharedListManagerDeinited")
    }

    func gottenDeeplinkToken(token: String) {
        if let user = UserAccountManager.shared.getUser() {
            connectToList(userToken: user.token, token: token)
        } else {
            router?.goToSharingPopUp()
        }
    }
    
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
            let localList = transform(sharedList: sharedList)
            arrayOfLists.append(localList)
        }
        
        print(arrayOfLists)
        
        arrayOfLists.forEach { list in
            CoreDataManager.shared.removeList(list.id)
            CoreDataManager.shared.saveList(list: list)
            list.products.forEach { product in
                CoreDataManager.shared.createProduct(product: product)
            }
        }
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
