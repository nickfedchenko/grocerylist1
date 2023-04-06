//
//  SearchInListCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.03.2023.
//

import UIKit

final class SearchInListCell: UICollectionViewCell {
    
    var listTapped: (() -> Void)?
    var shareTapped: (() -> Void)?
    var purchaseTapped: ((Product) -> Void)?
    
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
    
    private lazy var productStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        return stackView
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sharingView.clearView()
    }
    
    func configureList(_ list: GroceryListsModel) {
        listViewColor = ColorManager().getGradient(index: list.color).0
        listView.backgroundColor = listViewColor
        listTitleLabel.text = list.name
        let doneProducts = list.products.filter { $0.isPurchased }
        countLabel.text = "\(doneProducts.count) / \(list.products.count)"
        
        sharingView.configure(state: list.isShared ? .added : .invite,
                              images: getShareImages(list))
    }
    
    func configureProducts(_ products: [Product]?) {
        productStackView.removeAllArrangedSubviews()
        
        guard let products else { return }
        products.forEach { product in
            let view = SearchInListProductView(product: product)
            view.configuration(textColor: listViewColor)
            view.updatePurchaseStatusAction = { [weak self] product in
                self?.purchaseTapped?(product)
            }
            productStackView.addArrangedSubview(view)
            view.snp.makeConstraints { $0.height.equalTo(48) }
        }
    }

    private func setup() {
        self.backgroundColor = .clear
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        setupShadowView()
        
        let tapOnListView = UITapGestureRecognizer(target: self, action: #selector(tapOnList))
        listView.addGestureRecognizer(tapOnListView)
        let tapOnSharingView = UITapGestureRecognizer(target: self, action: #selector(tapOnShare))
        sharingView.addGestureRecognizer(tapOnSharingView)
        
        makeConstraints()
    }
    
    @objc
    private func tapOnList() {
        listTapped?()
    }

    @objc
    private func tapOnShare() {
        shareTapped?()
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
        shadowOneView.addCustomShadow(color: UIColor(hex: "#484848"),
                                      opacity: 0.15,
                                      radius: 1,
                                      offset: .init(width: 0, height: 0.5))
        shadowTwoView.addCustomShadow(color: UIColor(hex: "#858585"),
                                      opacity: 0.1,
                                      radius: 6,
                                      offset: .init(width: 0, height: 6))
    }
    
    private func makeConstraints() {
        self.addSubviews([shadowOneView, shadowTwoView, containerView])
        containerView.addSubviews([listView, productStackView])
        listView.addSubviews([listTitleLabel, countLabel, sharingView])
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        listView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(72)
        }
        
        productStackView.snp.makeConstraints {
            $0.top.equalTo(listView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
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
            shadowView.snp.makeConstraints { $0.edges.equalTo(productStackView) }
        }
    }
}
