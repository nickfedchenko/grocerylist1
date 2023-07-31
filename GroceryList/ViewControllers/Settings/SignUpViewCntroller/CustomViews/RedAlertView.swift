//
//  EmailTakenView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 09.02.2023.
//

import SnapKit
import UIKit

class RedAlertView: UIView {
    
    private var state: State
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .SFProRounded.semibold(size: 14).font
        label.textColor = R.color.attention()
        return label
    }()
    
    let touchView = UIView()
    
    // MARK: - LifeCycle
    init(state: State = .mailTaken) {
        self.state = state
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        textLabel.text = state.getTitle()
        self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Open func
    func hideView() {
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.layoutIfNeeded()
        } completion: { _ in
            self.isHidden = true
        }
    }
    
    func showView() {
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.isHidden = false
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Constraints
    private func setupView() {
        self.layer.cornerRadius = 4
        self.layer.cornerCurve = .continuous
        self.backgroundColor = .white
    }
    
    private func setupConstraints() {
        addSubviews([textLabel])
        textLabel.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview().inset(10)
        }
    }
    
    enum State {
        case internet
        case mailTaken
        
        func getTitle() -> String {
            switch self {
            case .internet:
                return R.string.localizable.noInternet()
            case .mailTaken:
                return R.string.localizable.emailTaken()
            }
        }
    }
}
