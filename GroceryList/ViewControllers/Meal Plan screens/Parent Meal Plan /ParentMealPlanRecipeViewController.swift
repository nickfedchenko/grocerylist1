//
//  ParentMealPlanRecipeViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.08.2023.
//

import SJSegmentedScrollView
import UIKit

class ParentMealPlanRecipeViewController: SJSegmentedViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    var currentIndex: Int {
        segmentedControl.selectedSegmentIndex
    }
    
    private lazy var segmentedControl: CustomSegmentedControlView = {
        let segmentedControl = CustomSegmentedControlView(items: [R.string.localizable.mealPlan(),
                                                                  R.string.localizable.recipes()],
                                                          select: selectConfiguration,
                                                          unselect: unselectConfiguration)
        segmentedControl.delegate = self
        segmentedControl.selectedSegmentIndex = UserDefaultsManager.shared.selectedMealPlannerOrRecipes
        return segmentedControl
    }()

    private let selectConfiguration = SegmentView.Configuration(
        titleColor: R.color.primaryDark(),
        font: UIFont.SFPro.bold(size: 18).font,
        borderColor: UIColor.clear.cgColor,
        borderWidth: 0,
        backgroundColor: .white
    )
    
    private let unselectConfiguration = SegmentView.Configuration(
        titleColor: R.color.darkGray(),
        font: UIFont.SFPro.bold(size: 18).font,
        borderColor: UIColor.clear.cgColor,
        borderWidth: 0,
        backgroundColor: .clear
    )
     
    override func viewDidLoad() {
        setupSJSegmented()
        super.viewDidLoad()

        makeConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as? MainTabBarController)?.isHideNavView(isHide: true)
        
        updateUI(index: UserDefaultsManager.shared.selectedMealPlannerOrRecipes)
        setSelectedSegmentAt(UserDefaultsManager.shared.selectedMealPlannerOrRecipes, animated: true)
    }
    
    private func setupSJSegmented() {
        selectedSegmentViewColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        segmentViewHeight = 0
        segmentBounces = false
        delegate = self
    }
    
    private func updateUI(index: Int) {
        segmentedControl.segmentedBackgroundColor = index == 0 ? R.color.primaryLight() : UIColor(hex: "CBEEEE")
        
        let tabBarText = index == 0 ? R.string.localizable.recipe() : R.string.localizable.create()
        (self.tabBarController as? MainTabBarController)?.setTextTabBar(text: tabBarText.uppercased())
        
        if index == 0 {
            self.segmentControllers.forEach {
                ($0 as? MealPlanViewController)?.viewModel.updateStorage()
            }
        }
    }
    
    private func makeConstraints() {
        self.view.addSubviews([segmentedControl])
        
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
    }
}

extension ParentMealPlanRecipeViewController: SJSegmentedViewControllerDelegate {
    func didMoveToPage(_ controller: UIViewController,
                       segment: SJSegmentTab?, index: Int) {
        segmentedControl.selectedSegmentIndex = index
    }
}

extension ParentMealPlanRecipeViewController: CustomSegmentedControlViewDelegate {
    func segmentChanged(_ selectedSegmentIndex: Int) {
        AmplitudeManager.shared.logEvent(selectedSegmentIndex == 0 ? .mplanSection : .recipesSection)
        Vibration.heavy.vibrate()
        segmentedControl.selectedSegmentIndex = selectedSegmentIndex
        setSelectedSegmentAt(selectedSegmentIndex, animated: true)
        updateUI(index: selectedSegmentIndex)
        UserDefaultsManager.shared.selectedMealPlannerOrRecipes = selectedSegmentIndex
    }
}
