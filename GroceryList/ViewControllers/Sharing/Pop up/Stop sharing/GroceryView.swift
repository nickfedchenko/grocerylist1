//
//  GroceryView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 04.09.2023.
//

import UIKit

class GroceryView: UIView {

    private let containerView = UIView()
    private let listView = UIView()
    private let sharingView = SharingView()
    
    private lazy var listTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        return label
    }()
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    
    private var listViewColor: UIColor = .white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureList(_ list: GroceryListsModel) {
        listViewColor = ColorManager.shared.getGradient(index: list.color).medium
        listView.backgroundColor = listViewColor
        listTitleLabel.text = list.name
        let doneProducts = list.products.filter { $0.isPurchased }
        countLabel.text = "\(doneProducts.count) / \(list.products.count)"
        
        sharingView.configure(state: list.isShared ? .added : .invite,
                              viewState: .main,
                              color: listViewColor,
                              images: getShareImages(list))
    }

    private func setup() {
        self.backgroundColor = .clear
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        
        listView.layer.cornerRadius = 8
        listView.layer.borderColor = UIColor.white.cgColor
        listView.layer.borderWidth = 1
        
        setupShadowView()
        makeConstraints()
    }
    
    private func getShareImages(_  list: GroceryListsModel) -> [String?] {
        var arrayOfImageUrls: [String?] = []
        
        if let newUsers = SharedListManager.shared.sharedListsUsers[list.sharedId] {
            newUsers.forEach { user in
                if user.token != UserAccountManager.shared.getUser()?.token {
                    arrayOfImageUrls.append(user.avatar)
                }
            }
        }
        return arrayOfImageUrls
    }
    
    private func setupShadowView() {
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.backgroundColor = .white
            shadowView.layer.cornerRadius = 8
        }
        shadowOneView.addShadow(color: .black,
                                      opacity: 0.15,
                                      radius: 11,
                                      offset: .init(width: 0, height: 12))
        shadowTwoView.addShadow(color: .black,
                                      opacity: 0.06,
                                      radius: 3,
                                      offset: .init(width: 0, height: 2))
    }
    
    private func makeConstraints() {
        self.addSubviews([shadowOneView, shadowTwoView, containerView])
        containerView.addSubviews([listView])
        listView.addSubviews([listTitleLabel, countLabel, sharingView])
        
        containerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        listView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(72)
        }
        
        listTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(sharingView.snp.leading).offset(-8)
            $0.height.equalTo(24)
        }
        
        countLabel.snp.makeConstraints {
            $0.top.equalTo(listTitleLabel.snp.bottom).offset(2)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(sharingView.snp.leading).offset(-8)
            $0.height.equalTo(24)
        }
        
        sharingView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.snp.makeConstraints { $0.edges.equalTo(listView) }
        }
    }
}
