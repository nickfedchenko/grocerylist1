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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        preparationsForAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstAnimation()
    }
    
    deinit {
        print("Onboarding deinited")
    }
    
    private func preparationsForAnimation() {
        bottomView.transform = CGAffineTransform(scaleX: 0, y: 0)
        bascetView.transform = CGAffineTransform(scaleX: 0, y: 0)
        whiteView.transform = CGAffineTransform(scaleX: 0, y: 0)
        playView.transform = CGAffineTransform(scaleX: 0, y: 0)
    }
    
    private func firstAnimation() {
        UIView.animate(withDuration: 1.2, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.cartView.snp.updateConstraints { make in
                make.left.equalToSuperview().inset(14)
            }
            self.bottomView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.secondAnimation()
        }
    }
    
    private func secondAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
                self.bottomView.layer.borderWidth = 0
                self.bottomView.layer.shadowOpacity = 0
                self.bottomView.backgroundColor = UIColor(hex: "#31635A")
                let transition = CATransition()
                transition.type = .fade
                transition.duration = 0.3
                self.bottomViewLabel.layer.add(transition, forKey: nil)
                self.bottomViewLabel.textColor = .white
                self.bascetView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.whiteView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.view.layoutIfNeeded()
        } completion: { _ in
            self.thirdAnimation()
        }
    }
    
    private func thirdAnimation() {
        UIView.animate(withDuration: 1.2, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) { [self] in
            self.recieptView.snp.updateConstraints { make in
                make.top.equalTo(bottomView.snp.centerY).offset(0)
            }
            self.playView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.addRecognizer()
        }
    }
    
    private func addRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(bottomViewRecognizerAction))
        bottomView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc
    private func bottomViewRecognizerAction() {
        UIView.animate(withDuration: 1.0) {
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.3
            self.bottomViewLabel.layer.add(transition, forKey: nil)
            self.bottomViewLabel.textColor = UIColor(hex: "#346965")
            self.bottomView.backgroundColor = UIColor(hex: "#DAF4F0")
            self.playView.isHidden = true
            self.firstView.snp.remakeConstraints { make in
                make.right.equalTo(self.view.snp.left)
                make.height.width.equalToSuperview()
            }
            
            self.secondView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
               // make.height.width.top.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
            
        } completion: { _ in
      
        }

    }
    
    @objc
    private func nextButtonPressed() {
        
    }

    // MARK: - UI
    
    private let firstView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "firstBG")
        return imageView
    }()
    
    private let logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    
    private let cartView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "cart")
        return imageView
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D7F8EE")
        view.layer.cornerRadius = 24
        view.layer.borderColor = UIColor(hex: "#31635A").cgColor
        view.layer.borderWidth = 2
        view.layer.masksToBounds = true
        
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowRadius = 2
        view.layer.masksToBounds = false
        
        return view
    }()
    
    private let whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 26
        view.layer.masksToBounds = false
        return view
    }()
    
    private let bottomViewLabel: UILabel = {
        let label = UILabel()
        label.font = .SFPro.medium(size: 22).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "SafeTimeAndMoney".localized
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let bascetView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "basket")
        
        imageView.layer.shadowColor = UIColor.white.cgColor
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowOffset = CGSize(width: 0, height: 10)
        imageView.layer.shadowRadius = 0
        imageView.layer.masksToBounds = false
        return imageView
    }()
    
    private let recieptView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "#reciept")
        imageView.layer.masksToBounds = false
        return imageView
    }()
    
    private let playView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "#play")
        return imageView
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
      //  button.isHidden = true
        return button
    }()
    
    private let secondView: SecondOnboardingView = {
        let view = SecondOnboardingView()
        return view
    }()
   
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        view.backgroundColor = .lightGray
        view.addSubviews([firstView, secondView, nextButton])
        firstView.addSubviews([backgroundView, logoView, cartView, bascetView, whiteView, bottomView, recieptView])
        bottomView.addSubviews([bottomViewLabel, playView])
        
        firstView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        logoView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(142)
            make.width.equalTo(367)
        }
        
        cartView.snp.makeConstraints { make in
            make.centerY.equalTo(logoView)
            make.width.equalTo(66)
            make.height.equalTo(63)
            make.left.equalToSuperview().inset(-66)
        }
        
        whiteView.snp.makeConstraints { make in
            make.centerY.equalTo(bottomView)
            make.width.equalTo(352)
            make.centerX.equalToSuperview()
            make.height.equalTo(90)
        }
        
        bottomView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().multipliedBy(0.9)
            make.width.equalTo(342)
            make.centerX.equalToSuperview()
            make.height.equalTo(80)
        }
        
        bottomViewLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        playView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(14)
            make.centerX.equalToSuperview().multipliedBy(1.35)
            make.height.width.equalTo(23)
        }
        
        bascetView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top).inset(18)
            make.width.equalTo(340)
            make.height.equalTo(313)
        }
        
        recieptView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(6)
            make.top.equalTo(bottomView.snp.centerY).offset(300)
            make.width.equalTo(152)
            make.height.equalTo(239)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(64)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(64)
        }
        
        secondView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
            make.top.equalToSuperview()
            make.left.equalTo(self.view.snp.right)
        }
    }
}
