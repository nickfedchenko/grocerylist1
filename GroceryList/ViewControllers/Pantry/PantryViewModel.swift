//
//  PantryViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.05.2023.
//

import UIKit

final class PantryViewModel {
    
    weak var router: RootRouter?
    
    var reloadData: (() -> Void)?
    
    private var colorManager = ColorManager()
    private var dataSource: PantryDataSource
    private var starterPack = true
    
    init(dataSource: PantryDataSource) {
        self.dataSource = dataSource
        
        self.dataSource.reloadData = { [weak self] in
            self?.reloadData?()
        }
    }
    
    var pantries: [PantryModel] {
        dataSource.getPantries()
    }
    
    func showStarterPackIfNeeded() {
        if !starterPack {
            router?.goToPantryStarterPack()
            starterPack = true
        }
    }
    
    func getCellModel(by index: IndexPath, and model: PantryModel) -> PantryCell.CellModel {
        let theme = colorManager.getGradient(index: model.color)
        var icon: UIImage?
        if let iconData = model.icon {
            icon = UIImage(data: iconData)
        }
        let sharingState = getSharingState(model)
        let sharingUser = getShareImages(model)
        let stockCount = model.stock.count.asString
        let outOfStock = model.stock.filter { $0.isAvailability }.count
        let outOfStockCount = outOfStock == 0 ? "" : outOfStock.asString
        
        return PantryCell.CellModel(theme: theme, name: model.name, icon: icon,
                                          sharingState: sharingState, sharingUser: sharingUser,
                                          stockCount: stockCount, outOfStockCount: outOfStockCount)
    }
    
    func getColor(model: PantryModel) -> Theme {
        colorManager.getGradient(index: model.color)
    }
    
    func moveCell(source: IndexPath, destination: IndexPath) {
        dataSource.movePantry(source: source.row, destination: destination.row)
    }
    
    func updatePantriesAfterMove(updatedPantries: [PantryModel]) {
        dataSource.updatePantriesAfterMove(updatedPantries: updatedPantries)
    }
    
    func addPantry(_ pantry: PantryModel) {
        dataSource.addPantry(pantry)
    }
    
    func delete(model: PantryModel) {
        dataSource.delete(pantry: model)
    }
    
    func showEditPantry(pantry: PantryModel) {
        router?.goToCreateNewPantry(currentPantry: pantry) { [weak self] pantry in
            self?.addPantry(pantry)
        }
    }
    
    func sharingTapped(model: PantryModel) {
        guard UserAccountManager.shared.getUser() != nil else {
            router?.goToSharingPopUp()
            return
        }
        let users = SharedListManager.shared.sharedListsUsers[model.sharedId] ?? []
//        router?.goToSharingList(listToShare: model, users: users)
    }
    
    private func getSharingState(_  model: PantryModel) -> SharingView.SharingState {
        model.isShared ? .added : .invite
    }
    
    private func getShareImages(_  model: PantryModel) -> [String?] {
        var arrayOfImageUrls: [String?] = []
        
        if let newUsers = SharedListManager.shared.sharedListsUsers[model.sharedId] {
            newUsers.forEach { user in
                if user.token != UserAccountManager.shared.getUser()?.token {
                    arrayOfImageUrls.append(user.avatar)
                }
            }
        }
        return arrayOfImageUrls
    }
}