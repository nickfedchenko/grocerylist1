//
//  MainScreenViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import Foundation
import UIKit

class MainScreenViewModel {
    
    init() {
        dataSource = MainScreenDataManager()
        dataSource.dataChangedCallBack = {
            self.reloadDataCallBack?()
        }

        CoreDataManager.shared.saveList(list: GroseryListsModel(dateOfCreation: Date(), name: "1",
                                                                  color: "1DD3CF", isFavorite: true, supplays: [] ))
        CoreDataManager.shared.saveList(list: GroseryListsModel(dateOfCreation: Date(), name: "2",
                                                                color: "1DD3CF", isFavorite: true, supplays: [] ))
        CoreDataManager.shared.saveList(list: GroseryListsModel(dateOfCreation: Date() - 660000, name: "3",
                                                                color: "1DD3CF", isFavorite: false, supplays: [] ))
//        CoreDataManager.shared.saveList(list: GroseryListsModel(dateOfCreation: Date(), name: "4",
//                                                                color: "1DD3CF", isFavorite: false, supplays: [] ))

    }
    
    var reloadDataCallBack: (() -> Void)?
    private var dataSource: MainScreenDataManager
    
    var model: [SectionModel] {
        return dataSource.workingSectionsArray
    }
    
    // setup cells
    func getNameOfList(at ind: IndexPath) -> String {
        return model[ind.section].lists[ind.row].name ?? "No name"
    }
    
    func getBGColor(at ind: IndexPath) -> String {
        return model[ind.section].lists[ind.row].color
    }
    
    func isTopRounded(at ind: IndexPath) -> Bool {
        ind.row == 0
    }
    
    func isBottomRounded(at ind: IndexPath) -> Bool {
        let lastCell = model[ind.section].lists.count - 1
        return ind.row == lastCell
    }
    
    // cells callbacks
    
    func deleteCell(with model: GroseryListsModel) {
        dataSource.deleteList(with: model)
    }
    
    func addOrDeleteFromFavorite(with model: GroseryListsModel) {
        dataSource.addOrDeleteFromFavorite(with: model)
    }
    
    func getnumberOfSupplaysInside(at ind: IndexPath) -> String {
        let supply = model[ind.section].lists[ind.row]
        var done = 0
        supply.supplays.forEach({ item in
            guard let item = item else { return }
            if item.isPurchased {done += 1 }
        })
        return "\(done)/\(supply.supplays.count)"
    }
}
