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
        dataSource = DataSource()
        dataSource.dataChangedCallBack = {
            self.reloadDataCallBack?()
        }
    }
    
    var reloadDataCallBack: (() -> Void)?
    private let coldStartDataSource = ColdStartDataSource()
    private var dataSource = DataSource()
    private var isFirstStart = true
    
    var model: [SectionModel] {
        dataSource.workingSectionsArray
    }
    
    // setup cells
    func getNameOfList(at ind: IndexPath) -> String {
        return model[ind.section].lists[ind.row].name ?? "No name"
    }
    
    func getBGColor(at ind: IndexPath) -> UIColor {
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
        dataSource.coreDataSet.remove(model)
        reloadDataCallBack?()
    }
    
    func addOrDeleteFromFavorite(at ind: IndexPath) {
        let modelToAddOrDelete = model[ind.section].lists[ind.row]
        if model[ind.section].sectionType == .favorite {
            
        }
    
        if model[ind.section].sectionType != .favorite {
            if !model.contains(where: { $0.sectionType == .favorite }) {
             //   model.insert(createEmptyFavoriteSection(with: modelToAddOrDelete), at: 0) 
            }
        }
        reloadDataCallBack?()
    }
    
    func createEmptyFavoriteSection(with model: GroseryListsModel) -> SectionModel {
        SectionModel(cellType: .usual, sectionType: .favorite, lists: [model])
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
