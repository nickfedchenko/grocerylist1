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
}

class ProductsSettingsViewModel {
    
    private var snapshot: UIImage?
    private var model: GroseryListsModel
    weak var router: RootRouter?
    var valueChangedCallback: (() -> Void)?
    weak var delegate: ProductSettingsViewDelegate?
    
    private var colorManager = ColorManager()
   
    init(model: GroseryListsModel, snapshot: UIImage?) {
        self.model = model
        self.snapshot = snapshot
    }
    
    func getNumberOfCells() -> Int {
        return TableViewContent.allCases.count
    }
    
    func getImage(at ind: Int) -> UIImage? {
        return TableViewContent.allCases[ind].image
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
    
    func cellSelected(at ind: Int) {
        guard let snapshot = snapshot else { return }

        switch ind {
        case 0:
            rename()
        case 1:
            pinch()
        case 2:
            changeColor()
        case 3:
            print("")
        case 4:
            byCategory()
        case 5:
            byTime()
        case 6:
            byAlphabet()
        case 7:
            UIImageWriteToSavedPhotosAlbum(snapshot, self, nil, nil)
        case 8:
            router?.showPrintVC(image: snapshot)
        case 9:
            router?.showActivityVC(image: [snapshot])
        case 10:
            CoreDataManager.shared.removeList(model.id)
            delegate?.dismissController()
        default:
            print("")
        }
        
        func rename() {
            
        }
        
        func pinch() {
            
        }
        
        func changeColor() {
            
        }
        
        func byCategory() {
            
        }
        
        func byTime() {
            
        }
        
        func byAlphabet() {
            
        }
    }
    

}


extension ProductsSettingsViewModel {
    enum TableViewContent: String, CaseIterable {
        case rename
        case pinch
        case changeColor
        case sort
        case byCategory
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
            case .byTime, .byAlphabet, .byCategory:
                return true
            default:
                return false
            }
        }
    }
}
