//
//  ImportAlertView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 31.07.2023.
//

import UIKit

protocol ImportAlertViewDelegate: AnyObject {
    func tappedItsClear()
    func tappedMicrodata()
    func tappedHrecipe()
}

class ImportAlertView: UIView {
    
    weak var delegate: ImportAlertViewDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "F3FFFE")
        view.layer.cornerRadius = 14
        view.layer.cornerCurve = .continuous
        view.addDefaultShadowForPopUp()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 22).font
        label.textColor = R.color.primaryDark()
        label.text = R.string.localizable.requiredImportStandard()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        let underlineString = NSMutableAttributedString(string: descriptionText)
        [microdataRange, hrecipeRange].forEach { range in
            underlineString.addAttribute(NSAttributedString.Key.underlineStyle,
                                         value: NSUnderlineStyle.single.rawValue, range: range)
            underlineString.addAttribute(NSAttributedString.Key.font,
                                         value: UIFont.SFPro.regular(size: 17).font ?? .systemFont(ofSize: 17),
                                         range: range)
            underlineString.addAttribute(NSAttributedString.Key.foregroundColor,
                                         value: UIColor(hex: "023B46"),
                                         range: range)
        }
        label.attributedText = underlineString
        label.font = UIFont.SFPro.regular(size: 17).font
        label.textColor = UIColor(hex: "023B46")
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
        return label
    }()
    
    private lazy var itsClearButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.itSClear(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 18).font
        button.backgroundColor = UIColor(hex: "1A645A")
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.addDefaultShadowForPopUp()
        button.addTarget(self, action: #selector(itsClearButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let blurView = UIVisualEffectView(effect: nil)
    private var blurRadiusDriver: UIViewPropertyAnimator?
    
    private let descriptionText = R.string.localizable.groceryListCanImportRecipes()
    private lazy var microdataRange = (descriptionText as NSString).range(of: R.string.localizable.rangeMicrodata())
    private lazy var hrecipeRange = (descriptionText as NSString).range(of: R.string.localizable.rangeHrecipe())
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        makeConstraints()
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
    
    private func reinitBlurView() {
        blurRadiusDriver?.stopAnimation(true)
        blurRadiusDriver?.finishAnimation(at: .current)
        
        blurView.effect = nil
        blurRadiusDriver = UIViewPropertyAnimator(duration: 1, curve: .linear, animations: {
            self.blurView.effect = UIBlurEffect(style: .systemThinMaterialDark)
        })
        blurRadiusDriver?.fractionComplete = 0.2
    }
    
    @objc
    private func tapLabel(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: descriptionLabel,
                                               inRange: microdataRange) {
            delegate?.tappedMicrodata()
        } else if gesture.didTapAttributedTextInLabel(label: descriptionLabel,
                                                      inRange: hrecipeRange) {
            delegate?.tappedHrecipe()
        }
    }
    
    @objc
    private func itsClearButtonTapped() {
        delegate?.tappedItsClear()
    }
    
    private func makeConstraints() {
        addSubview(blurView)
        blurView.contentView.addSubviews([containerView, descriptionLabel])
        containerView.addSubviews([titleLabel, itsClearButton])
        
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(46)
            $0.center.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(24)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(containerView).inset(16)
            $0.bottom.equalTo(itsClearButton.snp.top).offset(-24)
        }
        
        itsClearButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(48)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-32)
            $0.height.equalTo(48)
        }
    }
}
