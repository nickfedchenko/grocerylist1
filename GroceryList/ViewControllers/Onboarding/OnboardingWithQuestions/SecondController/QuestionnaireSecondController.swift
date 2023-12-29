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
        "IMG for export (PNG or JPEG) 2",
        "IMG for export (PNG or JPEG) 4",
        "IMG for export (PNG or JPEG) 7",
        "IMG for export (PNG or JPEG) 12",
        "IMG for export (PNG or JPEG) 13"
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
