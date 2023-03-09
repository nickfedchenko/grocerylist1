//
//  CategoryView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.03.2023.
//

import UIKit

protocol CategoryViewDelegate: AnyObject {
    func categoryTapped()
}

class CategoryView: UIView {
    
    weak var delegate: CategoryViewDelegate?
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 16).font
        label.textColor = UIColor(hex: "#777777")
        label.text = "Category"
        return label
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.whitePencil()?.withTintColor(UIColor(hex: "#777777")),
                        for: .normal)
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setCategory(_ category: String?, textColor: UIColor) {
        categoryLabel.text = category
        categoryLabel.textColor = textColor
    }
    
    private func setup() {
        self.backgroundColor = UIColor(hex: "#FCFCFE")

        makeConstraints()
    }
    
    @objc
    private func categoryButtonTapped() {
        delegate?.categoryTapped()
    }
    
    private func makeConstraints() {
        self.addSubviews([categoryLabel, categoryButton])
        
        categoryLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(17)
        }
        
        categoryButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-35)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(25)
        }
    }
}
