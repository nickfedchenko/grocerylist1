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
    var scrollToPage: ((Int) -> Void)?
    var isMultiselectionEnabled: ((Bool) -> Void)?
    var isNextButtonEnabled: ((Bool) -> Void)?
    
    var dataSource: QuestionnaireThirdDataSource
    weak var router: RootRouter?
    
    private var currentPage = 0

    // MARK: - Init
    init() {
        self.dataSource = QuestionnaireThirdDataSource()
    }
    
    func viewDidLoad() {
        router?.openQuestionnaireFirstPaywall()
        reloadData()
    }
    
    func nextButtonTapped() {
        if currentPage < dataSource.sections.count - 1 {
            currentPage += 1
            scrollToPage?(currentPage)
            isMultiselectionEnabled?(dataSource.sections[currentPage].isMultiselectionEnabled)
            isNextButtonEnabled?(dataSource.isNextButtonEnabled(page: currentPage))
        } else {
            print("done")
            router?.popToRoot()
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.router?.openPaywallWithTimer()
            }
        }
    }
    
    func cellSelected(at indexPath: IndexPath) {
        dataSource.questionSelected(indexPath: indexPath)
        isNextButtonEnabled?(dataSource.isNextButtonEnabled(page: currentPage))
    }
    
    func cellDeselected(at indexPath: IndexPath) {
        if dataSource.sections[currentPage].isMultiselectionEnabled {
            dataSource.questionSelected(indexPath: indexPath)
        }

        isNextButtonEnabled?(dataSource.isNextButtonEnabled(page: currentPage))
    }
    
    // ReloadData
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<QuestionnaireThirdControllerSections, QuestionnaireThirdControllerCellModel>()
        
        snapshot.appendSections(dataSource.sections)

        dataSource.sections.forEach({
            snapshot.appendItems([$0.getHeaderModel()], toSection: $0)
            snapshot.appendItems($0.getQuestionModels(), toSection: $0)
        })

        applyShapshot?(snapshot)
    }
}
