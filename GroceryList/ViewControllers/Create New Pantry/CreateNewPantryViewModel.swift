//
//  CreateNewPantryViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 25.05.2023.
//

import UIKit

protocol CreateNewPantryViewModelDelegate: AnyObject {
    func updateColor()
    func selectedIcon(_ icon: UIImage?)
}
 
final class CreateNewPantryViewModel {
    
    weak var router: RootRouter?
    weak var delegate: CreateNewPantryViewModelDelegate?
    var updateUI: ((PantryModel) -> Void)?
    
    private var pantryListTemplates: [PantryListTemplate]
    private let colorManager = ColorManager.shared
    private var selectedThemeIndex = 0
    private(set) var selectedTheme: Theme {
        didSet { delegate?.updateColor() }
    }
    
    init() {
        pantryListTemplates = [
            PantryListTemplate(icon: R.image.baby(),
                               title: R.string.localizable.baby()),
            PantryListTemplate(icon: R.image.medications(),
                               title: R.string.localizable.medications()),
            PantryListTemplate(icon: R.image.cookingSupplies(),
                               title: R.string.localizable.cookingSupplies()),
            PantryListTemplate(icon: R.image.car(),
                               title: R.string.localizable.car()),
            PantryListTemplate(icon: R.image.tools(),
                               title: R.string.localizable.tools()),
            PantryListTemplate(icon: R.image.handiwork(),
                               title: R.string.localizable.handiwork()),
            PantryListTemplate(icon: R.image.subscriptions(),
                               title: R.string.localizable.subscriptions()),
            PantryListTemplate(icon: R.image.sport(),
                               title: R.string.localizable.sport()),
            PantryListTemplate(icon: R.image.gifts(),
                               title: R.string.localizable.gifts())
        ]
        
        selectedTheme = colorManager.getGradient(index: selectedThemeIndex)
    }
    
    func getPantryTemplates() -> [PantryListTemplate] {
        pantryListTemplates
    }
    
    func getDarkColor(by index: Int) -> UIColor {
        colorManager.getGradient(index: index).dark
    }
    
    func getMediumColor(by index: Int) -> UIColor {
        colorManager.getGradient(index: index).medium
    }
    
    func getLightColor(by index: Int) -> UIColor {
        colorManager.getGradient(index: index).light
    }
    
    func setColor(at index: Int) {
        selectedTheme = colorManager.getGradient(index: index)
    }
    
    func getNumberOfCells() -> Int {
        colorManager.gradientsCount
    }
    
    func selectedTemplate(by index: Int) -> PantryListTemplate {
        return pantryListTemplates[index]
    }
    
    func showAllIcons(by viewController: UIViewController, icon: UIImage?) {
        let selectIconViewController = SelectIconViewController()
        selectIconViewController.icon = icon
        selectIconViewController.updateColor(theme: selectedTheme)
        selectIconViewController.selectedIcon = { [weak self] icon in
            self?.delegate?.selectedIcon(icon)
        }
        selectIconViewController.modalPresentationStyle = .overCurrentContext
        selectIconViewController.modalTransitionStyle = .crossDissolve
        viewController.present(selectIconViewController, animated: true)
    }
    
    func savePantryList(name: String?, icon: UIImage?,
                        synchronizedLists: [UUID]) {
        let pantry = PantryModel(name: name ?? "No name",
                                 color: selectedThemeIndex,
                                 icon: icon?.pngData(),
                                 synchronizedLists: synchronizedLists)
        updateUI?(pantry)
    }
}
