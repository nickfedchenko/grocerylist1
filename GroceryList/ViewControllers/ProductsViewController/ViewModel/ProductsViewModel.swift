//
//  ProductsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import Foundation
import UIKit

protocol ProductsViewModelDelegate: AnyObject {
    func updateController()
}

class ProductsViewModel {
    
    weak var router: RootRouter?
    private var colorManager = ColorManager()
    var valueChangedCallback: (() -> Void)?
    var model: GroceryListsModel
    var dataSource: ProductsDataManager
    weak var delegate: ProductsViewModelDelegate?
    var selectedProduct: Product?
    
    init(model: GroceryListsModel, dataSource: ProductsDataManager) {
        self.dataSource = dataSource
        self.model = model
        
        self.dataSource.dataChangedCallBack = { [weak self] in
            self?.valueChangedCallback?()
        }
        
        self.dataSource.createDataSourceArray()
        addObserver()
    }
    
    var arrayWithSections: [Category] {
        return dataSource.dataSourceArray
    }
    
    func getColorForBackground() -> UIColor {
        colorManager.getGradient(index: model.color).1
    }
    
    func getColorForForeground() -> UIColor {
        colorManager.getGradient(index: model.color).0
    }
    
    func getNameOfList() -> String {
        model.name ?? "..."
    }
    
    func goBackButtonPressed() {
        router?.pop()
        router?.goReviewController()
    }
    
    func getCellIndex(with category: Category) -> Int {
        guard let index = arrayWithSections.firstIndex(of: category ) else { return 0 }
        return index
    }
    
    func settingsTapped(with snapshot: UIImage?) {
        router?.goProductsSettingsVC(snapshot: snapshot, listByText: getListByText(), model: model,
                                     compl: { [weak self] updatedModel, products in
            self?.model = updatedModel
            self?.appendToDataSourceProducts(products: products)
            self?.dataSource.typeOfSorting = SortingType(rawValue: self?.model.typeOfSorting ?? 0) ?? .category
            self?.delegate?.updateController()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.updateList()
            }
        })
    }
    
    func updatePurchasedStatus(product: Product) {
        dataSource.updatePurchasedStatus(for: product)
        updateList()
    }
    
    func updateFavoriteStatus(for product: Product) {
        dataSource.updateFavoriteStatus(for: product)
        updateList()
    }
    
    func updateImage(_ image: UIImage?) {
        selectedProduct?.imageData = image?.jpegData(compressionQuality: 1)
        guard let selectedProduct else {
            return
        }
        dataSource.updateImage(for: selectedProduct)
        valueChangedCallback?()
    }
    
    func delete(product: Product) {
        dataSource.delete(product: product)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateList()
        }

    }
    
    func appendToDataSourceProducts(products: [Product]) {
        dataSource.appendCopiedProducts(product: products)
    }
    
    func addNewProductTapped(_ product: Product? = nil) {
        router?.goCreateNewProductController(model: model, product: product, compl: { [weak self] product in
            self?.dataSource.appendCopiedProducts(product: [product])
            self?.updateList()
        })
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
        dataSource.createDataSourceArray()
    }
    
    private func updateList() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.model.isShared else { return }
            SharedListManager.shared.updateGroceryList(listId: self.model.id.uuidString)
        }
    }
    
    private func getListByText() -> String {
        var list = ""
        let newLine = "\n"
        let tab = "  • "
        let buy = "Купить".uppercased() + newLine + newLine
        list += buy
        
        arrayWithSections.forEach { category in
            list += category.name.uppercased() + newLine
            category.products.map { product in
                return tab + product.name.firstCharacterUpperCase() + newLine
            }.forEach { title in
                list += title
            }
            list += newLine
        }
        
        return list
    }
}
