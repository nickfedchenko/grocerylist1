//
//  RateUsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 26.12.2023.
//

import Foundation
import UIKit

final class RateUsViewModel {
    
    var applyShapshot: ((NSDiffableDataSourceSnapshot<RateUsSection, RateUsModel>) -> Void)?
    var scrollToPage: ((Int) -> Void)?
    var updateStateCallback: (() -> Void)?
    weak var router: RootRouter?
 
    private var ratingValue = 0
    
    func viewDidLoad() {
        reloadData()
    }
    
    func closeButtonTapped() {
        router?.dismissCurrentController()
    }
    
    func ratingSelected(ratingValue: Int) {
        self.ratingValue = ratingValue
    }
    
    func cellSelected(at index: IndexPath) {
        switch index.row {
        case 1, 2:
            scrollToPage?(1)
        default:
            router?.dismissCurrentController(compl: { [weak self] in
                self?.router?.openContactUsController()
            })
        }
    }
    
    func nextButtonTapped() {
        likeAppViewAction()
    }

    // ReloadData
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<RateUsSection, RateUsModel>()
        
        snapshot.appendSections([.main, .positive])
       
        snapshot.appendItems(
            [
                .topCell(model: .first),
                .bottomCell(model: .veryGood),
                .bottomCell(model: .good),
                .bottomCell(model: .neutral),
                .bottomCell(model: .bad),
                .bottomCell(model: .veryBad)
            ],
            toSection: .main)
        
        snapshot.appendItems([.topCell(model: .second)], toSection: .positive)

        applyShapshot?(snapshot)
    }
    
    private func likeAppViewAction() {
        guard let
                url = URL(string: ""),
              UIApplication.shared.canOpenURL(url)
        else { return }
        UIApplication.shared.open(url)
    }
}
