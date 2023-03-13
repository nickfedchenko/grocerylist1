//
//  ProductsSettingsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import Foundation
import UIKit

protocol ProductSettingsViewDelegate: AnyObject {
    func dismissController()
    func reloadController()
}

class ProductsSettingsViewModel {
    private var snapshot: UIImage?
    private var model: GroceryListsModel
    weak var router: RootRouter?
    var valueChangedCallback: ((GroceryListsModel, [Product]) -> Void)?
    weak var delegate: ProductSettingsViewDelegate?
    private var copiedProducts: [Product] = []
    
    private var colorManager = ColorManager()
   
    init(model: GroceryListsModel, snapshot: UIImage?) {
        self.model = model
        self.snapshot = snapshot
    }
    
    func getNumberOfCells() -> Int {
        return TableViewContent.allCases.count
    }
    
    func getImage(at ind: Int) -> UIImage? {
        if ind == 2 { return getImageWithColor(color: getTextColor(), size: CGSize(width: 28, height: 28))?.rounded(radius: 100)}
        return TableViewContent.allCases[ind].image
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func getText(at ind: Int) -> String? {
        return TableViewContent.allCases[ind].rawValue.localized
    }
    
    func getInset(at ind: Int) -> Bool {
        return TableViewContent.allCases[ind].isInset
    }
    
    func getTextColor() -> UIColor {
        colorManager.getGradient(index: model.color).0
    }
    
    func getSeparatirLineColor() -> UIColor {
        colorManager.getGradient(index: model.color).1
    }
    
    func controllerDissmised() {
        router?.pop()
    }
    
    func isChecmarkActive(at ind: Int) -> Bool {
        if ind == 1 { return model.isFavorite }
        if ind == 4 { return model.typeOfSorting == SortingType.category.rawValue }
        if ind == 5 { return model.typeOfSorting == SortingType.recipe.rawValue }
        if ind == 6 { return model.typeOfSorting == SortingType.time.rawValue }
        if ind == 7 { return model.typeOfSorting == SortingType.alphabet.rawValue }
        return false
    }
    
    func cellSelected(at ind: Int) {
        guard let snapshot = snapshot else { return }
        switch ind {
        case 0:
            router?.presentCreateNewList(model: model) { [weak self] newModel, products  in
                self?.model = newModel
                self?.copiedProducts = products
                self?.savePatametrs()
            }
        case 1:
            model.isFavorite = !model.isFavorite
            savePatametrs()
        case 2:
            router?.presentCreateNewList(model: model) { [weak self] newModel, products  in
                self?.model = newModel
                self?.copiedProducts = products
                self?.savePatametrs()
            }
        case 4:
            model.typeOfSorting = SortingType.category.rawValue
            savePatametrs()
        case 5:
            model.typeOfSorting = SortingType.recipe.rawValue
            savePatametrs()
        case 6:
            model.typeOfSorting = SortingType.time.rawValue
            savePatametrs()
        case 7:
            model.typeOfSorting = SortingType.alphabet.rawValue
            savePatametrs()
        case 8:
            UIImageWriteToSavedPhotosAlbum(snapshot, self, nil, nil)
        case 9:
            router?.showPrintVC(image: snapshot)
        case 10:
            router?.showActivityVC(image: [snapshot])
        case 11:
            CoreDataManager.shared.removeList(model.id)
            delegate?.dismissController()
        default:
            print("")
        }
    }
    
    private func savePatametrs() {
        delegate?.reloadController()
        valueChangedCallback?(model, copiedProducts)
        CoreDataManager.shared.saveList(list: model)
    }
}

extension ProductsSettingsViewModel {
    enum TableViewContent: String, CaseIterable {
        case rename
        case pinch
        case changeColor
        case sort
        case byCategory
        case byRecipe
        case byTime
        case byAlphabet
        case copy
        case print
        case send
        case delete
        
        var image: UIImage? {
            switch self {
            case .rename:
                return UIImage(named: "Rename")
            case .pinch:
                return UIImage(named: "Pin")
            case .changeColor:
                return UIImage(named: "Color")
            case .sort:
                return UIImage(named: "Sort")
            case .byCategory:
                return UIImage(named: "Category")
            case .byRecipe:
                return UIImage(named: "Time")
            case .byTime:
                return UIImage(named: "Time")
            case .byAlphabet:
                return UIImage(named: "ABC")
            case .copy:
                return UIImage(named: "Copy")
            case .print:
                return UIImage(named: "Print")
            case .send:
                return UIImage(named: "Send")
            case .delete:
                return UIImage(named: "Trash")
            }
        }
        
        var isInset: Bool {
            switch self {
            case .byTime, .byAlphabet, .byCategory, .byRecipe:
                return true
            default:
                return false
            }
        }
    }
}
