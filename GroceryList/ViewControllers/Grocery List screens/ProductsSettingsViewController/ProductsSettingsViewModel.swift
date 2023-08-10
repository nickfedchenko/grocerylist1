//
//  ProductsSettingsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import ApphudSDK
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
    
    private var colorManager = ColorManager.shared
    private(set) var snapshot: UIImage?
    private(set) var listByText = ""
    private var model: GroceryListsModel
    private var copiedProducts: [Product] = []
    private var allContent = TableViewContent.allCases
   
    init(model: GroceryListsModel, snapshot: UIImage?, listByText: String) {
        self.model = model
        self.snapshot = snapshot
        self.listByText = listByText
    }
    
    func getNumberOfCells() -> Int {
        return allContent.count
    }
    
    func getImage(at ind: Int) -> UIImage? {
        guard let content = allContent[safe: ind] else { return nil }
        if content == .changeColor {
            return getImageWithColor(color: getColor(),
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
    
    func getColor() -> UIColor {
        colorManager.getGradient(index: model.color).medium
    }
    
    func getTextColor() -> UIColor {
        colorManager.getGradient(index: model.color).dark
    }
    
    func getSeparatorLineColor() -> UIColor {
        colorManager.getGradient(index: model.color).light
    }
    
    func controllerDismissed() {
        router?.pop()
    }
    
    func isCheckmarkActive(at ind: Int) -> Bool {
        guard let content = allContent[safe: ind] else { return false }
        if content == .pinch { return model.isFavorite }
        if content == .share { return model.isShared }
        return false
    }
    
    func switchValue(at ind: Int) -> Bool {
        guard let content = allContent[safe: ind] else { return false }
        if content == .imageMatching {
            return model.isShowImage.getBool(defaultValue: UserDefaultsManager.shared.isShowImage)
        }
        if content == .storeAndCost {
#if RELEASE
            guard Apphud.hasActiveSubscription() else {
                return false
            }
#endif
            return model.isVisibleCost
        }
        return false
    }
    
    func isSwitchActive(at ind: Int) -> Bool {
        guard let content = allContent[safe: ind] else { return false }
        return content == .imageMatching || content == .storeAndCost
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
            renameList()
        case .edit:
            editList()
        case .pinch:
            pinList()
        case .changeColor:
            changeListColor()
        case .share:
            shareList()
        case .print:
            printList()
        case .send:
            sendListByText()
        case .delete:
            deleteList()
        default: return
        }
    }
    
    func changeSwitchValue(at ind: Int, isOn: Bool) {
        guard let content = allContent[safe: ind] else { return }
        switch content {
        case .storeAndCost:
#if RELEASE
        if !Apphud.hasActiveSubscription() {
            delegate?.reloadController()
            showPaywall()
            return
        }
#endif

            model.isVisibleCost = !model.isVisibleCost
            savePatametrs()
        case .imageMatching:
            AmplitudeManager.shared.logEvent(.setAutoimageToggle, properties: [.isActive: isOn ? .yes : .valueNo])
            model.isShowImage = isOn ? .itsTrue : .itsFalse
            savePatametrs()
        default: break
        }
    }
    
    private func renameList() {
        AmplitudeManager.shared.logEvent(.setRename)
        router?.presentCreateNewList(model: model) { [weak self] newModel, products  in
            self?.model = newModel
            self?.copiedProducts = products
            self?.savePatametrs()
        }
    }
    
    private func editList() {
        delegate?.dismissController(comp: { [weak self] in
            self?.editCallback?(.edit)
        })
    }
    
    private func pinList() {
        AmplitudeManager.shared.logEvent(.setFix)
        model.isFavorite = !model.isFavorite
        savePatametrs()
    }
    
    private func changeListColor() {
        AmplitudeManager.shared.logEvent(.setColor)
        router?.presentCreateNewList(model: model) { [weak self] newModel, products  in
            self?.model = newModel
            self?.copiedProducts = products
            self?.savePatametrs()
        }
    }
    
    private func shareList() {
        AmplitudeManager.shared.logEvent(.setInvite)
        delegate?.dismissController(comp: { [weak self] in
            self?.editCallback?(.share)
        })
    }
    
    private func printList() {
        AmplitudeManager.shared.logEvent(.setPrint)
        guard let snapshot = snapshot else { return }
        router?.showPrintVC(image: snapshot)
    }
    
    private func sendListByText() {
        AmplitudeManager.shared.logEvent(.listSendedText)
        router?.showActivityVC(image: [listByText])
    }
    
    private func deleteList() {
        AmplitudeManager.shared.logEvent(.setDelete)
        CoreDataManager.shared.removeList(model.id)
        delegate?.dismissController(comp: { [weak self] in
            self?.controllerDismissed()
        })
    }
    
    private func savePatametrs() {
        delegate?.reloadController()
        valueChangedCallback?(model, copiedProducts)
        CoreDataManager.shared.saveList(list: model)
    }
    
    private func showPaywall() {
        router?.showPaywallVCOnTopController()
    }
}

extension ProductsSettingsViewModel {
    enum TableViewContent: Int, CaseIterable {
        case edit
        case pinch
        case rename
        case share
        case send
        case storeAndCost
        case changeColor
        case imageMatching
        case print
        case delete
        
        var image: UIImage? {
            switch self {
            case .rename:           return R.image.rename()
            case .edit:             return R.image.editCell()
            case .pinch:            return R.image.pin()
            case .changeColor:      return R.image.color()
            case .storeAndCost:     return R.image.bankCard()?.withTintColor(.black)
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
            case .storeAndCost:     return R.string.localizable.displayCostAndStore()
            case .imageMatching:    return R.string.localizable.pictureMatching()
            case .share:            return R.string.localizable.shared()
            case .print:            return R.string.localizable.print()
            case .send:             return R.string.localizable.send()
            case .delete:           return R.string.localizable.delete()
            }
        }
    }
}
