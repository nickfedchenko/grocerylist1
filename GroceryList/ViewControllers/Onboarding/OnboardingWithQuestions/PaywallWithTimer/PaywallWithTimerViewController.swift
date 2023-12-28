//
//  PaywallWithTimer.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 25.12.2023.
//

import UIKit

class PaywallWithTimerViewController: UIViewController {
    
    var viewModel: PaywallWithTimerViewModel?
    
    private let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.paywallWithTimerBackground()
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(R.image.paywalWithTimerCloseButton(), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let topView: PaywallWithTimerTopView = {
        let view = PaywallWithTimerTopView()
        return view
    }()
    
    private let viewWithTimer: PaywallWithTimerTimerView = {
        let view = PaywallWithTimerTimerView()
        return view
    }()
    
    private lazy var bottomView: PaywallWithTimerBottomView = {
        let view = PaywallWithTimerBottomView()
        view.termsButtonCallback = { [weak self] in
            self?.viewModel?.termsDidTap()
        }
        
        view.privacyButtonCallback = { [weak self] in
            self?.viewModel?.privacyDidTap()
        }
        
        view.continueButtonCallback = { [weak self] in
            self?.viewModel?.continueButtonPressed()
        }
        return view
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCallbacks()
    }
    
    // MARK: - Actions
    @objc
    private func closeButtonTapped() {
        viewModel?.closeButtonTapped()
    }
}

// MARK: - Constraints
extension PaywallWithTimerViewController {
    private func configureUI() {
        addSubViews()
        setupConstraints()
    }
    
    private func configureCallbacks() {
        viewModel?.timerCallback = { [weak self] min, sec in
            self?.viewWithTimer.setupTimer(minutes: min, seconds: sec)

        }
        
        viewModel?.showErrorAlertCallback = { [weak self] message in
            self?.alertOk(title: "Error", message: message)
        }
        
        viewModel?.updatePrices = { [weak self] oldPrice, newPrice in
            self?.viewWithTimer.configurePrice(oldPrice: oldPrice, newPrice: newPrice)
            self?.bottomView.configure(oldPrice: oldPrice)
        }
    }
    
    private func addSubViews() {
        view.addSubviews([
            backgroundImageView,
            topView,
            viewWithTimer,
            closeButton,
            bottomView
        ])
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(12)
            make.width.height.equalTo(40)
        }
        
        topView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().inset(40)
            make.left.right.equalToSuperview()
        }
        
        viewWithTimer.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).inset(-32)
            make.left.right.equalToSuperview()
            make.bottom.lessThanOrEqualTo(bottomView.snp.top).inset(-118)
        }
        
        bottomView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
        }
    }
}
