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
    
    private(set) var allStocks: [Stock] = [] {
        didSet { sortByStock() }
    }
    private(set) var stocks: [Stock] = []
    private(set) var outOfStock: [Stock] = []
    private(set) var editStocks: [Stock] = []
    
    init(stocks: [Stock]) {
        allStocks = stocks.sorted(by: { $0.index < $1.index })
    }
    
    func addStock(_ stock: Stock) {
        if allStocks.contains(where: { $0.id == stock.id }) {
            allStocks.removeAll { stock.id == $0.id }
        }
        allStocks.append(stock)
        allStocks = allStocks.sorted(by: { $0.dateOfCreation < $1.dateOfCreation })
        
        reloadData?()
    }
    
    func updateStockStatus(stock: Stock) {
        guard let index = allStocks.firstIndex(where: { $0.id == stock.id }) else {
            return
        }
        allStocks[index].isAvailability = !stock.isAvailability
        
        sortByStock()
    }
    
    func sortByStock() {
        if isSort {
            outOfStock = allStocks.filter({ !$0.isAvailability })
            stocks = allStocks.filter({ $0.isAvailability })
        } else {
            stocks = allStocks.sorted(by: { $0.dateOfCreation < $1.dateOfCreation })
            outOfStock = []
        }
        
        reloadData?()
    }
    
    func updateStocksAfterMove(updatedStocks: [Stock]) {
        updatedStocks.enumerated().forEach { newIndex, updatedStock in
            if let index = allStocks.firstIndex(where: { $0.id == updatedStock.id }) {
                allStocks[index].index = newIndex
            }
        }
        
        allStocks = allStocks.sorted(by: { $0.dateOfCreation < $1.dateOfCreation })
        reloadData?()
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
//        CoreDataManager.shared.removeProduct(product: product)
        allStocks.removeAll { stock.id == $0.id }
        reloadData?()
    }
    
    func resetEditStocks() {
        editStocks.removeAll()
    }
}
