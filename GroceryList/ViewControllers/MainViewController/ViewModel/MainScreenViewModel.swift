//
//  MainScreenViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import Foundation
import Kingfisher
import UIKit

class MainScreenViewModel {
    
    weak var router: RootRouter?
    var reloadDataCallBack: (() -> Void)?
    var addCustomCollection: (() -> Void)?
    var addCustomRecipe: ((Recipe) -> Void)?
    var updateCells:((Set<GroceryListsModel>) -> Void)?
    var dataSource: DataSourceProtocol?
    
    var model: [SectionModel] {
        return dataSource?.dataSourceArray ?? []
    }
    
    func getRecipeModel(for indexPath: IndexPath) -> Recipe? {
        guard let dataSource = dataSource else { return nil }
        let model = dataSource.recipesSections[indexPath.section].recipes[indexPath.item]
        return model
    }
    
    func recipeCount(for section: Int) -> Int {
        let count = dataSource?.recipesSections[section].recipes.count ?? 0
        let maxCount = dataSource?.recipeCount ?? 10
        return count < maxCount ? count : maxCount
    }
    
    func updateRecipesSection() {
        dataSource?.makeRecipesSections()
    }
    
    func updateFavorites() {
        dataSource?.updateFavoritesSection()
    }
    
    func updateCustomSection() {
        dataSource?.updateCustomSection()
    }
    
    // user
    var userPhoto: UIImage? {
        guard let user = UserAccountManager.shared.getUser() else {
            return R.image.profile_noreg()
        }
        
        guard let avatarAsData = user.avatarAsData else {
            return R.image.profile_icon()
        }
        return UIImage(data: avatarAsData)
    }
    
    var userName: String? {
        UserAccountManager.shared.getUser()?.username
    }
    
    private var colorManager = ColorManager()
    private let groupForSavingSharedUser = DispatchGroup()
    
    init(dataSource: DataSourceProtocol) {
        self.dataSource = dataSource
        self.dataSource?.dataChangedCallBack = { [weak self] in
            self?.reloadDataCallBack?()
        }
        addObserver()
        downloadMySharedLists()
    }
    
    // routing
    func createNewListTapped() {
        
        router?.goCreateNewList(compl: { [weak self] model, _  in
            guard let list = self?.dataSource?.updateListOfModels() else { return }
            self?.updateCells?(list)
            self?.dataSource?.setOfModelsToUpdate = []
            self?.router?.goProductsVC(model: model, compl: {
            })
        })
    }
    
    func cellTapped(with model: GroceryListsModel) {
        router?.goProductsVC(model: model, compl: {

        })
    }
    
    func sharingTapped(model: GroceryListsModel) {
        guard UserAccountManager.shared.getUser() != nil else {
            router?.goToSharingPopUp()
            return
        }
        let users = SharedListManager.shared.sharedListsUsers[model.sharedId] ?? []
        router?.goToSharingList(listToShare: model, users: users)
    }
    
    func createNewRecipeTapped() {
        router?.goToCreateNewRecipe(compl: { [weak self] recipe in
            self?.addCustomRecipe?(recipe)
        })
    }
    
    func createNewCollectionTapped() {
        router?.goToCreateNewCollection(compl: { [weak self] in
            self?.updateRecipesSection()
            self?.addCustomCollection?()
        })
    }
    
    func showCollection() {
        router?.goToShowCollection(state: .edit)
    }
    
    // setup cells
    func getNameOfList(at ind: IndexPath) -> String {
        return model[ind.section].lists[ind.row].name ?? "No name"
    }
    
    func getBGColor(at ind: IndexPath) -> UIColor {
        let colorInd = model[ind.section].lists[ind.row].color
        return colorManager.getGradient(index: colorInd).0
    }
    
    func getBGColorForEmptyCell(at ind: IndexPath) -> UIColor {
        let colorInd = model[ind.section].lists[ind.row].color
        return colorManager.getEmptyCellColor(index: colorInd)
    }
    
    func isTopRounded(at ind: IndexPath) -> Bool {
        ind.row == 0
    }
    
    func isBottomRounded(at ind: IndexPath) -> Bool {
        let lastCell = model[ind.section].lists.count - 1
        return ind.row == lastCell
    }
    
    func getSharingState(_  model: GroceryListsModel) -> SharingView.SharingState {
        model.isShared ? .added : .invite
    }
    
    func getShareImages(_  model: GroceryListsModel) -> [String?] {
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
    
    // cells callbacks
    
    func deleteCell(with model: GroceryListsModel) {
        guard let list = dataSource?.deleteList(with: model) else { return }
        updateCells?(list)
        dataSource?.setOfModelsToUpdate = []
        
        guard model.sharedId != "" else { return }
        SharedListManager.shared.deleteGroceryList(listId: model.sharedId)
        SharedListManager.shared.unsubscribeFromGroceryList(listId: model.sharedId)
    }
    
    func addOrDeleteFromFavorite(with model: GroceryListsModel) {
        guard let list = dataSource?.addOrDeleteFromFavorite(with: model) else { return }
        updateCells?(list)
        dataSource?.setOfModelsToUpdate = []
        SharedListManager.shared.updateGroceryList(listId: model.id.uuidString)
    }
    
    func settingsTapped() {
        router?.goToSettingsController()
    }
    
    func getnumberOfProductsInside(at ind: IndexPath) -> String {
        let supply = model[ind.section].lists[ind.row]
        var done = 0
        supply.products.forEach({ item in
            if item.isPurchased {done += 1 }
        })
        return "\(done) / \(supply.products.count)"
    }
    
    func reloadDataFromStorage() {
        dataSource?.updateListOfModels()
    }
    
    func getImageHeight() -> ImageHeight {
        dataSource?.imageHeight ?? .empty
    }
    
    // MARK: - Shared List Functions
    
    private func downloadMySharedLists() {
        SharedListManager.shared.fetchMyGroceryLists()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sharedListDownloaded),
            name: .sharedListDownloadedAndSaved,
            object: nil
        )
    }
    
    @objc
    private func sharedListDownloaded() {
        guard let dataSource = dataSource else { return }
        updateCells?(dataSource.updateListOfModels())
    }
}
