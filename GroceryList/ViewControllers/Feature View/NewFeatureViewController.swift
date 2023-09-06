//
//  NewFeatureViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.08.2023.
//

import UIKit

class NewFeatureView: UIView {
  
    var greatEnable: (() -> Void)?
    var maybeLater: (() -> Void)?
    
    private lazy var baseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.newFeatureImage()
        imageView.layer.cornerRadius = 8
        imageView.layer.cornerCurve = .continuous
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var baseShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.action()
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        view.addDefaultShadowForPopUp()
        return view
    }()

    private lazy var whiteView: FeatureCloudView = {
        let view = FeatureCloudView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var maybeLaterButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.maybeLater(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
        button.addTarget(self, action: #selector(tappedMaybeLaterButton), for: .touchUpInside)
        return button
    }()
    
    private let blurView = UIVisualEffectView(effect: nil)
    private var blurRadiusDriver: UIViewPropertyAnimator?

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        reinitBlurView()
    }
    
    func stopViewPropertyAnimator() {
        blurRadiusDriver?.stopAnimation(true)
        blurRadiusDriver?.finishAnimation(at: .current)
        blurRadiusDriver = nil
    }
    
    private func setup() {
        self.backgroundColor = .black.withAlphaComponent(0.5)
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedMaybeLaterButton))
        self.addGestureRecognizer(tapOnView)
        
        makeConstraints()
        reinitBlurView()
        
        whiteView.tappedGreatEnable = { [weak self] in
            self?.greatEnable?()
        }
    }

    private func reinitBlurView() {
        blurRadiusDriver?.stopAnimation(true)
        blurRadiusDriver?.finishAnimation(at: .current)
        
        blurView.effect = nil
        blurRadiusDriver = UIViewPropertyAnimator(duration: 1, curve: .linear, animations: {
            self.blurView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        })
        blurRadiusDriver?.fractionComplete = 0.2
    }

    @objc
    private func tappedMaybeLaterButton() {
        maybeLater?()
    }
    
    private func makeConstraints() {
        self.addSubview(blurView)
        blurView.contentView.addSubviews([baseShadowView, baseImageView])
        baseImageView.addSubviews([whiteView, maybeLaterButton])
        
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        baseShadowView.snp.makeConstraints {
            $0.edges.equalTo(baseImageView)
        }
        
        baseImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(335)
            $0.height.equalTo(462)
        }
        
        whiteView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(303)
            $0.height.equalTo(237)
            $0.bottom.equalTo(maybeLaterButton.snp.top).offset(-7)
        }
        
        maybeLaterButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
            $0.height.equalTo(60)
        }
    }
}
