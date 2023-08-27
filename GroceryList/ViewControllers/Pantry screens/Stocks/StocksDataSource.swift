//
//  StocksDataSource.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 05.06.2023.
//

import Foundation

final class StocksDataSource {
    
    var reloadData: (() -> Void)?
    var isSort: Bool = false
    
    private(set) var allStocks: [Stock] = []
    private(set) var stocks: [Stock] = []
    private(set) var outOfStock: [Stock] = []
    private(set) var editStocks: [Stock] = []
    private let pantryId: UUID
    
    init(pantryId: UUID) {
        self.pantryId = pantryId
        getStocksFromDB()
    }
    
    func updateStockStatus(stock: Stock) {
        var stock = stock
        stock.isAvailability = !stock.isAvailability
        CoreDataManager.shared.saveStock(stock: [stock], for: pantryId.uuidString)
        CloudManager.shared.saveCloudData(stock: stock)
        updateStocks()
    }
    
    func sortByStock() {
        if isSort {
            outOfStock = allStocks.filter({ !$0.isAvailability })
            stocks = allStocks.filter({ $0.isAvailability })
            return
        }
        stocks = allStocks
        outOfStock = []
    }
    
    func updateStocksAfterMove(updatedStocks: [Stock]) {
        var updatedStocks = updatedStocks
        for newIndex in updatedStocks.indices {
            updatedStocks[newIndex].index = newIndex
        }
        CoreDataManager.shared.saveStock(stock: updatedStocks, for: pantryId.uuidString)
        updatedStocks.forEach { stock in
            CloudManager.shared.saveCloudData(stock: stock)
        }
        updateStocks()
    }
    
    func updateEditStock(_ stock: Stock) {
        if editStocks.contains(where: { $0.id == stock.id }) {
            editStocks.removeAll { $0.id == stock.id }
            return
        }
        editStocks.append(stock)
    }
    
    func addEditAllStocks() {
        editStocks.removeAll()
        editStocks = allStocks
    }
    
    func delete(stock: Stock) {
        CoreDataManager.shared.deleteStock(by: stock.id)
        CloudManager.shared.delete(recordType: .stock, recordID: stock.recordId)
        updateStocks()
    }
    
    func resetEditStocks() {
        editStocks.removeAll()
    }
    
    func updateStocks() {
        getStocksFromDB()
        reloadData?()
    }
    
    private func getStocksFromDB() {
        var isSortIndex = false
        let dbStocks = CoreDataManager.shared.getAllStocks(for: pantryId.uuidString) ?? []
        let dbPantry = CoreDataManager.shared.getPantry(id: pantryId.uuidString)
        allStocks = dbStocks.map({ Stock(dbModel: $0,
                                         isVisibleСost: dbPantry?.isVisibleCost ?? false) })
        allStocks.forEach {
            if $0.index > 0 {
                isSortIndex = true
            }
        }
        
        if isSortIndex {
            allStocks.sort { $0.index < $1.index }
        } else {
            allStocks.sort { $0.dateOfCreation > $1.dateOfCreation }
        }
        
        sortByStock()
    }
}
