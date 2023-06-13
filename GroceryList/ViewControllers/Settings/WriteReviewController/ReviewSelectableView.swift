//
//  ReviewSelectableView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.02.2023.
//

import UIKit

final class ReviewSelectableView: UIView {
    
    var viewTapped: (() -> Void)?
    
    private let circleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()
    
    private let circleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 17).font
        label.textColor = UIColor(hex: "#434A4A")
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 17).font
        label.textColor = UIColor(hex: "#434A4A")
        return label
    }()
    
    // MARK: - LifeCycle
    
    init(state: ReviewSelectableViewState) {
        super.init(frame: .zero)
        setupView()
        setupConstraint()
        setupState(state: state)
        addRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetupView
    private func setupState(state: ReviewSelectableViewState) {
        circleView.backgroundColor = state.getColorForCircle()
        circleLabel.text = state.getCircleText()
        descriptionLabel.text = state.getDescriptionText()
    }

    private func setupView() {
        self.layer.cornerRadius = 30
        self.layer.borderColor = UIColor(hex: "#B0B5B5").cgColor
        self.layer.borderWidth = 2
        self.backgroundColor = .white
        self.layer.masksToBounds = true
    }
    // MARK: - Constraints
    private func setupConstraint() {
        self.addSubviews([circleView, circleLabel, descriptionLabel])
        
        snp.makeConstraints { make in
            make.width.equalTo(260)
            make.height.equalTo(60)
        }
        
        circleView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        circleLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(circleView)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(circleView.snp.right).inset(-10)
        }
    }
    
    // MARK: - Recognizer
    private func addRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    @objc
    private func tapAction() {
        viewTapped?()
    }
}

enum ReviewSelectableViewState {
    case yes
    case not
    
    func getColorForCircle() -> UIColor {
        switch self {
        case .yes:
            return UIColor(hex: "#E1F4DF")
        case .not:
            return UIColor(hex: "#F4E2DF")
        }
    }
    
    func getCircleText() -> String {
        switch self {
        case .yes:
            return R.string.localizable.yes()
        case .not:
            return R.string.localizable.no()
        }
    }
    
    func getDescriptionText() -> String {
        switch self {
        case .yes:
            return R.string.localizable.writeAReview()
        case .not:
            return R.string.localizable.sendUsFeedback()
        }
    }
}
