//
//  MealPlanDestinationListView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.09.2023.
//

import UIKit

protocol MealPlanDestinationListViewDelegate: AnyObject {
    func selectList()
}

class MealPlanDestinationListView: UIView {

    weak var delegate: MealPlanDestinationListViewDelegate?
    
    private let containerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = R.color.darkGray()
        label.text = "Destination List"
        return label
    }()
    
    private let listLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = R.color.darkGray()
        label.text = "Not selected"
        return label
    }()
    
    private let listImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.mealplan_tabbar_inactive()
        return imageView
    }()
    
    private lazy var listView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 3
        view.layer.masksToBounds = false
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()
    
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
    
    func configure(list name: String?) {
        guard let name else { return }
        listLabel.text = name
    }
    
    private func setup() {
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnList))
        listView.addGestureRecognizer(tapOnView)
        
        makeConstraints()
    }
    
    @objc
    private func tappedOnList() {
        delegate?.selectList()
    }
    
    private func makeConstraints() {
        self.addSubview(containerView)
        containerView.addSubviews([listView, titleLabel])
        listView.addSubviews([listLabel, listImageView, chevronImageView])
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(40)
        }
        
        listView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        listImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.width.height.equalTo(32)
        }
        
        listLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(listImageView.snp.trailing).offset(8)
        }
        
        chevronImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-4)
            $0.width.height.equalTo(24)
        }
    }
}
