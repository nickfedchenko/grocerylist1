//
//  PreparationStepViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 06.03.2023.
//

import Foundation

final class PreparationStepViewModel {
    
    var stepNumber: Int
    var stepCallback: ((String) -> Void)?
    
    init(stepNumber: Int) {
        self.stepNumber = stepNumber
    }
    
    func save(step: String) {
        stepCallback?(step)
    }
}
