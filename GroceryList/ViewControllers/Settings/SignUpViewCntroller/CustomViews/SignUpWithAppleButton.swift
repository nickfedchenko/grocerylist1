//
//  SignUpWithAppleButton.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 09.02.2023.
//

import UIKit

class SignInWithAppleButton: UIButton {
    // MARK: - Property
    private let newTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 20).font
        label.textColor = .white
        label.text = R.string.localizable.signInWithApple()
        return label
    }()
    
    private let appleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.appleImage()
        return imageView
    }()
    
    private let containerView = UIView()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupConstraints()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard super.hitTest(point, with: event) != nil,
              let superview = containerView.superview else { return nil }
            return superview
    }
    
    // MARK: - SetupView
    private func setupView() {
        self.backgroundColor = .black
        self.layer.cornerRadius = 16
        self.layer.cornerCurve = .continuous
        self.layer.masksToBounds = true
        containerView.isUserInteractionEnabled = true
    }
    
    private func setupConstraints() {
        addSubviews([containerView])
        containerView.addSubviews([appleImageView, newTitleLabel])
        
        containerView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        appleImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        newTitleLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(appleImageView).offset(1)
            make.left.equalTo(appleImageView.snp.right).inset(-5)
        }
    }
}
