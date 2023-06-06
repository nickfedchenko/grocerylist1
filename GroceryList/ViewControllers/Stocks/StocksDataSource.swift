//
//  StocksDataSource.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 05.06.2023.
//

import Foundation

final class StocksDataSource {
    
    var reloadData: (() -> Void)?

    private(set) var stocks: [Stock] = []
    private(set) var editStocks: [Stock] = []
    
    init(stocks: [Stock]) {
        self.stocks = stocks.sorted(by: { $0.index < $1.index })
    }
    
    func addStock(_ stock: Stock) {
        if stocks.contains(where: { $0.id == stock.id }) {
            stocks.removeAll { stock.id == $0.id }
        }
        stocks.append(stock)
        stocks = stocks.sorted(by: { $0.index < $1.index })
        reloadData?()
    }
    
    func updateStockStatus(stock: Stock) {
        guard let index = stocks.firstIndex(where: { $0.id == stock.id }) else {
            return
        }
        stocks[index].isAvailability = !stock.isAvailability
        reloadData?()
    }
    
    func sortByStock(_ isSort: Bool) {
        if isSort {
            stocks = stocks.sorted { !$0.isAvailability && $1.isAvailability }
        } else {
            stocks = stocks.sorted(by: { $0.index < $1.index })
        }
        
        reloadData?()
    }
    
    func updateStocksAfterMove(updatedStocks: [Stock]) {
        updatedStocks.enumerated().forEach { newIndex, updatedStock in
            if let index = stocks.firstIndex(where: { $0.id == updatedStock.id }) {
                stocks[index].index = newIndex
            }
        }
        
        stocks = stocks.sorted(by: { $0.index < $1.index })
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
        editStocks = stocks
    }
    
    func delete(stock: Stock) {
//        CoreDataManager.shared.removeProduct(product: product)
        stocks.removeAll { stock.id == $0.id }
        reloadData?()
    }
    
    func resetEditStocks() {
        editStocks.removeAll()
    }
}
