//
//  ProductsSettingsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import Foundation
import UIKit

protocol ProductSettingsViewDelegate: AnyObject {
    func dismissController(comp: @escaping (() -> Void))
    func reloadController()
}

class ProductsSettingsViewModel {
    
    weak var router: RootRouter?
    weak var delegate: ProductSettingsViewDelegate?
    var valueChangedCallback: ((GroceryListsModel, [Product]) -> Void)?
    var editCallback: ((TableViewContent) -> Void)?
    
    private var colorManager = ColorManager()
    private var snapshot: UIImage?
    private var listByText = ""
    private var model: GroceryListsModel
    private var copiedProducts: [Product] = []
    private var allContent: [TableViewContent] = []
   
    init(model: GroceryListsModel, snapshot: UIImage?, listByText: String) {
        self.model = model
        self.snapshot = snapshot
        self.listByText = listByText
        
        allContent = getContentOnSharedList()
    }
    
    func getNumberOfCells() -> Int {
        return allContent.count
    }
    
    func getImage(at ind: Int) -> UIImage? {
        guard let content = allContent[safe: ind] else { return nil }
        if content == .changeColor {
            return getImageWithColor(color: getTextColor(),
                                     size: CGSize(width: 28, height: 28))?.rounded(radius: 100)
        }
        return allContent[ind].image
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
        return allContent[ind].title
    }
    
    func getInset(at ind: Int) -> Bool {
        return allContent[ind].isInset
    }
    
    func getTextColor() -> UIColor {
        colorManager.getGradient(index: model.color).medium
    }
    
    func getSeparatirLineColor() -> UIColor {
        colorManager.getGradient(index: model.color).light
    }
    
    func controllerDissmised() {
        router?.pop()
    }
    
    func isChecmarkActive(at ind: Int) -> Bool {
        guard let content = allContent[safe: ind] else { return false }
        if content == .pinch { return model.isFavorite }
        if content == .byUsers { return model.typeOfSorting == SortingType.user.rawValue }
        if content == .byCategory { return model.typeOfSorting == SortingType.category.rawValue }
        if content == .byTime { return model.typeOfSorting == SortingType.time.rawValue }
        if content == .byRecipe { return model.typeOfSorting == SortingType.recipe.rawValue }
        if content == .byAlphabet { return model.typeOfSorting == SortingType.alphabet.rawValue }
        if content == .share { return model.isShared }
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
        guard let content = allContent[safe: ind] else { return false }
        return content == .imageMatching
    }
    
    func isSharedList(at ind: Int) -> Bool {
        guard let content = allContent[safe: ind] else { return false }
        return content == .share && model.isShared
    }
    
    func getShareImages() -> [String?] {
        var arrayOfImageUrls: [String?] = []
        guard let newUsers = SharedListManager.shared.sharedListsUsers[model.sharedId] else {
            return arrayOfImageUrls
        }
        newUsers.forEach { user in
            if user.token != UserAccountManager.shared.getUser()?.token {
                arrayOfImageUrls.append(user.avatar)
            }
        }
        return arrayOfImageUrls
    }
    
    func cellSelected(at ind: Int) {
        guard let content = allContent[safe: ind] else { return }
        switch content {
        case .rename:
            AmplitudeManager.shared.logEvent(.setRename)
            router?.presentCreateNewList(model: model) { [weak self] newModel, products  in
                self?.model = newModel
                self?.copiedProducts = products
                self?.savePatametrs()
            }
        case .edit:
            delegate?.dismissController(comp: { [weak self] in
                self?.editCallback?(.edit)
            })
        case .pinch:
            AmplitudeManager.shared.logEvent(.setFix)
            model.isFavorite = !model.isFavorite
            savePatametrs()
        case .changeColor:
            AmplitudeManager.shared.logEvent(.setColor)
            router?.presentCreateNewList(model: model) { [weak self] newModel, products  in
                self?.model = newModel
                self?.copiedProducts = products
                self?.savePatametrs()
            }
        case .byUsers, .byCategory, .byTime, .byRecipe, .byAlphabet:
            typeOfSorting(content)
        case .share:
            AmplitudeManager.shared.logEvent(.setInvite)
            delegate?.dismissController(comp: { [weak self] in
                self?.editCallback?(.share)
            })
        case .print:
            AmplitudeManager.shared.logEvent(.setPrint)
            sendSnapshot(content)
        case .send:
            AmplitudeManager.shared.logEvent(.listSendedText)
            router?.showActivityVC(image: [listByText])
        case .delete:
            AmplitudeManager.shared.logEvent(.setDelete)
            CoreDataManager.shared.removeList(model.id)
            delegate?.dismissController(comp: { [weak self] in
                self?.controllerDissmised()
            })
        default: return
        }
    }
    
    func imageMatching(isOn: Bool) {
        AmplitudeManager.shared.logEvent(.setAutoimageToggle, properties: [.isActive: isOn ? .yes : .no])
        model.isShowImage = isOn ? .switchOn : .switchOff
        savePatametrs()
    }
    
    private func typeOfSorting(_ content: TableViewContent) {
        switch content {
        case .byUsers:
            model.typeOfSorting = SortingType.user.rawValue
        case .byCategory:
            AmplitudeManager.shared.logEvent(.setSortCategory)
            model.typeOfSorting = SortingType.category.rawValue
        case .byTime:
            AmplitudeManager.shared.logEvent(.setSortTime)
            model.typeOfSorting = SortingType.time.rawValue
        case .byRecipe:
            AmplitudeManager.shared.logEvent(.setSortRecipe)
            model.typeOfSorting = SortingType.recipe.rawValue
        case .byAlphabet:
            AmplitudeManager.shared.logEvent(.setSortAbc)
            model.typeOfSorting = SortingType.alphabet.rawValue
        default: return
        }
        savePatametrs()
    }
    
    private func sendSnapshot(_ content: TableViewContent) {
        guard let snapshot = snapshot else { return }
        switch content {
        case .print:
            router?.showPrintVC(image: snapshot)
        default:
            print("")
        }
    }
    
    private func getContentOnSharedList() -> [TableViewContent] {
        var allContent = TableViewContent.allCases
        guard model.isShared else {
            allContent.removeAll { $0 == .byUsers }
            return allContent
        }
        return allContent
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
        case edit
        case pinch
        case changeColor
        case sort
        case byUsers
        case byCategory
        case byTime
        case byRecipe
        case byAlphabet
        case imageMatching
        case share
        case print
        case send
        case delete
        
        var image: UIImage? {
            switch self {
            case .rename:           return R.image.rename()
            case .edit:             return R.image.editCell()
            case .pinch:            return R.image.pin()
            case .changeColor:      return R.image.color()
            case .sort:             return R.image.sort()
            case .byUsers:          return R.image.byUsers()
            case .byCategory:       return R.image.category()
            case .byRecipe:         return R.image.sortRecipe()
            case .byTime:           return R.image.time()
            case .byAlphabet:       return R.image.abC()
            case .imageMatching:    return R.image.carrot_image()
            case .share:            return R.image.profile_add()?.withTintColor(.black)
            case .print:            return R.image.print()
            case .send:             return R.image.send()
            case .delete:           return R.image.trash_red()
            }
        }
        
        var title: String {
            switch self {
            case .rename:           return R.string.localizable.rename()
            case .edit:             return R.string.localizable.edit()
            case .pinch:            return R.string.localizable.pinch()
            case .changeColor:      return R.string.localizable.changeColor()
            case .sort:             return R.string.localizable.sort()
            case .byUsers:          return R.string.localizable.byUsers()
            case .byCategory:       return R.string.localizable.byCategory()
            case .byRecipe:         return R.string.localizable.byRecipe()
            case .byTime:           return R.string.localizable.byTime()
            case .byAlphabet:       return R.string.localizable.byAlphabet()
            case .imageMatching:    return R.string.localizable.pictureMatching()
            case .share:            return R.string.localizable.shared()
            case .print:            return R.string.localizable.print()
            case .send:             return R.string.localizable.send()
            case .delete:           return R.string.localizable.delete()
            }
        }
        
        var isInset: Bool {
            switch self {
            case .byTime, .byAlphabet, .byCategory, .byRecipe, .byUsers:
                return true
            default:
                return false
            }
        }
    }
}
