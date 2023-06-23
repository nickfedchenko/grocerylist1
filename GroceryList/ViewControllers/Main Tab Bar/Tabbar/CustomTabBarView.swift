//
//  CustomTabBarView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 23.05.2023.
//

import UIKit

protocol CustomTabBarViewDelegate: AnyObject {
    func tabSelected(at index: Int)
    func tabAddItem()
}

final class CustomTabBarView: ViewWithOverriddenPoint {
    
    weak var delegate: CustomTabBarViewDelegate?
    
    private lazy var items: [TabBarItemView] = TabBarItemView.Item.allCases.map {
        let tabItem = TabBarItemView(configurationOfItem: $0)
        tabItem.delegate = self
        return tabItem
    }
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        items.forEach { tabItem in
            stackView.addArrangedSubview(tabItem)
        }
        return stackView
    }()
    
    private let addItem = AddListView()
    private let lineView = UIView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateItems(by index: Int) {
        items.enumerated().forEach { tag, view in
            let isSelectedView = index == tag
            guard view.isSelected != isSelectedView else {
                return
            }
            view.isSelected = isSelectedView
        }
    }

    func updateColorAddItem(_ color: UIColor?) {
        addItem.setColor(background: color, image: color)
    }
    
    func updateTextAddItem(_ text: String) {
        addItem.setText(text)
    }
    
    private func setup() {
        self.backgroundColor = .white.withAlphaComponent(0.95)
        lineView.backgroundColor = R.color.lightGray()
        
        setupAddItem()
        makeConstraints()
    }
    
    private func setupAddItem() {
        addItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAddItem)))
        addItem.setColor(background: R.color.primaryDark(),
                         image: R.color.primaryDark())
    }
    
    @objc
    private func tapAddItem() {
        delegate?.tabAddItem()
    }
    
    /// метод  для будущих изменений, возможно будет в настройках свитч для левшей)
    /// переместит кнопку Создания листа влево/вправо в зависимости от isRightHanded
    private func updateAddItemConstraints(isRightHanded: Bool) {
        addItem.updateView(isRightHanded: isRightHanded)
        
        guard isRightHanded else {
            addItem.snp.updateConstraints {
                $0.trailing.equalToSuperview().offset(-246)
                $0.leading.equalToSuperview().offset(-5)
            }
            
            stackView.snp.remakeConstraints {
                $0.leading.equalTo(addItem.snp.trailing).offset(24)
                $0.trailing.equalToSuperview().offset(-24)
            }
            return
        }
        addItem.snp.updateConstraints {
            $0.leading.equalToSuperview().offset(246)
            $0.trailing.equalToSuperview().offset(5)
        }
        
        stackView.snp.remakeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalTo(addItem.snp.leading).offset(-24)
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([lineView, stackView, addItem])
        
        lineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(-1)
            $0.height.equalTo(1)
        }
        
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalTo(addItem.snp.leading).offset(-24)
        }
        
        addItem.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(246)
            $0.trailing.equalToSuperview().offset(5)
            $0.top.equalToSuperview().offset(-2)
            $0.bottom.equalToSuperview().offset(5)
        }
    }
}

extension CustomTabBarView: TabBarItemDelegate {
    func tabSelected(at index: Int) {
        delegate?.tabSelected(at: index)
    }
}
