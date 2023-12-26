//
//  BottomViewWithNextButton.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 25.12.2023.
//

import Foundation
import UIKit

final class BottomViewWithNextButton: UIView {
    
    var nextButtonPressedCallback: (() -> Void)?
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(string: "Next".localized.uppercased(), attributes: [
            .font: UIFont.SFPro.semibold(size: 20).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#FFFFFF")
        ])
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(hex: "#A2ABAB")
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.setImage(UIImage(named: "nextArrow"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = .white
        button.imageEdgeInsets.left = 8
        button.isUserInteractionEnabled = false
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 0
        return button
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = R.color.primaryDark()
        pageControl.pageIndicatorTintColor = R.color.action()
        pageControl.isUserInteractionEnabled = false
        pageControl.numberOfPages = 4
        return pageControl
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(numberOfPages: Int) {
        pageControl.numberOfPages = numberOfPages
    }
    
    func selectPage(pageIndex: Int) {
        pageControl.currentPage = pageIndex
    }
    
    func activateButton(isActive: Bool) {
        if isActive {
            nextButton.addShadowForView(radius: 10, height: 5)
            nextButton.backgroundColor = UIColor(hex: "#1A645A")
            nextButton.setTitleColor(.white, for: .normal)
            nextButton.layer.borderWidth = 2
        } else {
            nextButton.addShadowForView(radius: 0, height: 0)
            nextButton.backgroundColor = UIColor(hex: "#A2ABAB")
            nextButton.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
            nextButton.layer.borderWidth = 0
        }

        nextButton.isUserInteractionEnabled = isActive
    }
    
    @objc
    private func nextButtonPressed() {
        nextButtonPressedCallback?()
    }
}

extension BottomViewWithNextButton {
    // MARK: - SetupView
    private func setupView() {
        addSubview()
        setupConstraint()
        backgroundColor = .white
    }
    
    private func addSubview() {
        addSubviews([nextButton, pageControl])
    }
    
    private func setupConstraint() {
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(14)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(16)
            make.height.equalTo(64)
            make.width.equalTo(350)
            make.bottom.equalTo(pageControl.snp.top).offset(-12)
        }
    }
}
