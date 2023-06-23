//
//  PantryListOptionViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.06.2023.
//

import ApphudSDK
import UIKit

final class PantryListOptionViewModel: ProductsSettingsViewModel {

    var updateUI: ((PantryModel) -> Void)?
    var goToEditList: (() -> Void)?
    
    private var colorManager = ColorManager()
    private var pantry: PantryModel
    private let allContent: [ProductsSettingsViewModel.TableViewContent] = [
        .edit, .rename, .share, .send, .storeAndCost,
        .changeColor, .imageMatching, .print, .delete
    ]

    init(pantry: PantryModel, snapshot: UIImage?, listByText: String) {
        self.pantry = pantry
        super.init(model: GroceryListsModel(dateOfCreation: Date(), color: 0, products: [], typeOfSorting: 0),
                   snapshot: snapshot, listByText: listByText)
    }
    
    override func getNumberOfCells() -> Int {
        return allContent.count
    }
    
    override func getImage(at ind: Int) -> UIImage? {
        guard let content = allContent[safe: ind] else { return nil }
        if content == .changeColor {
            return getImageWithColor(color: getColor(),
                                     size: CGSize(width: 28, height: 28))?.rounded(radius: 100)
        }
        return allContent[ind].image
    }
    
    override func getImageWithColor(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func getText(at ind: Int) -> String? {
        return allContent[ind].title
    }
    
    override func getColor() -> UIColor {
        colorManager.getGradient(index: pantry.color).medium
    }
    
    override func getTextColor() -> UIColor {
        colorManager.getGradient(index: pantry.color).dark
    }
    
    override func getSeparatorLineColor() -> UIColor {
        colorManager.getGradient(index: pantry.color).light
    }

    override func switchValue(at ind: Int) -> Bool {
        guard let content = allContent[safe: ind] else { return false }
        if content == .imageMatching {
            return pantry.isShowImage.getBool(defaultValue: UserDefaultsManager.isShowImage)
        }
        if content == .storeAndCost {
            
#if RELEASE
            guard Apphud.hasActiveSubscription() else {
                return false
            }
#endif
            return pantry.isVisibleCost
        }
        return false
    }
    
    override func isSwitchActive(at ind: Int) -> Bool {
        guard let content = allContent[safe: ind] else { return false }
        return content == .imageMatching || content == .storeAndCost
    }
    
    override func isSharedList(at ind: Int) -> Bool {
        guard let content = allContent[safe: ind] else { return false }
        return content == .share && pantry.isShared
    }
    
    override func getShareImages() -> [String?] {
        var arrayOfImageUrls: [String?] = []
        
        if let newUsers = SharedPantryManager.shared.sharedListsUsers[pantry.sharedId] {
            newUsers.forEach { user in
                if user.token != UserAccountManager.shared.getUser()?.token {
                    arrayOfImageUrls.append(user.avatar)
                }
            }
        }
        return arrayOfImageUrls
    }
    
    override func cellSelected(at ind: Int) {
#if RELEASE
        if !Apphud.hasActiveSubscription() {
            showPaywall()
            return
        }
#endif
        
        guard let content = allContent[safe: ind] else { return }
        switch content {
        case .edit:
            AmplitudeManager.shared.logEvent(.pantryMenuEdit)
            editList()
        case .rename:
            AmplitudeManager.shared.logEvent(.pantryMenuRename)
            selectedChangeList()
        case .share:
            AmplitudeManager.shared.logEvent(.pantryMenuAddUser)
            shareList()
        case .send:
            AmplitudeManager.shared.logEvent(.pantryMenuSend)
            sendListByText()
        case .print:
            printList()
        case .changeColor:
            AmplitudeManager.shared.logEvent(.pantryMenuColor)
            selectedChangeList()
        case .delete:
            AmplitudeManager.shared.logEvent(.pantryMenuDelete)
            deleteList()
        default: return
        }
    }
    
    override func changeSwitchValue(at ind: Int, isOn: Bool) {
        guard let content = allContent[safe: ind] else { return }
        switch content {
        case .storeAndCost:
            AmplitudeManager.shared.logEvent(.pantryMenuShopsToggle, properties: [.isActive: isOn ? .valueOn : .off])
            pantry.isVisibleCost = isOn
            saveParameters()
        case .imageMatching:
            AmplitudeManager.shared.logEvent(.pantryImageMatchToggle, properties: [.isActive: isOn ? .valueOn : .off])
            pantry.isShowImage = isOn ? .itsTrue : .itsFalse
            saveParameters()
        default: break
        }
    }
    
    func changeList(presentedController: UIViewController) {
        router?.goToCreateNewPantry(presentedController: presentedController,
                                    currentPantry: pantry, updateUI: { newPantry in
            if let newPantry {
                self.pantry = newPantry
                self.saveParameters()
            }
        })
    }
    
    private func selectedChangeList() {
        goToEditList?()
    }
    
    private func editList() {
        delegate?.dismissController(comp: { [weak self] in
            self?.editCallback?(.edit)
        })
    }
    
    private func shareList() {
        delegate?.dismissController(comp: { [weak self] in
            self?.editCallback?(.share)
        })
    }
    
    private func printList() {
        guard let snapshot = snapshot else {
            return
        }
        router?.showPrintVC(image: snapshot)
    }
    
    private func sendListByText() {
        AmplitudeManager.shared.logEvent(.listSendedText)
        router?.showActivityVC(image: [listByText])
    }
    
    private func deleteList() {
        CoreDataManager.shared.deletePantry(by: pantry.id)
        delegate?.dismissController(comp: { [weak self] in
            self?.editCallback?(.delete)
        })
    }
    
    private func saveParameters() {
        CoreDataManager.shared.savePantry(pantry: [pantry])
        delegate?.reloadController()
        updateUI?(pantry)        
    }
    
    private func showPaywall() {
        router?.showPaywallVCOnTopController()
    }
}
