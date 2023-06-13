//
//  PantryViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.05.2023.
//

import UIKit

class PantryViewModel {
    
    weak var router: RootRouter?
    
    var reloadData: (() -> Void)?
    var updateNavUI: (() -> Void)?
    
    private var colorManager = ColorManager()
    private(set) var dataSource: PantryDataSource
    
    init(dataSource: PantryDataSource) {
        self.dataSource = dataSource
        
        self.dataSource.reloadData = { [weak self] in
            self?.reloadData?()
        }
        
        SharedPantryManager.shared.fetchMyPantryLists()
        NotificationCenter.default.addObserver(self, selector: #selector(sharedPantryDownloaded),
                                               name: .sharedPantryDownloadedAndSaved, object: nil)
    }
    
    var pantries: [PantryModel] {
        dataSource.getPantries()
    }
    
    func showStarterPackIfNeeded() {
        if !UserDefaultsManager.isShowPantryStarterPack {
            router?.goToPantryStarterPack()
            UserDefaultsManager.isShowPantryStarterPack = true
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
        let outOfStock = model.stock.filter { !$0.isAvailability }.count
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
    
    func addPantry() {
        dataSource.updatePantry()
    }
    
    func delete(model: PantryModel) {
        dataSource.delete(pantry: model)
        
        guard model.sharedId != "" else {
            return
        }
        SharedPantryManager.shared.deletePantryList(pantryId: model.sharedId)
        SharedPantryManager.shared.unsubscribeFromPantryList(pantryId: model.sharedId)
    }
    
    func showEditPantry(presentedController: UIViewController, pantry: PantryModel) {
        router?.goToCreateNewPantry(presentedController: presentedController,
                                    currentPantry: pantry) { [weak self] pantry in
            if let pantry {
                self?.addPantry()
                self?.updateSharedPantryList(model: pantry)
            }
            self?.updateNavUI?()
        }
    }
    
    func tappedAddItem(presentedController: UIViewController) {
        router?.goToCreateNewPantry(presentedController: presentedController,
                                    currentPantry: nil,
                                    updateUI: { [weak self] pantry in
            if let pantry {
                self?.addPantry()
                self?.router?.goToStocks(navController: presentedController, pantry: pantry)
            }
            self?.updateNavUI?()
        })
    }
    
    func showStocks(controller: UIViewController, model: PantryModel) {
        router?.goToStocks(navController: controller, pantry: model)
    }
    
    func sharingTapped(model: PantryModel) {
        guard UserAccountManager.shared.getUser() != nil else {
            router?.goToSharingPopUp()
            return
        }
        let users = SharedListManager.shared.sharedListsUsers[model.sharedId] ?? []
        router?.goToSharingList(pantryToShare: model, users: users)
    }
    
    func reloadDataFromStorage() {
        dataSource.updatePantry()
    }
    
    private func getSharingState(_  model: PantryModel) -> SharingView.SharingState {
        model.isShared ? .added : .invite
    }
    
    private func getShareImages(_  model: PantryModel) -> [String?] {
        var arrayOfImageUrls: [String?] = []
        
        if let newUsers = SharedPantryManager.shared.sharedListsUsers[model.sharedId] {
            newUsers.forEach { user in
                if user.token != UserAccountManager.shared.getUser()?.token {
                    arrayOfImageUrls.append(user.avatar)
                }
            }
        }
        return arrayOfImageUrls
    }
    
    @objc
    private func sharedPantryDownloaded() {
        addPantry()
    }
    
    private func updateSharedPantryList(model: PantryModel) {
        guard model.isShared else {
            return
        }
        SharedPantryManager.shared.updatePantryList(pantryId: model.id.uuidString)
    }
}
