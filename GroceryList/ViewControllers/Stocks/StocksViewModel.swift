//
//  StocksViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.06.2023.
//

import UIKit

final class StocksViewModel {
    
    weak var router: RootRouter?
    var reloadData: (() -> Void)?
    var editState: (() -> Void)?
    var updateController: (() -> Void)?
        
    private var colorManager = ColorManager()
    private var dataSource: StocksDataSource
    private var pantry: PantryModel
    
    init(dataSource: StocksDataSource, pantry: PantryModel) {
        self.dataSource = dataSource
        self.pantry = pantry
        
        self.dataSource.reloadData = { [weak self] in
            self?.reloadData?()
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
        let stockCount = pantry.stock.count.asString
        let outOfStock = pantry.stock.filter { !$0.isAvailability }.count
        let outOfStockCount = outOfStock == 0 ? "" : outOfStock.asString
        
        return (total: stockCount, outOfStocks: outOfStockCount)
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
        
        return StockCell.CellModel(theme: theme, name: model.name,
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
            self.updateController?()
        }, editCallback: { [weak self] content in
            guard let self else {
                return
            }
            switch content {
            case .edit:
                self.editState?()
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
