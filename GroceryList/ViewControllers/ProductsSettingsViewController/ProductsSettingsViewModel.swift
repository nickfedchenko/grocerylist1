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
    private var listByText = ""
    private var model: GroceryListsModel
    weak var router: RootRouter?
    var valueChangedCallback: ((GroceryListsModel, [Product]) -> Void)?
    weak var delegate: ProductSettingsViewDelegate?
    private var copiedProducts: [Product] = []
    
    private var colorManager = ColorManager()
   
    init(model: GroceryListsModel, snapshot: UIImage?, listByText: String) {
        self.model = model
        self.snapshot = snapshot
        self.listByText = listByText
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
        return TableViewContent.allCases[ind].title
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
        if ind == TableViewContent.pinch.rawValue { return model.isFavorite }
        if ind == TableViewContent.byCategory.rawValue { return model.typeOfSorting == SortingType.category.rawValue }
        if ind == TableViewContent.byTime.rawValue { return model.typeOfSorting == SortingType.time.rawValue }
        if ind == TableViewContent.byRecipe.rawValue { return model.typeOfSorting == SortingType.recipe.rawValue }
        if ind == TableViewContent.byAlphabet.rawValue { return model.typeOfSorting == SortingType.alphabet.rawValue }
        return false
    }
    
    func isShowImage() -> Bool {
        switch model.isShowImage {
        case .nothing:      return UserDefaultsManager.isShowImage
        case .switchOff:    return false
        case .switchOn:     return true
        }
    }
    
    func isSwitchActive(at ind: Int) -> Bool {
        ind == TableViewContent.imageMatching.rawValue
    }
    
    func cellSelected(at ind: Int) {
        switch ind {
        case TableViewContent.rename.rawValue:
            router?.presentCreateNewList(model: model) { [weak self] newModel, products  in
                self?.model = newModel
                self?.copiedProducts = products
                self?.savePatametrs()
            }
        case TableViewContent.pinch.rawValue:
            model.isFavorite = !model.isFavorite
            savePatametrs()
        case TableViewContent.changeColor.rawValue:
            router?.presentCreateNewList(model: model) { [weak self] newModel, products  in
                self?.model = newModel
                self?.copiedProducts = products
                self?.savePatametrs()
            }
        case TableViewContent.sort.rawValue...TableViewContent.byAlphabet.rawValue:
            typeOfSorting(at: ind)
        case TableViewContent.copy.rawValue...TableViewContent.print.rawValue:
            sendSnapshot(at: ind)
        case TableViewContent.send.rawValue:
            AmplitudeManager.shared.logEvent(.listSendedText)
            router?.showActivityVC(image: [listByText])
        case TableViewContent.delete.rawValue:
            CoreDataManager.shared.removeList(model.id)
            delegate?.dismissController()
        default:
            print("")
        }
    }
    
    func imageMatching(isOn: Bool) {
        model.isShowImage = isOn ? .switchOn : .switchOff
        savePatametrs()
    }
    
    private func typeOfSorting(at ind: Int) {
        switch ind {
        case TableViewContent.byCategory.rawValue:
            model.typeOfSorting = SortingType.category.rawValue
            savePatametrs()
        case TableViewContent.byTime.rawValue:
            model.typeOfSorting = SortingType.time.rawValue
            savePatametrs()
        case TableViewContent.byRecipe.rawValue:
            model.typeOfSorting = SortingType.recipe.rawValue
            savePatametrs()
        case TableViewContent.byAlphabet.rawValue:
            model.typeOfSorting = SortingType.alphabet.rawValue
            savePatametrs()
        default:
            print("")
        }
    }
    
    private func sendSnapshot(at ind: Int) {
        guard let snapshot = snapshot else { return }
        switch ind {
        case TableViewContent.copy.rawValue:
            UIImageWriteToSavedPhotosAlbum(snapshot, self, nil, nil)
        case TableViewContent.print.rawValue:
            router?.showPrintVC(image: snapshot)
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
    enum TableViewContent: Int, CaseIterable {
        case rename
        case pinch
        case changeColor
        case sort
        case byCategory
        case byTime
        case byRecipe
        case byAlphabet
        case imageMatching
        case copy
        case print
        case send
        case delete
        
        var image: UIImage? {
            switch self {
            case .rename:           return R.image.rename()
            case .pinch:            return R.image.pin()
            case .changeColor:      return R.image.color()
            case .sort:             return R.image.sort()
            case .byCategory:       return R.image.category()
            case .byRecipe:         return R.image.sortRecipe()
            case .byTime:           return R.image.time()
            case .byAlphabet:       return R.image.abC()
            case .imageMatching:    return R.image.carrot_image()
            case .copy:             return R.image.copy()
            case .print:            return R.image.print()
            case .send:             return R.image.send()
            case .delete:           return R.image.trash_red()
            }
        }
        
        var title: String {
            switch self {
            case .rename:           return R.string.localizable.rename()
            case .pinch:            return R.string.localizable.pinch()
            case .changeColor:      return R.string.localizable.changeColor()
            case .sort:             return R.string.localizable.sort()
            case .byCategory:       return R.string.localizable.byCategory()
            case .byRecipe:         return R.string.localizable.byRecipe()
            case .byTime:           return R.string.localizable.byTime()
            case .byAlphabet:       return R.string.localizable.byAlphabet()
            case .imageMatching:    return R.string.localizable.pictureMatching()
            case .copy:             return R.string.localizable.copy()
            case .print:            return R.string.localizable.print()
            case .send:             return R.string.localizable.send()
            case .delete:           return R.string.localizable.delete()
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
