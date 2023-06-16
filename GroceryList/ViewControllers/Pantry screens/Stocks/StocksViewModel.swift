//
//  StocksViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.06.2023.
//

import ApphudSDK
import UIKit

protocol StocksViewModelDelegate: AnyObject {
    func reloadData()
    func editState()
    func updateController()
    func updateUIEditTabBar()
    func popController()
    func updateLinkButton()
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
    
    var necessaryOffsetToLink: Double {
        dataSource.stocks.isEmpty ? 0 : Double(dataSource.stocks.count * 56)
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
    
    var lastIndex: IndexPath {
        IndexPath(item: dataSource.stocks.count - 1, section: 1)
    }
    
    func getStocks() -> [PantryStocks] {
        return [
            PantryStocks(name: R.string.localizable.outOfStock(), stock: dataSource.outOfStock, typeOFCell: .outOfStock),
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
    
    func getCostCellModel(model: Stock) -> StockCell.CostCellModel {
        var isVisibleCost = false
#if RELEASE
        if Apphud.hasActiveSubscription() {
            isVisibleCost = model.isVisibleСost
        }
#endif
        
        let newLine = (model.description?.count ?? 0 + (model.store?.title.count ?? 0)) > 30 && isVisibleCost
        let theme = colorManager.getGradient(index: pantry.color)
        let productCost = calculateCost(quantity: model.quantity, cost: model.cost)
        
        return StockCell.CostCellModel(isVisible: isVisibleCost,
                                       isAddNewLine: newLine,
                                       color: theme.medium,
                                       storeTitle: model.store?.title,
                                       costValue: productCost)
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
            self.dataSource.updateStocks()
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
    
    func goToSelectList(presentedController: UIViewController?, contentViewHeigh: Double) {
        router?.showSelectList(presentedController: presentedController,
                               contentViewHeigh: contentViewHeigh,
                               synchronizedLists: pantry.synchronizedLists,
                               updateUI: { [weak self] uuids in
            guard let self else {
                return
            }
            self.delegate?.updateLinkButton()
            self.pantry.synchronizedLists = uuids
            CoreDataManager.shared.savePantry(pantry: [self.pantry])
        })
    }
    
    func updateStockStatus(stock: Stock) {
        dataSource.updateStockStatus(stock: stock)
        updateSharedPantryList()
    }
    
    func sortIsAvailability() {
        sortByOutOfStock.toggle()
        AmplitudeManager.shared.logEvent(.pantryOutButton, properties: [.isActive: sortByOutOfStock ? .valueOn : .off])
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
        let pantry = R.string.localizable.pantryName(pantryName)
        list += pantry
        
        let stocks = dataSource.stocks.filter { $0.isAvailability }
        let outOfStocks = dataSource.stocks.filter { !$0.isAvailability }
        
        list += R.string.localizable.outOfStock().uppercased() + newLine
        outOfStocks.forEach {
            list += tab + $0.name.firstCharacterUpperCase() + newLine
        }
        list += newLine
        
        list += R.string.localizable.inStock().uppercased() + newLine
        stocks.forEach {
            list += tab + $0.name.firstCharacterUpperCase() + newLine
        }
        
        return list
    }
    
    private func calculateCost(quantity: Double?, cost: Double?) -> Double? {
        guard quantity != 0 && cost != 0 else {
            return nil
        }
        
        guard let cost else {
            return nil
        }
        
        if let quantity {
            if quantity == 0 {
                return cost
            }
            return quantity * cost
        } else {
            return cost
        }
    }
}
