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
    
    func goBackButtonPressed() {
        router?.pop()
    }
}

final class StocksDataSource {
    
    var reloadData: (() -> Void)?

    private(set) var stocks: [Stock] = []
    
    init(stocks: [Stock]) {
        self.stocks = stocks
    }
    
}
