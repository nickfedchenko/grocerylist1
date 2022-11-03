//
//  OnboardingViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.11.2022.
//

import SnapKit
import UIKit

class OnboardingViewController: UIViewController {
    
    weak var router: RootRouter?
    private var currentVC = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupCallbacks()
    }
    
    private func setupCallbacks() {
        firstView.buttonPressedCallback = { [weak self] in
            self?.showSecondView()
        }
        
        secondView.unlockButton = {  [weak self] in
            self?.nextButton.isUserInteractionEnabled = true
        }
        
        secondView.lockButton = {  [weak self] in
            self?.nextButton.isUserInteractionEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstView.startAnimation()
    }
    
    deinit {
        print("Onboarding deinited")
    }
    
    private func showSecondView() {
        UIView.animate(withDuration: 1.0) { [weak self] in
            guard let self = self else { return }
            self.firstView.snp.remakeConstraints { make in
                make.width.height.equalToSuperview()
                make.right.equalTo(self.view.snp.left)
            }
            
            self.secondView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            self.nextButton.snp.remakeConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(30)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(64)
            }
            self.nextButton.isHidden = false
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.secondView.firstAnimation()
        }
    }
    
    @objc
    private func nextButtonPressed() {
        if currentVC == 1 {
            secondView.secondAnimation()
            currentVC += 1
            return
        }
        
        if currentVC == 2 {
            secondView.goToThirdState()
            currentVC += 1
            return
        }
        
        if currentVC == 3 {
            secondView.goToForthState()
            currentVC += 1
            return
        }
        
        if currentVC > 3 {
           print("close onboarding")
            return
        }
        
    }

    // MARK: - UI
    
    private let firstView: FirstOnboardingView = {
        let view = FirstOnboardingView()
        return view
    }()
    
    private let secondView: OnboardingContentView = {
        let view = OnboardingContentView()
        return view
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(string: "Next".localized, attributes: [
            .font: UIFont.SFPro.semibold(size: 20).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#FFFFFF")
        ])
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(hex: "#31635A")
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.masksToBounds = true
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let nextArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "nextArrow")
        return imageView
    }()
    
    private func setupConstraints() {
        view.backgroundColor = .lightGray
        view.addSubviews([firstView, secondView, nextButton])
        nextButton.addSubview(nextArrow)
       
        firstView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(30)
            make.width.equalTo(300)
            make.centerX.equalTo(secondView.snp.centerX)
            make.height.equalTo(64)
        }
        
        secondView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
            make.top.equalToSuperview()
            make.left.equalTo(self.view.snp.right)
        }
        
        nextArrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(45)
            make.width.equalTo(24)
            make.height.equalTo(20)
        }
    }
}
