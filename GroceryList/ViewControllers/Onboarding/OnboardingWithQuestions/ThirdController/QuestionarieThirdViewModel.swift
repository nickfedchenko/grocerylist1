//
//  QuestionarieThirdViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.12.2023.
//

import Foundation
import UIKit

class QuestionnaireThirdViewModel {
    
    var applyShapshot: ((NSDiffableDataSourceSnapshot<QuestionnaireThirdControllerSections, QuestionnaireThirdControllerCellModel>) -> Void)?
    
    weak var router: RootRouter?
    var firstSection = QuestionnaireThirdControllerSections(headerTitle: "Fdfdf", questions: ["fdf1", "ddsd2", "dsds"])
    var secondSection = QuestionnaireThirdControllerSections(headerTitle: "2323", questions: ["535", "gfgg", "ds2"])

    lazy var sections = [firstSection, secondSection]
 
    // MARK: - Init
    init() {
 
    }
    
    func viewDidLoad() {
        reloadData()
    }
    
    // ReloadData
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<QuestionnaireThirdControllerSections, QuestionnaireThirdControllerCellModel>()
        
        snapshot.appendSections(sections)
        
        print(firstSection.getQuestionModels())
        snapshot.appendItems([firstSection.getHeaderModel()], toSection: firstSection)
        snapshot.appendItems(firstSection.getQuestionModels(), toSection: firstSection)
        
        snapshot.appendItems([secondSection.getHeaderModel()], toSection: secondSection)
        snapshot.appendItems(secondSection.getQuestionModels(), toSection: secondSection)
        applyShapshot?(snapshot)
      //  collectionViewDataSource?.apply(snapshot, animatingDifferences: false)
    }
}
