//
//  RecipeEditMessageView.swift
//  ActionExtension
//
//  Created by Хандымаа Чульдум on 04.08.2023.
//

import UIKit

class RecipeEditMessageView: UIView {

    var tappedCrossButton: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.text = "You can edit the recipe later".localized
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var crossButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.xMarkInput(), for: .normal)
        button.addTarget(self, action: #selector(crossButtonTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = R.color.action()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isVisible(_ isVisible: Bool) {
        crossButton.isHidden = !isVisible
        titleLabel.isHidden = !isVisible
    }
    
    @objc
    private func crossButtonTapped() {
        tappedCrossButton?()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, crossButton])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(crossButton.snp.leading)
            $0.centerY.equalToSuperview()
        }
        
        crossButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
    }
}
