//
//  PantryStarterPackViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 23.05.2023.
//

import UIKit

final class PantryStarterPackViewController: UIViewController {

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerCurve = .continuous
        view.addCustomShadow(radius: 11, offset: CGSize(width: 0, height: -12))
        return view
    }()
    
    private lazy var pantryImageView: UIImageView = {
        let image = UIDevice.isSE ? R.image.starterpack_pantry_SE() : R.image.starterpack_pantry()
        let imageView = createImageView(image: image)
        imageView.layer.cornerRadius = 32
        imageView.layer.maskedCorners = [.layerMaxXMinYCorner]
        imageView.layer.cornerCurve = .continuous
        return imageView
    }()
    
    private lazy var iconImageView: UIImageView = {
        let image = UIDevice.isSE ? R.image.starterpack_icon_SE() : R.image.starterpack_icon()
        return createImageView(image: image)
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.heavy(size: 32).font
        label.textColor = R.color.primaryDark()
        label.text = R.string.localizable.pantryEnterStocks()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 15).font
        label.textColor = R.color.primaryDark()
        label.text = R.string.localizable.pantryStarterPackDescription()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        return label
    }()
    
    private lazy var excellentButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = R.color.primaryDark()
        button.setTitle("Excellent!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.bold(size: 20).font
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.layer.borderColor = R.color.action()?.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(tappedExcellentButton), for: .touchUpInside)
        button.addCustomShadow(color: UIColor(hex: "03694A"), opacity: 0.35,
                               radius: 0.5, offset: CGSize(width: 0, height: 1))
        return button
    }()
    
    private lazy var excellentShadowOneView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.primaryDark()
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        view.addCustomShadow(color: UIColor(hex: "005138"), opacity: 0.45,
                             radius: 6, offset: CGSize(width: 0, height: 3))
        return view
    }()
    
    private lazy var excellentShadowTwoView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.primaryDark()
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        view.addCustomShadow(color: UIColor(hex: "03694A"), opacity: 0.4,
                             radius: 20, offset: CGSize(width: 0, height: 8))
        return view
    }()
    
    private var contentViewHeight = 723
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(panRecognizer)
        
        makeConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showPanel()
    }
    
    private func createImageView(image: UIImage?) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    @objc
    private func tappedExcellentButton() {
        hidePanel()
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
    
    private func hidePanel() {
        updateContentViewConstraint(with: contentViewHeight, alpha: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false)
        }
    }
    
    private func showPanel() {
        updateContentViewConstraint(with: 0, alpha: 0.2)
    }
    
    func updateContentViewConstraint(with offset: Int, alpha: CGFloat) {
        contentView.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(offset)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.backgroundColor = .black.withAlphaComponent(alpha)
            self?.view.layoutIfNeeded()
        }
    }
    
    private func makeConstraints() {
        self.view.addSubview(contentView)
        contentView.addSubviews([excellentShadowOneView, excellentShadowTwoView, excellentButton,
                                 pantryImageView, iconImageView,
                                 titleLabel, descriptionLabel])
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(contentViewHeight)
            if UIDevice.isSE {
                $0.height.equalToSuperview()
            } else {
                $0.height.equalTo(contentViewHeight)
            }
        }
        
        pantryImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.equalTo(UIDevice.isSE ? 146 : 181)
            $0.height.equalTo(512)
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(pantryImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(31)
            $0.leading.equalTo(pantryImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(UIDevice.isSE ? 17 : 19)
            $0.leading.trailing.equalTo(titleLabel)
            $0.bottom.equalTo(pantryImageView)
        }
        
        makeExcellentButtonConstraints()
    }
    
    private func makeExcellentButtonConstraints() {
        excellentButton.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().offset(UIDevice.isSE ? -24 : -75)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        excellentShadowOneView.snp.makeConstraints {
            $0.edges.equalTo(excellentButton)
        }
        
        excellentShadowTwoView.snp.makeConstraints {
            $0.edges.equalTo(excellentButton)
        }
    }
}
