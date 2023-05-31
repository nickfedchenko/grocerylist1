//
//  ListViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import Kingfisher
import UIKit

class ListViewModel {
    
    weak var router: RootRouter?
    var dataSource: ListDataSourceProtocol
    
    var reloadDataCallBack: (() -> Void)?
    var updateCells:((Set<GroceryListsModel>) -> Void)?
    var showSynchronizationActivity: ((Bool) -> Void)?
    
    var model: [SectionModel] {
        return dataSource.dataSourceArray
    }
    
    private var colorManager = ColorManager()
    private let groupForSavingSharedUser = DispatchGroup()
    private var startTime: Date?
    
    init(dataSource: ListDataSourceProtocol) {
        self.dataSource = dataSource
        self.dataSource.dataChangedCallBack = { [weak self] in
            self?.reloadDataCallBack?()
        }

        addObserver()
        downloadMySharedLists()
    }

    func cellTapped(with model: GroceryListsModel) {
        router?.goProductsVC(model: model, compl: { })
    }
    
    func sharingTapped(model: GroceryListsModel) {
        guard UserAccountManager.shared.getUser() != nil else {
            router?.goToSharingPopUp()
            return
        }
        let users = SharedListManager.shared.sharedListsUsers[model.sharedId] ?? []
        router?.goToSharingList(listToShare: model, users: users)
    }
    
    func getNameOfList(at ind: IndexPath) -> String {
        return model[ind.section].lists[ind.row].name ?? "No name"
    }
    
    func getBGColor(at ind: IndexPath) -> UIColor {
        let colorInd = model[ind.section].lists[ind.row].color
        return colorManager.getGradient(index: colorInd).medium
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
    
    func deleteCell(with model: GroceryListsModel) {
        let list = dataSource.deleteList(with: model)
        updateCells?(list)
        dataSource.setOfModelsToUpdate = []
        
        guard model.sharedId != "" else { return }
        SharedListManager.shared.deleteGroceryList(listId: model.sharedId)
        SharedListManager.shared.unsubscribeFromGroceryList(listId: model.sharedId)
    }
    
    func addOrDeleteFromFavorite(with model: GroceryListsModel) {
        let list = dataSource.addOrDeleteFromFavorite(with: model)
        updateCells?(list)
        dataSource.setOfModelsToUpdate = []
        SharedListManager.shared.updateGroceryList(listId: model.id.uuidString)
    }
    
    func settingsTapped() {
        router?.goToSettingsController()
    }
    
    func getNumberOfProductsInside(at ind: IndexPath) -> String {
        let supply = model[ind.section].lists[ind.row]
        var done = 0
        supply.products.forEach({ item in
            if item.isPurchased {done += 1 }
        })
        return "\(done) / \(supply.products.count)"
    }
    
    func reloadDataFromStorage() {
        dataSource.updateListOfModels()
    }
    
    func getImageHeight() -> ImageHeight {
        dataSource.imageHeight
    }
    
    // MARK: - Shared List Functions
    
    private func downloadMySharedLists() {
        SharedListManager.shared.fetchMyGroceryLists()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(sharedListDownloaded),
                                               name: .sharedListDownloadedAndSaved, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sharedListLoading),
                                               name: .sharedListLoading, object: nil)
    }
    
    @objc
    private func sharedListDownloaded() {
        updateCells?(dataSource.updateListOfModels())
        showSynchronizationActivity?(false)
        if let startTime {
            let time = Double(Date().timeIntervalSince(startTime))
            AmplitudeManager.shared.logEvent(.sharedListLoading,
                                             properties: [.time: String(format: "%.2f", time)])
            self.startTime = nil
        }
    }
    
    @objc
    private func sharedListLoading() {
        showSynchronizationActivity?(true)
        startTime = Date()
    }
}
