//
//  StockReminderDataSource.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.06.2023.
//

import Foundation

class StockReminderDataSource {
    
    var reloadData: (() -> Void)?
    
    private(set) var outOfStocks: [Stock]
    private let stocksUpdateHours = 10
    
    init(outOfStocks: [Stock]) {
        self.outOfStocks = outOfStocks
        self.outOfStocks.sort { $0.name < $1.name }
    }
    
    func updateStockStatus(stock: Stock) {
        var stock = stock
        stock.isAvailability = !stock.isAvailability
        CoreDataManager.shared.saveStock(stock: [stock], for: stock.pantryId.uuidString)
        
        outOfStocks.removeAll { $0.id == stock.id }
        outOfStocks.append(stock)
        outOfStocks.sort { $0.name < $1.name }
        reloadData?()
    }
    
    func saveListIds(uuids: [UUID]) {
        let pantryIds = Array(Set(outOfStocks.map { $0.pantryId }))
        var dbPantries: [DBPantry] = []
        pantryIds.forEach { id in
            if let dbPantry = CoreDataManager.shared.getPantry(id: id.uuidString) {
                dbPantries.append(dbPantry)
            }
        }
        var pantries: [PantryModel] = []
        dbPantries.map { PantryModel(dbModel: $0) }.forEach { pantry in
            var pantry = pantry
            pantry.synchronizedLists = uuids
            pantries.append(pantry)
        }
        
        CoreDataManager.shared.savePantry(pantry: pantries)
    }
}
