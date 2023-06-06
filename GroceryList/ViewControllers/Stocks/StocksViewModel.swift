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
}

final class StocksViewModel {
    
    weak var router: RootRouter?
    weak var delegate: StocksViewModelDelegate?
        
    private var colorManager = ColorManager()
    private var dataSource: StocksDataSource
    private var pantry: PantryModel
    private(set) var stateCellModel: StockCell.CellState = .normal
    private var sort = false
    
    init(dataSource: StocksDataSource, pantry: PantryModel) {
        self.dataSource = dataSource
        self.pantry = pantry
        
        self.dataSource.reloadData = { [weak self] in
            self?.delegate?.reloadData()
        }
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
        let stockCount = dataSource.stocks.count.asString
        let outOfStock = dataSource.stocks.filter { !$0.isAvailability }.count
        let outOfStockCount = outOfStock == 0 ? "" : outOfStock.asString
        
        return (total: stockCount, outOfStocks: outOfStockCount)
    }
    
    var editStocks: [Stock] {
        return dataSource.editStocks
    }
    
    var isSelectedAllStockForEditing: Bool {
        dataSource.stocks.count == dataSource.editStocks.count
    }
    
    func getStocks() -> [Stock] {
        dataSource.stocks
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
        
        if let newUsers = SharedListManager.shared.sharedListsUsers[pantry.sharedId] {
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
        }, editCallback: { [weak self] content in
            guard let self else {
                return
            }
            switch content {
            case .edit:
                self.stateCellModel = .edit
                self.delegate?.editState()
            case .share: break
//                var shareModel = self.pantry
//                if let dbModel = CoreDataManager.shared.getList(list: self.pantry.id.uuidString),
//                   let model = GroceryListsModel(from: dbModel) {
//                    shareModel = model
//                }
//                self.router?.goToSharingList(listToShare: shareModel, users: self.getSharedListsUsers())
            default: break
            }
        })
    }
    
    func goToCreateItem(stock: Stock?) {
        router?.goToCreateNewStockController(pantry: pantry, stock: stock, compl: { [weak self] newStock in
            self?.dataSource.addStock(newStock)
        })
    }
    
    func updateStockStatus(stock: Stock) {
        dataSource.updateStockStatus(stock: stock)
    }
    
    func sortIsAvailability() {
        sort.toggle()
        dataSource.sortByStock(sort)
    }
    
    func updateStocksAfterMove(stocks: [Stock]) {
        dataSource.updateStocksAfterMove(updatedStocks: stocks)
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
//        updateList()
    }
    
    func resetEditProducts() {
        dataSource.resetEditStocks()
        delegate?.updateUIEditTabBar()
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
