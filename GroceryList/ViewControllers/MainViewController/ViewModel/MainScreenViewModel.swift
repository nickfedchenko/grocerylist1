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
//    //    CoreDataManager.shared.deleteAllEntities()
//        print(CoreDataManager.shared.getAllLists()?.count)
//        let supplay = Product(id: UUID(), listId: id.id!, name: "ccc", isPurchased: true, dateOfCreation: Date(), category: "222", isFavorite: true)
//        let supplay2 = Product(id: UUID(), listId: id.id!, name: "ddd", isPurchased: false, dateOfCreation: Date(), category: "222", isFavorite: true)
//        CoreDataManager.shared.createProduct(product: supplay)
//        CoreDataManager.shared.createProduct(product: supplay2)
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
    
    func getnumberOfProductsInside(at ind: IndexPath) -> String {
        let supply = model[ind.section].lists[ind.row]
        var done = 0
        supply.products.forEach({ item in
            if item.isPurchased {done += 1 }
        })
        return "\(done)/\(supply.products.count)"
    }
    
    func reloadDataFromStorage() {
        dataSource.updateListOfModels()
    }
}
