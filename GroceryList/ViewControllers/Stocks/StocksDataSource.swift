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
    
    init(stocks: [Stock]) {
        self.stocks = stocks
    }
    
    func addStock(_ pantry: Stock) {
        if stocks.contains(where: { $0.id == pantry.id }) {
            stocks.removeAll { pantry.id == $0.id }
        }
        stocks.append(pantry)
        reloadData?()
    }
}
