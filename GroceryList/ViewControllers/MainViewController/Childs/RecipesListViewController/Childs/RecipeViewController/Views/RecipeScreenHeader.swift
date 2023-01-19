//
//  RecipeScreenHeader.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 11.12.2022.
//

import UIKit

protocol RecipeScreenHeaderDelegate: AnyObject {
    func backButtonTapped()
}

final class RecipeScreenHeader: UIView {
    weak var delegate: RecipeScreenHeaderDelegate?
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.greenArrowBack(), for: .normal)
        button.imageEdgeInsets.right = 11
        button.tintColor = UIColor(hex: "0C695E")
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedBold(size: 22)
        label.textColor = UIColor(hex: "0C695E")
        label.numberOfLines = 2
        return label
    }()
    
    let blurView = UIVisualEffectView(effect: nil)
    private var blurRadiusDriver: UIViewPropertyAnimator?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        backgroundColor = UIColor(hex: "E5F5F3").withAlphaComponent(0.9)
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        reinitBlurView()
    }
    
    func setBackButtonTitle(title: String) {
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .foregroundColor: UIColor(hex: "0C695E"),
                .font: R.font.sfProRoundedBold(size: 15) ?? .systemFont(ofSize: 15)
            ]
        )
        backButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func releaseBlurAnimation() {
        blurRadiusDriver?.stopAnimation(true)
    }
    
    private func setupActions() {
        backButton.addAction(
            UIAction { [weak self] _ in
                self?.delegate?.backButtonTapped()
        },
            for: .touchUpInside)
    }
    
    private func reinitBlurView() {
        blurRadiusDriver?.stopAnimation(true)
        blurRadiusDriver?.finishAnimation(at: .current)
        
        blurView.effect = nil
        blurRadiusDriver = UIViewPropertyAnimator(duration: 1, curve: .linear, animations: {
            self.blurView.effect = UIBlurEffect(style: .light)
        })
        blurRadiusDriver?.fractionComplete = 0.1
//        blurRadiusDriver?.stopAnimation(true)
//        blurRadiusDriver?.finishAnimation(at: .current)
    }
    
    private func setupSubviews() {
        addSubview(blurView)
        blurView.contentView.addSubview(backButton)
        blurView.contentView.addSubview(titleLabel)
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(46)
            make.leading.equalToSuperview().offset(8)
            make.width.equalTo(110)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }
    }
}
