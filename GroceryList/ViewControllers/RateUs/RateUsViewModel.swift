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
    var updateStateCallback: (() -> Void)?
    weak var router: RootRouter?
    
    private var models: [RateUsModel] = [
        .topCell(model: .init()),
        .bottomCell(model: .init()),
        .bottomCell(model: .init()),
        .bottomCell(model: .init()),
        .bottomCell(model: .init()),
    ]
 
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
    
    private func likeAppViewAction() {
        guard let
                url = URL(string: "itms-apps://itunes.apple.com/app/reels-reel-maker/id6474242365?action=write-review"),
              UIApplication.shared.canOpenURL(url)
        else { return }
        UIApplication.shared.open(url)
    }

    // ReloadData
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<RateUsSection, RateUsModel>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)

        applyShapshot?(snapshot)
    }
}
