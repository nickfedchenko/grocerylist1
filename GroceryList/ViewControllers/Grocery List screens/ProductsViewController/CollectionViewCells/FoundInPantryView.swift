//
//  FoundInPantryView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 12.06.2023.
//

import UIKit

class FoundInPantryView: UIView {
    
    var tapCross: (() -> Void)?
    
    private let titleView = UIView()
    private let crossView = UIView()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 13).font
        label.textColor = .white
        label.text = "Found in the pantry, in stock"
        return label
    }()
    
    private lazy var crossButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.xMark_in_stock(), for: .normal)
        button.addTarget(self, action: #selector(tappedCrossButton), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureColor(_ color: UIColor?) {
        titleView.backgroundColor = color
        crossView.backgroundColor = color
    }
    
    private func setup() {
        titleView.clipsToBounds = true
        titleView.layer.cornerRadius = 8
        titleView.layer.maskedCorners = [.layerMinXMinYCorner]
        
        crossView.clipsToBounds = true
        crossView.layer.cornerRadius = 12
        crossView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        makeConstraints()
    }
    
    @objc
    private func tappedCrossButton() {
        tapCross?()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleView, crossView])
        titleView.addSubview(titleLabel)
        crossView.addSubview(crossButton)
        
        titleView.snp.makeConstraints {
            $0.leading.bottom.top.equalToSuperview()
            $0.trailing.equalTo(crossView.snp.leading)
        }
        
        crossView.snp.makeConstraints {
            $0.trailing.bottom.top.equalToSuperview()
            $0.width.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.center.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        crossButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}
