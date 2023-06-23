//
//  WriteReviewViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.02.2023.
//

import MessageUI
import UIKit

class WriteReviewViewController: UIViewController {
    
    var viewModel: WriteReviewViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    private var contentViewHeight = 640.0
    
    private let topView = UIView()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 40
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.reviewBackground()
        return imageView
    }()
    
    private let starsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.reviewStars()
        return imageView
    }()
    
    private let productsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.reviewProducts()
        return imageView
    }()
    
    private let yourOpinionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 20).font
        label.textColor = UIColor(hex: "#E3990C")
        label.text = R.string.localizable.yourOpinionMatterToUs()
        return label
    }()
    
    private let likeTheAppLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 20).font
        label.textColor = UIColor(hex: "#434A4A")
        label.text = R.string.localizable.likeTheApp()
        return label
    }()
    
    private lazy var yesView: ReviewSelectableView = {
        let view = ReviewSelectableView(state: .yes)
        view.viewTapped = { [weak self] in
            self?.viewModel?.yesButtonTapped()
        }
        return view
    }()
    
    private lazy var noView: ReviewSelectableView = {
        let view = ReviewSelectableView(state: .not)
        view.viewTapped = { [weak self] in
            self?.viewModel?.noButtonTapped()
        }
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        addRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateConstr(with: 0, alpha: 0.3)
    }
    
    deinit {
        print("WriteReviewViewController deinited")
    }
    
    // MARK: - Constraints
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        view.addSubviews([contentView, topView])
        contentView.addSubviews([
            backgroundImageView, starsImageView,
            productsImageView, yourOpinionLabel,
            likeTheAppLabel, yesView, noView
        ])
        
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(contentView.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-640)
            make.height.equalTo(contentView)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
            make.height.equalTo(640)
        }
        
        starsImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(64)
            make.centerX.equalToSuperview()
            make.width.equalTo(313)
            make.height.equalTo(122)
        }
        
        productsImageView.snp.makeConstraints { make in
            make.top.equalTo(starsImageView.snp.top).inset(64)
            make.centerX.equalToSuperview()
            make.width.equalTo(192)
            make.height.equalTo(189)
        }
        
        productsImageView.snp.makeConstraints { make in
            make.top.equalTo(starsImageView.snp.top).inset(64)
            make.centerX.equalToSuperview()
            make.width.equalTo(192)
            make.height.equalTo(189)
        }
        
        yourOpinionLabel.snp.makeConstraints { make in
            make.top.equalTo(productsImageView.snp.bottom).inset(-14)
            make.centerX.equalToSuperview()
        }
        
        likeTheAppLabel.snp.makeConstraints { make in
            make.top.equalTo(yourOpinionLabel.snp.bottom).inset(-42)
            make.centerX.equalToSuperview()
        }
        
        yesView.snp.makeConstraints { make in
            make.top.equalTo(likeTheAppLabel.snp.bottom).inset(-19)
            make.centerX.equalToSuperview()
        }
        
        noView.snp.makeConstraints { make in
            make.top.equalTo(yesView.snp.bottom).inset(-16)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Recognizer
    private func addRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        topView.addGestureRecognizer(tapRecognizer)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(panRecognizer)
    }
    
    @objc
    private func tapAction() {
        updateConstr(with: -contentViewHeight, alpha: 0, shouldHide: true)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            updateConstr(with: -contentViewHeight, alpha: 0, shouldHide: true)
        }
    }
    // MARK: - Update Constraints
    private func updateConstr(with inset: Double, alpha: Double, shouldHide: Bool = false) {
        UIView.animate(withDuration: 0.3) { [ weak self ] in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(inset)
            }
            self.view.backgroundColor = .black.withAlphaComponent(alpha)
            self.view.layoutIfNeeded()
        }
        if shouldHide {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { [weak self] in
                self?.dismiss(animated: false)
            }
        }
    }
}

// MARK: - ViewModel Delegate
extension WriteReviewViewController: WriteReviewViewModelDelegate {
    func presentMail(controller: UIViewController) {
        self.present(controller, animated: true)
    }
}

// MARK: - Contact Us
extension WriteReviewViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true)
    }
}
