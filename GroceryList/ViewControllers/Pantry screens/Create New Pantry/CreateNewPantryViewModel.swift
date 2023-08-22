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
    func updateSelectListButton(isLinked: Bool)
}
 
final class CreateNewPantryViewModel {
    
    weak var router: RootRouter?
    weak var delegate: CreateNewPantryViewModelDelegate?
    var updateUI: ((PantryModel?) -> Void)?
    
    private var pantryListTemplates: [PantryListTemplate] = []
    private let colorManager = ColorManager.shared
    private var synchronizedLists: [UUID] = []
    private var selectedThemeIndex = 0
    private(set) var currentPantry: PantryModel?
    private(set) var selectedTheme: Theme {
        didSet { delegate?.updateColor() }
    }
    
    init(currentPantry: PantryModel?) {
        self.currentPantry = currentPantry
        selectedThemeIndex = currentPantry?.color ?? 0
        selectedTheme = colorManager.getGradient(index: selectedThemeIndex)
        setupTemplates()
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
        selectedThemeIndex = index
        selectedTheme = colorManager.getGradient(index: index)
    }
    
    func getNumberOfCells() -> Int {
        colorManager.gradientsCount
    }
    
    func selectedTemplate(by index: Int) -> PantryListTemplate {
        return pantryListTemplates[index]
    }
    
    func showAllIcons(icon: UIImage?) {
        router?.showAllIcons(icon: icon, selectedTheme: selectedTheme,
                             selectedIcon: { [weak self] icon in
            self?.delegate?.selectedIcon(icon)
        })
    }
    
    func showSelectList(contentViewHeigh: Double) {
        router?.showSelectList(contentViewHeigh: contentViewHeigh,
                               synchronizedLists: synchronizedLists,
                               updateUI: { [weak self] uuids in
            self?.delegate?.updateSelectListButton(isLinked: !uuids.isEmpty)
            self?.synchronizedLists = uuids
        })
    }
    
    func savePantryList(name: String?, icon: UIImage?) {
        let pantry: PantryModel
        let name = name ?? "No name"
        if var currentPantry {
            currentPantry.name = name
            currentPantry.icon = icon?.pngData()
            currentPantry.color = selectedThemeIndex
            currentPantry.synchronizedLists = synchronizedLists
            pantry = currentPantry
        } else {
            let index = CoreDataManager.shared.getAllPantries()?.count ?? 1
            pantry = PantryModel(name: name,
                                 index: -index,
                                 color: selectedThemeIndex,
                                 icon: icon?.pngData(),
                                 synchronizedLists: synchronizedLists)
        }
        CoreDataManager.shared.savePantry(pantry: [pantry])
        CloudManager.saveCloudData(pantryModel: pantry)
        AmplitudeManager.shared.logEvent(.pantryListCreated)
        if !synchronizedLists.isEmpty {
            AmplitudeManager.shared.logEvent(.pantryLinkListCreated)
        }
        updateUI?(pantry)
    }
    
    private func setupTemplates() {
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
    }
}
