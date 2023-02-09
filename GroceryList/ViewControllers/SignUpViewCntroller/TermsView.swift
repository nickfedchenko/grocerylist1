//
//  TermsView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 09.02.2023.
//

import SnapKit
import UIKit

class TermsView: UIView {
    
    var isActiveCompl: ((Bool) -> Void)?
   
    private var isActive: Bool {
        didSet {
            checkMarkImageView.image = isActive ? R.image.signUpAcceptChackmark() : R.image.signUpEmptyCheckMark()
        }
    }
    
    private let checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.signUpEmptyCheckMark()
        return imageView
    }()
    
    private let text: UILabel = {
        let label = UILabel()
        label.font = .SFPro.medium(size: 14).font
        label.textColor = UIColor(hex: "#617774")
        label.textAlignment = .left
        label.text = R.string.localizable.signUpTerms()
        label.numberOfLines = 0
        return label
    }()
    
    let touchView = UIView()
    
    // MARK: - LifeCycle
    init(isActive: Bool = false) {
        self.isActive = isActive
        super.init(frame: .zero)
        setupConstraints()
        addRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        addSubviews([checkMarkImageView, text, touchView])
        
        checkMarkImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.height.width.equalTo(40)
        }
        
        text.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.bottom.right.equalToSuperview()
            make.left.equalTo(checkMarkImageView.snp.right).inset(-8)
        }
        
        touchView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - TapAction
    private func addRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        touchView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc
    private func tapAction() {
        isActive = !isActive
        isActiveCompl?(isActive)
    }
}
