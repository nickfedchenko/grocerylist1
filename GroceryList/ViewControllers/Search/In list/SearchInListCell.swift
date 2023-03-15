//
//  SearchInListCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.03.2023.
//

import UIKit

final class SearchInListCell: UITableViewCell {
    
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
    
    private var listViewColor: UIColor = .white
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.autoresizingMask = .flexibleHeight
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
        self.selectionStyle = .none
        self.backgroundColor = .clear
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
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
    
    private func makeConstraints() {
        self.addSubview(containerView)
        containerView.addSubviews([listView, productStackView])
        listView.addSubviews([listTitleLabel, countLabel, sharingView])
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
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
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
