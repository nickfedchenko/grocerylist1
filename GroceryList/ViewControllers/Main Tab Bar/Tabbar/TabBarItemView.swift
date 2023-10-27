//
//  TabBarItemView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 23.05.2023.
//

import UIKit

protocol TabBarItemDelegate: AnyObject {
    func tabSelected(at index: Int)
}

final class TabBarItemView: UIView {
    
    enum Item: Int, CaseIterable {
        case list
        case pantry
        case mealPlan
    }

    weak var delegate: TabBarItemDelegate?
    
    var isSelected: Bool = false {
        didSet {
            markAsSelected()
        }
    }
    
    private let titleLabel = UILabel()
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let configuration: Item
    
    init(configurationOfItem: Item) {
        configuration = configurationOfItem
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSelection)))
        self.tag = configuration.rawValue
        titleLabel.text = configuration.title
        titleLabel.font = configuration.font
        
        titleLabel.textColor = configuration.color
        iconImageView.image = configuration.image
        
        if configuration == .list {
            isSelected = true
        }
        
        makeConstraints()
    }
    
    private func markAsSelected() {
        guard isSelected else {
            titleLabel.textColor = configuration.color
            iconImageView.image = configuration.image
            return
        }
        titleLabel.textColor = configuration.selectedColor
        iconImageView.image = configuration.selectedImage
    }
    
    private func makeConstraints() {
        self.addSubviews([iconImageView, titleLabel])
        
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
    
    @objc
    private func toggleSelection() {
        delegate?.tabSelected(at: tag)
    }
}

extension TabBarItemView.Item {
    var title: String {
        switch self {
        case .list:     return R.string.localizable.list()
        case .pantry:   return R.string.localizable.pantry()
        case .mealPlan:   return R.string.localizable.tabBarMealPlan()
        }
    }
    
    var image: UIImage? {
        switch self {
        case .list:     return R.image.list_tabbar_inactive()
        case .pantry:   return R.image.pantry_tabbar_inactive()
        case .mealPlan:   return R.image.mealplan_tabbar_inactive()
        }
    }
    
    var selectedImage: UIImage? {
        switch self {
        case .list:     return R.image.list_tabbar_active()
        case .pantry:   return R.image.pantry_tabbar_active()
        case .mealPlan:   return R.image.mealplan_tabbar_active()
        }
    }
    
    var font: UIFont? {
        UIFont.SFProRounded.medium(size: 13).font
    }
    
    var color: UIColor? {
        R.color.darkGray() ?? .black
    }
    
    var selectedColor: UIColor? {
        R.color.primaryDark() ?? .black
    }
}
