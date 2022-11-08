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

       // let model = CoreDataManager.shared.getAllLists()
       // CoreDataManager.shared.getList(list: "979E19AA-3EA2-476C-9DC8-5348C932C689")

       // model?.forEach({ print($0.dateOfCreation)})
//          CoreDataManager.shared.saveList(list: GroseryListsModel(dateOfCreation: Date(), name: "second",
//                                                                  color: "1DD3CF", isFavorite: false, supplays: [] ))
//
    }
    
    var reloadDataCallBack: (() -> Void)?
    private var dataSource: DataSource
    
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
      //  dataSource.coreDataSet.remove(model)
    }
    
    func addCell(with model: GroseryListsModel) {
//        dataSource.coreDataSet.remove(model)
//        var newModel = model
//        newModel.isFavorite = true
//        dataSource.coreDataSet.insert(model)
    }
    
    func addOrDeleteFromFavorite(with model: GroseryListsModel) {
        
        if !model.isFavorite {
            addCell(with: model)
            }
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
