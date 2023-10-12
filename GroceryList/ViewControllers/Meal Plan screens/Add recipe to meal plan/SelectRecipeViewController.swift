//
//  SelectRecipeViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.09.2023.
//

import ApphudSDK
import UIKit

class SelectRecipeViewModel: MainRecipeViewModel {
    
    var selectedDate: Date = Date()
    var mealPlanDate: ((Date) -> Void)?
    
    override func showSearch() {
#if RELEASE
        if !Apphud.hasActiveSubscription() {
            showPaywall()
            return
        }
#endif
        router?.goToSearchInMealPlan(date: selectedDate)
    }
    
    override func showSection(by index: Int) {
        guard let section = getRecipeSectionsModel(for: index) else {
            return
        }
        router?.goToRecipeCollectionFromMealPlan(for: section, date: selectedDate)
    }
    
    override func showRecipe(by indexPath: IndexPath) {
        guard let recipeId = dataSource.recipesSections[safe: indexPath.section]?
                                       .recipes[safe: indexPath.item - 1]?.id,
              let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId),
              let model = Recipe(from: dbRecipe) else {
            return
        }
        router?.goToRecipeFromMealPlan(recipe: model, date: selectedDate, selectedDate: mealPlanDate)
    }
}

class SelectRecipeViewController: MainRecipeViewController {

    override var recipeIsFolderView: Bool {
        isFolder
    }
    
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "3C3C43", alpha: 0.3)
        view.setCornerRadius(2.5)
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.cancel(), for: .normal)
        button.setTitleColor(R.color.primaryDark(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.bold(size: 16).font
        button.addTarget(self, action: #selector(tappedOnCancel), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.selectRecipe()
        label.font = UIFont.SFPro.bold(size: 16).font
        label.textColor = R.color.darkGray()
        return label
    }()
    
    private var isFolder = UserDefaultsManager.shared.recipeIsFolderView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraints()
    }
    
    override func updateCollectionContentInset() {
        let topContentInset = navigationView.frame.height
        let contentInset: CGFloat = recipeIsFolderView ? 0 : 8
        recipesCollectionView.contentInset.top = topContentInset + contentInset
    }
    
    override func recipeChangeViewAction() {
        isFolder.toggle()
        let image = isFolder ? R.image.recipeCollectionView() : R.image.recipeFolderView()
        let contentInset: CGFloat = isFolder ? 68 : 78
        recipeChangeViewButton.setImage(image, for: .normal)

        DispatchQueue.main.async {
            self.recipesCollectionView.contentInset.top = self.topContentInset + contentInset
            self.recipesCollectionView.reloadData()
            self.recipesCollectionView.collectionViewLayout.invalidateLayout()
            let layout = self.collectionViewLayoutManager.makeRecipesLayout(isFolder: self.isFolder)
            self.recipesCollectionView.setCollectionViewLayout(layout, animated: false)
            self.recipesCollectionView.collectionViewLayout.collectionView?.reloadData()
            
            if self.isFolder {
                self.recipesCollectionView.reloadData()
            }
        }
    }
    
    @objc
    private func tappedOnCancel() {
        self.dismiss(animated: true)
    }
    
    private func makeConstraints() {
        self.navigationView.addSubviews([cancelButton, grabberView, titleLabel])
        
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(5)
            $0.width.equalTo(36)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.centerX.equalToSuperview()
        }
        
        searchView.snp.removeConstraints()
        recipeChangeViewButton.snp.removeConstraints()
        recipeEditCollectionButton.snp.removeConstraints()
        
        searchView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(78)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        recipeChangeViewButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(40)
        }
        
        recipeEditCollectionButton.isHidden = true
    }
}
