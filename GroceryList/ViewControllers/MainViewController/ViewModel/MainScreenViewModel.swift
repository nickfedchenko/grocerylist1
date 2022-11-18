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
        dataSource.dataChangedCallBack = { [weak self] in
            self?.reloadDataCallBack?()
        }
        
//        let id = CoreDataManager.shared.getAllLists()![0]
//        let supplay = Supplay(id: UUID(), listId: id.id!, name: "biba", isPurchased: true, dateOfCreation: Date(), category: "boba")
//        let supplay2 = Supplay(id: UUID(), listId: id.id!, name: "gr767", isPurchased: false, dateOfCreation: Date(), category: "lfg")
//        CoreDataManager.shared.createSupplay(supplay: supplay)
//        CoreDataManager.shared.createSupplay(supplay: supplay2)
       // print(CoreDataManager.shared.getSupplays(for: id))
    }
    
    var reloadDataCallBack: (() -> Void)?
    var updateCells:((Set<GroceryListsModel>) -> Void)?
    private var dataSource: MainScreenDataManager
    
    var model: [SectionModel] {
        return dataSource.workingSectionsArray
    }
    
    // routing
    func createNewListTapped() {
        
        router?.goCreateNewList(compl: { [weak self] _ in
            guard let list = self?.dataSource.updateListOfModels() else { return }
            self?.updateCells?(list)
            self?.dataSource.setOfModelsToUpdate = []
        })
    }
    
    func cellTapped(with model: GroceryListsModel) {
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
    
    func deleteCell(with model: GroceryListsModel) {
        let list = dataSource.deleteList(with: model)
        updateCells?(list)
        dataSource.setOfModelsToUpdate = []
    }
    
    func addOrDeleteFromFavorite(with model: GroceryListsModel) {
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
    
    func reloadDataFromStorage() {
        dataSource.updateListOfModels()
    }
}
