//
//  OnboardingWithQuestionSecondController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.12.2023.
//

import Foundation
class QuestionnaireSecondController: NewOnboardingViewController {
    
    override var screenNames: [String] {
       [
        "IMG for export (PNG or JPEG) 1",
        "IMG for export (PNG or JPEG) 2"
        ]
    }
    
    @objc
    override func nextButtonPressed() {
        if currentPage < screenNames.count - 1 {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            router?.popToRootFromOnboarding()
            router?.openQuestionnaireThirdController()
        }
    }
   
}
