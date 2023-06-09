//
//  StocksViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.06.2023.
//

import UIKit

protocol StocksViewModelDelegate: AnyObject {
    func reloadData()
    func editState()
    func updateController()
    func updateUIEditTabBar()
    func popController()
}

final class StocksViewModel {
    
    weak var router: RootRouter?
    weak var delegate: StocksViewModelDelegate?
    
    private(set) var stateCellModel: StockCell.CellState = .normal
    private(set) var sortByOutOfStock = false
    private var colorManager = ColorManager()
    private var dataSource: StocksDataSource
    private var pantry: PantryModel
    
    init(dataSource: StocksDataSource, pantry: PantryModel) {
        self.dataSource = dataSource
        self.pantry = pantry
        
        self.dataSource.isSort = sortByOutOfStock
        self.dataSource.reloadData = { [weak self] in
            self?.delegate?.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(sharedPantryDownloaded),
                                               name: .sharedPantryDownloadedAndSaved, object: nil)
    }
    
    var pantryName: String {
        pantry.name
    }
    
    var pantryIcon: UIImage? {
        var icon: UIImage?
        if let iconData = pantry.icon {
            icon = UIImage(data: iconData)
        }
        return icon
    }
    
    var availabilityOfGoods: (total: String, outOfStocks: String) {
        let stockCount = dataSource.allStocks.count.asString
        let outOfStock = dataSource.allStocks.filter { !$0.isAvailability }.count
        let outOfStockCount = outOfStock == 0 ? "" : outOfStock.asString
        
        return (total: stockCount, outOfStocks: outOfStockCount)
    }
    
    var editStocks: [Stock] {
        return dataSource.editStocks
    }
    
    var isSelectedAllStockForEditing: Bool {
        dataSource.stocks.count == dataSource.editStocks.count
    }
    
    var isEmptyStocks: Bool {
        dataSource.allStocks.isEmpty
    }
    
    var isEmptyOutOfStocks: Bool {
        dataSource.editStocks.isEmpty
    }
    
    func getStocks() -> [PantryStocks] {
        return [
            PantryStocks(name: "out of stock", stock: dataSource.outOfStock, typeOFCell: .outOfStock),
            PantryStocks(name: "", stock: dataSource.stocks, typeOFCell: .normal)
        ]
    }
    
    func getTheme() -> Theme {
        colorManager.getGradient(index: pantry.color)
    }
    
    func getCellModel(model: Stock) -> StockCell.CellModel {
        let theme = colorManager.getGradient(index: pantry.color)
        var image: UIImage?
        if let imageData = model.imageData {
            image = UIImage(data: imageData)
        }
        
        return StockCell.CellModel(state: stateCellModel,
                                   theme: theme, name: model.name,
                                   description: model.description, image: image,
                                   isRepeat: model.isAutoRepeat, isReminder: model.isReminder,
                                   inStock: model.isAvailability)
    }
    
    func getSharingState() -> SharingView.SharingState {
        pantry.isShared ? .added : .invite
    }
    
    func getShareImages() -> [String?] {
        var arrayOfImageUrls: [String?] = []
        
        if let newUsers = SharedPantryManager.shared.sharedListsUsers[pantry.sharedId] {
            newUsers.forEach { user in
                if user.token != UserAccountManager.shared.getUser()?.token {
                    arrayOfImageUrls.append(user.avatar)
                }
            }
        }
        return arrayOfImageUrls
    }
    
    func getSynchronizedListNames() -> [String] {
        let synchronizedLists = pantry.synchronizedLists
        var names: [String] = []
        
        synchronizedLists.forEach { uuid in
            let dbList = CoreDataManager.shared.getList(list: uuid.uuidString)
            if let name = dbList?.name {
                names.append(name)
            }
        }
        
        return names
    }
    
    func goToListOptions(snapshot: UIImage?) {
        router?.goToPantryListOption(pantry: pantry, snapshot: snapshot,
                                     listByText: getListByText(),
                                     updateUI: { [weak self] updatedPantry in
            guard let self else {
                return
            }
            self.pantry = updatedPantry
            self.delegate?.updateController()
            self.updateSharedPantryList()
        }, editCallback: { [weak self] content in
            guard let self else {
                return
            }
            switch content {
            case .edit:
                self.stateCellModel = .edit
                self.delegate?.editState()
            case .share:
                self.sharePantry()
            case .delete:
                SharedPantryManager.shared.deletePantryList(pantryId: self.pantry.sharedId)
                SharedPantryManager.shared.unsubscribeFromPantryList(pantryId: self.pantry.sharedId)
                self.updateSharedPantryList()
                self.delegate?.popController()
            default: break
            }
        })
    }
    
    func goToCreateItem(stock: Stock?) {
        router?.goToCreateNewStockController(pantry: pantry, stock: stock, compl: { [weak self] _ in
            self?.dataSource.updateStocks()
            self?.updateSharedPantryList()
        })
    }
    
    func updateStockStatus(stock: Stock) {
        dataSource.updateStockStatus(stock: stock)
        updateSharedPantryList()
    }
    
    func sortIsAvailability() {
        sortByOutOfStock.toggle()
        dataSource.isSort = sortByOutOfStock
        dataSource.sortByStock()
        dataSource.reloadData?()
    }
    
    func updateStocksAfterMove(stocks: [Stock]) {
        dataSource.updateStocksAfterMove(updatedStocks: stocks)
    }
    
    func sharePantry() {
        guard UserAccountManager.shared.getUser() != nil else {
            router?.goToSharingPopUp()
            return
        }
        
        var shareModel = self.pantry
        if let dbModel = CoreDataManager.shared.getPantry(id: self.pantry.id.uuidString) {
            shareModel = PantryModel(dbModel: dbModel)
        }
        self.router?.goToSharingList(pantryToShare: shareModel, users: self.getSharedListsUsers())
    }
    
    func updateEditState(isEdit: Bool) {
        stateCellModel = isEdit ? .edit : .normal
    }
    
    func updateEditStock(_ stock: Stock) {
        dataSource.updateEditStock(stock)
    }
    
    func addAllProductsToEdit() {
        dataSource.addEditAllStocks()
        delegate?.updateUIEditTabBar()
    }
    
    func moveProducts() {
        deleteProducts()
    }
    
    func showListView(contentViewHeigh: CGFloat,
                      state: EditListState,
                      delegate: EditSelectListDelegate) {
        router?.goToEditSelectPantryList(stocks: editStocks,
                                         contentViewHeigh: contentViewHeigh,
                                         delegate: delegate,
                                         state: state)
    }
    
    func deleteProducts() {
        editStocks.forEach {
            dataSource.delete(stock: $0)
        }
        resetEditProducts()
        delegate?.updateUIEditTabBar()
        updateSharedPantryList()
    }
    
    func resetEditProducts() {
        dataSource.resetEditStocks()
        delegate?.updateUIEditTabBar()
    }
    
    private func getSharedListsUsers() -> [User] {
        return SharedPantryManager.shared.sharedListsUsers[pantry.sharedId] ?? []
    }
    
    @objc
    private func sharedPantryDownloaded() {
        dataSource.updateStocks()
    }
    
    private func updateSharedPantryList() {
        SharedPantryManager.shared.updatePantryList(pantryId: self.pantry.id.uuidString)
    }
    
    private func getListByText() -> String {
        var list = ""
        let newLine = "\n"
        let tab = "  • "
        let pantry = "Pantry: \(pantryName)"
        list += pantry
        
        let stocks = dataSource.stocks.filter { $0.isAvailability }
        let outOfStocks = dataSource.stocks.filter { !$0.isAvailability }
        
        list += "out of stocks".uppercased() + newLine
        outOfStocks.forEach {
            list += tab + $0.name.firstCharacterUpperCase() + newLine
        }
        list += newLine
        
        list += "stocks".uppercased() + newLine
        stocks.forEach {
            list += tab + $0.name.firstCharacterUpperCase() + newLine
        }
        
        return list
    }
}
