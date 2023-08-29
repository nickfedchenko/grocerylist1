//
//  SharedPantryManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 08.06.2023.
//

import Foundation
import Kingfisher

class SharedPantryManager {

    static let shared = SharedPantryManager()
    var router: RootRouter?
    var sharedListsUsers: [String: [User]] = [:]
    
    private let network = NetworkEngine()
    private var newListId: String?
    private var isNewListId = false
    
    private var tokens: [String] {
        get { UserDefaultsManager.shared.pantryUserTokens ?? [] }
        set {
            UserDefaultsManager.shared.pantryUserTokens = newValue
            CloudManager.shared.saveCloudSettings()
        }
    }

    deinit {
        print("SharedPantryManager Deinited")
    }

    /// получаем токен и обрабатываем событие
    func gottenDeeplinkToken(token: String) {
        tokens.append(token)
        if let user = UserAccountManager.shared.getUser() {
            connectToPantryList(userToken: user.token, token: token)
        } else {
            router?.goToSharingPopUp()
        }
    }

    func connectToListAfterRegistration() {
        if let user = UserAccountManager.shared.getUser() {
            fetchMyPantryLists()
            tokens.forEach { connectToPantryList(userToken: user.token, token: $0) }
        }
    }

    /// подписываемся на лист
    private func connectToPantryList(userToken: String, token: String) {
        NotificationCenter.default.post(name: .sharedPantryListLoading, object: nil)
        isNewListId = true
        
        network.pantryListRelease(userToken: userToken,
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
                    self?.fetchMyPantryLists()
                }
            }
        }
    }

    /// получаем список листов на которые подписаны
    func fetchMyPantryLists() {
        guard let user = UserAccountManager.shared.getUser() else {
            return
        }
        network.fetchMyPantryLists(userToken: user.token) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                self.transformSharedModelsToLocal(response: response)
//                self.showStockViewController()
            }
        }
    }

    // MARK: - сохранение листа из сокета
    func saveListFromSocket(response: SocketPantryResponse) {
        appendToUsersDict(id: response.listId, users: response.listUsers)
        
        var localList = transform(sharedList: response.pantryList)
        let dbList = CoreDataManager.shared.getPantry(id: response.pantryList.id.uuidString)
        localList.sharedId = response.listId
        localList.isShowImage = BoolWithNilForCD(rawValue: dbList?.isShowImage ?? 0) ?? .nothing
        localList.synchronizedLists = (try? JSONDecoder().decode([UUID].self,
                                                                 from: dbList?.synchronizedLists ?? Data())) ?? []
        localList.isVisibleCost = dbList?.isVisibleCost ?? false
        
        CoreDataManager.shared.removeSharedPantryList(by: localList.sharedId)
        
        CoreDataManager.shared.savePantry(pantry: [localList])
        CloudManager.shared.saveCloudData(pantryModel: localList)
        CoreDataManager.shared.saveStock(stock: localList.stock, for: localList.id.uuidString)
        localList.stock.forEach { stock in
            CloudManager.shared.saveCloudData(stock: stock)
        }
        
        NotificationCenter.default.post(name: .sharedPantryDownloadedAndSaved, object: nil)
//        if isNewListId {
//            self.newListId = list.id.uuidString
//            showProductViewController()
//        }
    }
    
    // MARK: - удаление листа из сокета
    func deleteListFromSocket(response: SocketDeleteResponse) {
        CoreDataManager.shared.removeSharedPantryList(by: response.listId)
        NotificationCenter.default.post(name: .sharedListDownloadedAndSaved, object: nil)
    }

    private func removeProductsIfNeeded(list: PantryModel) {
        let products = CoreDataManager.shared.getProducts(for: list.id.uuidString)

        var arrayOfLocalProductId: [UUID?] = []
        products.forEach({ product in
            arrayOfLocalProductId.append(product.id)
        })

        var newArrayOfProducts: [UUID?] = []
        list.stock.forEach({ product in
            newArrayOfProducts.append(product.id)
        })

        let arrayToDelete = arrayOfLocalProductId.filter { !newArrayOfProducts.contains($0) }

        arrayToDelete.forEach { id in
            guard let id else { return }
            CoreDataManager.shared.deleteStock(by: id)
        }
    }

    // MARK: - отписка от списка
    func unsubscribeFromPantryList(pantryId: String) {
        guard let user = UserAccountManager.shared.getUser() else {
            return
        }
        network.pantryListUserDelete(userToken: user.token,
                                     pantryId: pantryId) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                print(result)
            }
        }
    }

    // MARK: - Delete grocery list
    func deletePantryList(pantryId: String) {
        guard let user = UserAccountManager.shared.getUser() else {
            return
        }
        network.pantryListDelete(userToken: user.token,
                                 pantryId: pantryId) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                print(result)
            }
        }
    }

    // MARK: - Fetch grocery list users
    func fetchPantryListUsers(pantryId: String,
                              completion: @escaping ((FetchPantryListUsersResponse) -> Void)) {
        guard let user = UserAccountManager.shared.getUser() else {
            return
        }
        network.fetchPantryListUsers(userToken: user.token,
                                     pantryId: pantryId) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                completion(result)
                print(result)
            }
        }
    }

    // MARK: - Update pantry list
    func updatePantryList(pantryId: String) {
        guard let domainList = CoreDataManager.shared.getPantry(id: pantryId) else {
            return
        }
        var localList = PantryModel(dbModel: domainList)

        guard let user = UserAccountManager.shared.getUser(),
              localList.isShared else {
            return
        }

        localList.stock.enumerated().forEach { index, stock in
            if stock.userToken == nil {
                localList.stock[index].userToken = user.token
            }
        }
        
        network.updatePantry(userToken: user.token,
                             pantryId: localList.sharedId,
                             pantryModel: localList) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                print(result)
            }
        }
    }

    // MARK: - Share grocery list

    func sharePantry(pantry: PantryModel, compl: ((String) -> Void)?) {
        guard let user = UserAccountManager.shared.getUser() else {
            return
        }
        let sharedId = pantry.sharedId.isEmpty ? nil : pantry.sharedId
        
        var pantry = pantry
        pantry.stock.enumerated().forEach { index, stock in
            if stock.userToken == nil {
                pantry.stock[index].userToken = user.token
            }
        }
        
        network.sharePantry(userToken: user.token,
                            pantryId: sharedId, pantryModel: pantry) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                let deepLinkToken = response.url
                compl?(deepLinkToken)
                self?.fetchMyPantryLists()
            }
        }
    }

    // MARK: - преобразуем нетворк модели в локальные
    private func transformSharedModelsToLocal(response: FetchMyPantryListsResponse) {
        var arrayOfLists: [PantryModel] = []

        response.items.forEach { sharedModel in
            appendToUsersDict(id: sharedModel.pantryListId, users: sharedModel.users)
            let sharedList = sharedModel.pantryList
            var localList = transform(sharedList: sharedList)
            let dbList = CoreDataManager.shared.getPantry(id: localList.id.uuidString)
            localList.sharedId = sharedModel.pantryListId
            
            localList.isShowImage = BoolWithNilForCD(rawValue: dbList?.isShowImage ?? 0) ?? .nothing
            localList.synchronizedLists = (try? JSONDecoder().decode([UUID].self,
                                                                     from: dbList?.synchronizedLists ?? Data())) ?? []
            localList.isVisibleCost = dbList?.isVisibleCost ?? false
            arrayOfLists.append(localList)
        }

        CoreDataManager.shared.removeSharedPantryLists()
        CoreDataManager.shared.savePantry(pantry: arrayOfLists)
        
        arrayOfLists.forEach { list in
            CoreDataManager.shared.saveStock(stock: list.stock, for: list.id.uuidString)
            list.stock.forEach { stock in
                CloudManager.shared.saveCloudData(stock: stock)
            }
        }

        NotificationCenter.default.post(name: .sharedPantryDownloadedAndSaved, object: nil)
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
    
    private func showStockViewController() {
        if !(self.router?.topViewController is StocksViewController),
           let newListId = self.newListId,
           let dbModel = CoreDataManager.shared.getPantry(id: newListId) {
            let model = PantryModel(dbModel: dbModel)
            self.router?.popToRoot()
//               self.router?.goToStocks(navController: UIViewController, pantry: model)
            self.newListId = nil
            isNewListId = false
        }
    }

    /// трансформим временную модель в постоянную
    func transform(sharedList: SharedPantryModel) -> PantryModel {
        var stocks: [Stock] = []

        sharedList.stock.forEach { sharedStock in
            let localStock = transform(sharedStock: sharedStock)
            stocks.append(localStock)
        }

        let dateOfListCreation = Date(timeIntervalSinceReferenceDate: sharedList.dateOfCreation)
        var pantry = PantryModel(sharedList: sharedList, stock: stocks)
        pantry.dateOfCreation = dateOfListCreation
        return pantry
    }

    /// трансформим временную модель в постоянную
    private func transform(sharedStock: SharedStock) -> Stock {
        let dateOfProductCreation = Date(timeIntervalSinceReferenceDate: sharedStock.dateOfCreation)
        var userToken = sharedStock.userToken ?? "0"
        var cost = -1.0
        var quantity = -1.0
        var store: Store? = Store(title: "")
        if let stock = CoreDataManager.shared.getStock(by: sharedStock.id) {
            cost = stock.cost
            quantity = stock.quantity
            store = (try? JSONDecoder().decode(Store.self, from: stock.store ?? Data()))
            if let token = stock.userToken {
                userToken = token
            }
        }
        var stock = Stock(sharedStock: sharedStock)
        stock.dateOfCreation = dateOfProductCreation
        stock.cost = cost
        stock.quantity = quantity
        stock.store = store
        stock.userToken = userToken
        return stock
    }
}
