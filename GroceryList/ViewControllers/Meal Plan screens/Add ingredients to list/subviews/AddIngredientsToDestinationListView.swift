//
//  AddIngredientsToDestinationListView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.10.2023.
//

import UIKit

class AddIngredientsToDestinationListView: UIView {
    
    var selectList: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.background()
        view.addShadow(radius: 11, offset: .init(width: 0, height: -12))
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 12).font
        label.textColor = R.color.darkGray()
        label.text = R.string.localizable.destinationList()
        return label
    }()
    
    private let listLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = R.color.darkGray()
        return label
    }()
    
    private let listImageView = UIImageView(image: R.image.list_tabbar_inactive())
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.chevron()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(list name: String) {
        listLabel.text = name
    }
    
    private func setup() {
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnList))
        containerView.addGestureRecognizer(tapOnView)
        
        makeConstraints()
    }
    
    @objc
    private func tappedOnList() {
        selectList?()
    }
    
    private func makeConstraints() {
        self.addSubview(containerView)
        containerView.addSubviews([titleLabel, listLabel, listImageView, chevronImageView])
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        listImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(listImageView.snp.trailing).offset(8)
            $0.height.equalTo(12)
        }
        
        listLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.equalTo(listImageView.snp.trailing).offset(8)
        }
        
        chevronImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(24)
        }
    }
}
