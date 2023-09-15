//
//  RecipesListFromMealPlanViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.09.2023.
//

import UIKit

class RecipesListFromMealPlanViewController: RecipesListViewController {

    private let grabberBackgroundView = UIView()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "3C3C43", alpha: 0.3)
        view.setCornerRadius(2.5)
        return view
    }()
    
    override var recipeIsTableView: Bool {
        isTable
    }
    
    override var isMealPlanMode: Bool {
        true
    }
    
    private var isTable = UserDefaultsManager.shared.recipeIsTableView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabberBackgroundView.backgroundColor = viewModel.theme.light.withAlphaComponent(0.95)
        recipesListCollectionView.contentInset.top = 134
        
        contextMenuBackgroundView.isHidden = true
        contextMenuView.isHidden = true
        messageView.isHidden = true
        photoView.isHidden = true
        header.searchButton.isHidden = true
        
        titleView.setFont(font: .SFPro.bold(size: 24).font)
        titleView.maximumLineHeight = 40
    }
    
    override func photoViewUpdateConstraints() { }
    
    override func changeListView() {
        isTable.toggle()
        header.updateImageChangeViewButton(recipeIsTableView: recipeIsTableView)
        recipesListCollectionView.reloadData()
    }
    
    override func showContextMenu(_ cell: RecipeListCell, _ point: CGPoint, _ index: Int) {
        viewModel.showRecipeForMealPlan(recipeIndex: index)
    }
    
    override func tapCell(_ indexPath: IndexPath) {
        viewModel.showRecipeForMealPlan(recipeIndex: indexPath.item)
    }
    
    override func setupSubviews() {
        self.view.addSubviews([recipesListCollectionView,
                               grabberBackgroundView, grabberView,
                               header, titleView])
        
        grabberBackgroundView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(titleView.snp.top)
        }
        
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(5)
            $0.width.equalTo(36)
        }
        
        header.snp.makeConstraints {
            $0.top.equalTo(22)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        recipesListCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(68)
            $0.top.greaterThanOrEqualTo(header.snp.bottom)
        }
    }
}
