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
    
    init(dataSource: DataSourceProtocol) {
        self.dataSource = dataSource
        self.dataSource?.dataChangedCallBack = { [weak self] in
            self?.reloadDataCallBack?()
        }
    }
    
    weak var router: RootRouter?
    private var colorManager = ColorManager()
    var reloadDataCallBack: (() -> Void)?
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
        guard let user = UserAccountManager.shared.getUser() else {
            router?.goToSharingPopUp()
            return
        }
        router?.goToSharingList(listToShare: model)
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
    
    func getSharingState(at ind: IndexPath) -> SharingView.SharingState {
        // TODO: туть передаем состояние кнопки шаре
        /*
          .invite - пригласить (иконка с плюсиком)
          .expectation - ожидание присоединения (иконка с галочкой)
          .added - пользователь добавлен + передаем массив фото пользователей
         */
        return .invite
    }
    
    func getShareImages(at ind: IndexPath) -> [UIImage] {
        guard getSharingState(at: ind) == .added else {
            return []
        }
        // TODO: туть получаем массив фото пользователей с которыми поделились карточкой
        return []
    }
    
    // cells callbacks
    
    func deleteCell(with model: GroceryListsModel) {
        guard let list = dataSource?.deleteList(with: model) else { return }
        updateCells?(list)
        dataSource?.setOfModelsToUpdate = []
    }
    
    func addOrDeleteFromFavorite(with model: GroceryListsModel) {
        guard let list = dataSource?.addOrDeleteFromFavorite(with: model) else { return }
        updateCells?(list)
        dataSource?.setOfModelsToUpdate = []
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
}
