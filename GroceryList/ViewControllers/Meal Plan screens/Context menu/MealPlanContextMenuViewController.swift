//
//  MealPlanContextMenuViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 28.09.2023.
//

import UIKit

class MealPlanContextMenuViewController: UIViewController {

    private let mealPlan: MealPlan?
    private let contextMenuView = MealPlanContextMenuView()
    
    init(contextDelegate: MealPlanContextMenuViewDelegate, mealPlan: MealPlan?) {
        self.mealPlan = mealPlan
        contextMenuView.delegate = contextDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
        
        let menuTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(menuTapAction))
        self.view.addGestureRecognizer(menuTapRecognizer)

        contextMenuView.configureSharing(state: getSharingState(),
                                         color: R.color.primaryDark() ?? .black,
                                         images: [])
        
        makeConstraints()
    }
    
    func getSharingState() -> SharingView.SharingState {
        .invite
//        model.isShared ? .added : .invite
    }
    
    func getShareImages() -> [String?] {
        var arrayOfImageUrls: [String?] = []
        
        getSharedListsUsers().forEach { user in
            if user.token != UserAccountManager.shared.getUser()?.token {
                arrayOfImageUrls.append(user.avatar)
            }
        }
        return arrayOfImageUrls
    }
    
    private func getSharedListsUsers() -> [User] {
        []
//        return SharedListManager.shared.sharedListsUsers[model.sharedId] ?? []
    }
    
    @objc
    private func menuTapAction() {
        self.dismiss(animated: true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([contextMenuView])
        
        contextMenuView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.greaterThanOrEqualTo(contextMenuView.requiredHeight)
            $0.width.equalTo(250)
        }
    }
}