//
//  MainScreenViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import Foundation
import UIKit

class MainScreenViewModel {
    
    weak var router: RootRouter?
    private var colorManager = ColorManager()
    let network = Networking()
    
    init() {
        dataSource = MainScreenDataManager()
        dataSource.dataChangedCallBack = {
            self.reloadDataCallBack?()
        }
//        CoreDataManager.shared.saveList(list: GroseryListsModel(dateOfCreation: Date(), name: "1",
//                                                                  color: 1, isFavorite: true, supplays: [] ))
//        CoreDataManager.shared.saveList(list: GroseryListsModel(dateOfCreation: Date(), name: "2",
//                                                                color: 1, isFavorite: true, supplays: [] ))
//        CoreDataManager.shared.saveList(list: GroseryListsModel(dateOfCreation: Date() - 660000, name: "3",
//                                                                color: 1, isFavorite: false, supplays: [] ))
    }
    
    var reloadDataCallBack: (() -> Void)?
    var updateCells:((Set<GroseryListsModel>) -> Void)?
    private var dataSource: MainScreenDataManager
    
    var model: [SectionModel] {
        return dataSource.workingSectionsArray
    }
    
    // routing
    func createNewListTapped() {
        router?.goCreateNewList(compl: { [weak self] in
            guard let list = self?.dataSource.updateListOfModels() else { return }
            self?.updateCells?(list)
            self?.dataSource.setOfModelsToUpdate = []
        })
    }
    
    func cellTapped(with model: GroseryListsModel) {
        router?.goProductsVC(model: model, compl: {

        })
    }
    
    // setup cells
    func getNameOfList(at ind: IndexPath) -> String {
        return model[ind.section].lists[ind.row].name ?? "No name"
    }
    
    func getBGColor(at ind: IndexPath) -> UIColor {
        let colorInd = model[ind.section].lists[ind.row].color
        return colorManager.getGradient(index: colorInd).0
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
        let list = dataSource.deleteList(with: model)
        updateCells?(list)
        dataSource.setOfModelsToUpdate = []
    }
    
    func addOrDeleteFromFavorite(with model: GroseryListsModel) {
        let list = dataSource.addOrDeleteFromFavorite(with: model)
        updateCells?(list)
        dataSource.setOfModelsToUpdate = []
    }
    
    func getnumberOfSupplaysInside(at ind: IndexPath) -> String {
        let supply = model[ind.section].lists[ind.row]
        var done = 0
        supply.supplays.forEach({ item in
            if item.isPurchased {done += 1 }
        })
        return "\(done)/\(supply.supplays.count)"
    }
}
