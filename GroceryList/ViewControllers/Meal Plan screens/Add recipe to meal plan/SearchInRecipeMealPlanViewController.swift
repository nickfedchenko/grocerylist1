//
//  SearchInRecipeMealPlanViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.09.2023.
//

import UIKit

class SearchInRecipeMealPlanViewController: SearchInRecipeViewController {

    override var isMealPlanMode: Bool {
        true
    }
    
    private let grabberBackgroundView = UIView()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "3C3C43", alpha: 0.3)
        view.setCornerRadius(2.5)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabberBackgroundView.backgroundColor = UIColor(hex: "#E5F5F3").withAlphaComponent(0.9)
        collectionView.contentInset.top = 174
        
        makeConstraints()
    }
    
    override func showContextMenu(_ cell: RecipeListCell, _ point: CGPoint, _ index: Int) {
        viewModel?.showRecipeForMealPlan(recipeIndex: index)
    }

    override func tapCell(_ indexPath: IndexPath) {
        viewModel?.showRecipeForMealPlan(recipeIndex: indexPath.row)
    }
    
    private func makeConstraints() {
        navigationView.snp.removeConstraints()
        
        self.view.addSubviews([grabberBackgroundView, grabberView])
        
        grabberBackgroundView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(22)
        }
        
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(5)
            $0.width.equalTo(36)
        }
        
        navigationView.snp.makeConstraints {
            $0.top.equalTo(grabberBackgroundView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(104)
        }
    }
}
