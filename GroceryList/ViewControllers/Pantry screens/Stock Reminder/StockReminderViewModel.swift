//
//  StockReminderViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 10.06.2023.
//

import UIKit

final class StockReminderViewModel {
    
    weak var router: RootRouter?
    var updateUI: (() -> Void)?
    var reloadData: (() -> Void)?
    
    private let dataSource: StockReminderDataSource
    private let colorManager = ColorManager()
    
    init(dataSource: StockReminderDataSource) {
        self.dataSource = dataSource
        
        self.dataSource.reloadData = { [weak self] in
            self?.reloadData?()
        }
        
        AmplitudeManager.shared.logEvent(.pantryReminderWorked)
    }
    
    var stocks: [Stock] {
        dataSource.outOfStocks
    }
    
    var necessaryHeight: Double {
        stocks.isEmpty ? 0 : Double(stocks.count * 56)
    }
    
    func getCellModel(model: Stock) -> StockCell.CellModel {
        let theme = colorManager.getGradientForStockReminder()
        var image: UIImage?
        if let imageData = model.imageData {
            image = UIImage(data: imageData)
        }
        
        return StockCell.CellModel(state: .normal,
                                   theme: theme, name: model.name,
                                   description: model.description, image: image,
                                   isRepeat: model.isAutoRepeat, isReminder: model.isReminder,
                                   inStock: model.isAvailability)
    }
    
    func updateStockStatus(stock: Stock) {
        dataSource.updateStockStatus(stock: stock)
        
        SharedPantryManager.shared.updatePantryList(pantryId: stock.pantryId.uuidString)
        AmplitudeManager.shared.logEvent(.pantryReminderCheckbox)
    }
    
    func showSyncList(contentViewHeigh: Double) {
        AmplitudeManager.shared.logEvent(.pantryReminderAddToList)
        router?.showSelectList(contentViewHeigh: contentViewHeigh,
                               synchronizedLists: [],
                               updateUI: { [weak self] uuids in
            self?.dataSource.saveListIds(uuids: uuids)
        })
    }
    
    func dismissView() {
        updateUI?()
    }
}
