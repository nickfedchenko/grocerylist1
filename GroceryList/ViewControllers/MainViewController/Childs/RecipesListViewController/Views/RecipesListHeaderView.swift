//
//  RecipesListHeaderView.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 06.12.2022.
//

import UIKit

protocol RecipesListHeaderViewDelegate: AnyObject {
    func backButtonTapped()
    func searchButtonTapped()
}

final class RecipesListHeaderView: UIView {
    weak var delegate: RecipesListHeaderViewDelegate?
    
    private let blurBack: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: nil)
        return view
    }()
    
    private var blurRadiusDriver: UIViewPropertyAnimator?
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let attrTitle = NSAttributedString(
            string: R.string.localizable.recipes(),
            attributes: [
                .font: R.font.sfProRoundedBold(size: 15) ?? .systemFont(ofSize: 15),
                .foregroundColor: UIColor(hex: "1A645A")
            ]
        )
        button.imageEdgeInsets.right = 11
        button.setImage(R.image.greenArrowBack(), for: .normal)
        button.tintColor = UIColor(hex: "1A645A")
        button.setAttributedTitle(attrTitle, for: .normal)
        return button
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.searchButtonImage(), for: .normal)
        button.tintColor = UIColor(hex: "1A645A")
        // TODO: - Fix when adds search functionality
        button.alpha = 0
        return button
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedBold(size: 22)
        label.textColor = UIColor(hex: "1A645A")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActions()
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        reinitBlurView()
    }
    
    func releaseBlurAnimation() {
        blurRadiusDriver?.stopAnimation(true)
        blurRadiusDriver?.finishAnimation(at: .current)
    }
    
    private func setupActions() {
        backButton.addAction(
            UIAction { [weak self] _ in
                self?.delegate?.backButtonTapped()
            }
            , for: .touchUpInside
        )
        
        searchButton.addAction(
            UIAction { [weak self] _ in
                self?.delegate?.searchButtonTapped()
            }
            , for: .touchUpInside
        )
    }
    
    private func setupSubviews() {
        addSubview(blurBack)
        blurBack.contentView.addSubview(backButton)
        blurBack.contentView.addSubview(searchButton)
        
        blurBack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(54)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(97)
        }
        
        searchButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.trailing.equalToSuperview().inset(20)
            make.height.width.equalTo(40)
        }
    }
    
    private func reinitBlurView() {
        blurRadiusDriver?.stopAnimation(true)
        blurRadiusDriver?.finishAnimation(at: .current)
        
        
        blurRadiusDriver = UIViewPropertyAnimator(duration: 1, curve: .linear) {
            self.blurBack.effect = UIBlurEffect(style: .light)
        }
        blurRadiusDriver?.fractionComplete = 0.1
//        blurRadiusDriver?.stopAnimation(true)
//        blurRadiusDriver?.finishAnimation(at: .current)
    }
}
