//
//  StopSharingViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 04.09.2023.
//

import UIKit

class StopSharingViewModel {
    
    var updateUI: ((Bool) -> Void)?
    var listToShareModel: GroceryListsModel?
    var pantryToShareModel: PantryModel?
    let user: User
    let state: SharingListViewModel.State
    
    init(user: User, state: SharingListViewModel.State) {
        self.user = user
        self.state = state
    }
    
    func getPantry() -> PantryCell.CellModel? {
        guard let model = pantryToShareModel else {
            return nil
        }
        let theme = ColorManager.shared.getGradient(index: model.color)
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
    
    func stopSharing() {
        updateUI?(true)
    }
    
    func cancel() {
        updateUI?(false)
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
}
