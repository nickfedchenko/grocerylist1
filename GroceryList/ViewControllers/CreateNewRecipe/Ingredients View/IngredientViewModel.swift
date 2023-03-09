//
//  IngredientViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.03.2023.
//

import UIKit

protocol IngredientViewModelDelegate: AnyObject {
    func categoryChange(title: String)
    func unitChange(_ unit: UnitSystem)
}

final class IngredientViewModel {
    
    weak var router: RootRouter?
    weak var delegate: IngredientViewModelDelegate?
    var ingredientCallback: ((Ingredient) -> Void)?
    
    func getNumberOfCells() -> Int {
        selectedUnitSystemArray.count
    }
    
    var productQuantityCount: Double? {
        guard let stringArray = productDescriptionQuantity?.components(separatedBy: .decimalDigits.inverted)
                                                           .filter({ !$0.isEmpty }),
              let lastCount = stringArray.first else {
            return nil
        }
        return Double(lastCount)
    }
    
    private var productDescriptionQuantity: String? {
        guard let description = currentProduct?.description else {
            return nil
        }
        if description.contains(where: { "," == $0 }),
           let firstIndex = description.firstIndex(of: ",") {
            let quantityStr = description[firstIndex..<description.endIndex]
            return String(quantityStr)
        }
        return currentProduct?.description
    }
    private var arrayOfProductsByCategories: [DBNetworkProduct]?
    private var currentProduct: Product?
    private var isMetricSystem = UserDefaultsManager.isMetricSystem
    private var currentSelectedUnit: UnitSystem = .gram
    private var selectedUnitSystemArray: [UnitSystem] {
        isMetricSystem ? arrayForMetricSystem : arrayForImperalSystem
    }
    private var arrayForMetricSystem: [UnitSystem] = [
        UnitSystem.gram,
        UnitSystem.kilogram,
        UnitSystem.liter,
        UnitSystem.mililiter,
        UnitSystem.can,
        UnitSystem.bottle,
        UnitSystem.pack,
        UnitSystem.piece
    ]
    
    private var arrayForImperalSystem: [UnitSystem] = [
        UnitSystem.ozz,
        UnitSystem.lbс,
        UnitSystem.pt,
        UnitSystem.fluidOz,
        UnitSystem.can,
        UnitSystem.bottle,
        UnitSystem.pack,
        UnitSystem.piece
    ]
    
    init() {
        arrayOfProductsByCategories = CoreDataManager.shared.getAllNetworkProducts()?
                                                     .sorted(by: { $0.title ?? "" > $1.title ?? "" })
    }
    
    func save(ingredient: Ingredient) {
        ingredientCallback?(ingredient)
    }
    
    func goToSelectCategoryVC() {
        guard let controller = router?.prepareSelectCategoryController(model: nil, compl: { [weak self] newCategoryName in
            guard let self = self else { return }
            self.delegate?.categoryChange(title: newCategoryName)
        }) else {
            return
        }
        controller.modalTransitionStyle = .crossDissolve
        router?.navigationPresent(controller, animated: true)
    }
    
    func checkIsProductFromCategory(name: String?) {
        guard let arrayOfProductsByCategories,
              var name = name?.lowercased() else {
            return
        }
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        var product: DBNetworkProduct?
        for productDB in arrayOfProductsByCategories {
            guard let title = productDB.title?.lowercased()
                                              .getTitleWithout(symbols: ["(", ")"]) else {
                return
            }
            
            guard title != name else {
                product = productDB
                break
            }
            
            if title.contains(name) {
                product = productDB
            }
        }
        
        guard let product = product else {
            delegate?.categoryChange(title: "Select Category")
            return
        }
        getAllInformation(product: product)
    }
    
    func getAllInformation(product: DBNetworkProduct) {
        let title = product.marketCategory
        let shouldSelectUnit: MarketUnitClass.MarketUnitPrepared = .init(rawValue: Int(product.defaultMarketUnitID)) ?? .gram
        let properSelectedUnit: UnitSystem = {
            switch shouldSelectUnit {
            case .bottle:
                return .bottle
            case .gram:
                return isMetricSystem ? .gram : .ozz
            case .kilogram:
                return isMetricSystem ? .kilogram : .lbс
            case .litter:
                return isMetricSystem ? .liter : .pt
            case .millilitre:
                return isMetricSystem ? .mililiter : .fluidOz
            case .pack:
                return .pack
            case .piece:
                return .piece
            case .tin:
                return .can
            }
        }()
        currentSelectedUnit = properSelectedUnit
        delegate?.categoryChange(title: title ?? "Select Category")
        delegate?.unitChange(currentSelectedUnit)
    }
    
    func getTitleForCell(at ind: Int) -> String {
        selectedUnitSystemArray[ind].rawValue.localized
    }
    
    func cellSelected(at ind: Int) {
        let step = selectedUnitSystemArray[ind]
        delegate?.unitChange(step)
    }
}
