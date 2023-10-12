//
//  StopSharingPopUpView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 04.09.2023.
//

import UIKit

class StopSharingPopUpView: UIView {

    var stopSharing: (() -> Void)?
    var cancel: (() -> Void)?
    
    private lazy var userInfoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.text = R.string.localizable.invitedToTheCommonList()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var stopSharingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = R.color.primaryDark()
        button.setTitle(R.string.localizable.stopSharing(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 18).font
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.addTarget(self, action: #selector(tappedStopSharingButton), for: .touchUpInside)
        button.addDefaultShadowForPopUp()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.contentEdgeInsets.left = 10
        button.contentEdgeInsets.right = 10
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.cancel(), for: .normal)
        button.setTitleColor(UIColor(hex: "617774"), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 18).font
        button.addTarget(self, action: #selector(tappedCancelButton), for: .touchUpInside)
        return button
    }()
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hex: "E5F5F3")
        self.layer.cornerRadius = 8
        self.layer.cornerCurve = .continuous
        self.addDefaultShadowForPopUp()
        setupShadowView()
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureUser(_ user: User) {
        let userName = user.username ?? "-"
        let blackColor = [NSAttributedString.Key.foregroundColor: UIColor.black]
        let grayColor = [NSAttributedString.Key.foregroundColor: UIColor(hex: "617774")]

        let name = NSMutableAttributedString(string: userName, attributes: blackColor)
        let email = NSMutableAttributedString(string: "(\(user.email))", attributes: grayColor)

        name.append(NSAttributedString(string: " "))
        name.append(email)
        userInfoTitleLabel.attributedText = name
    }
    
    private func setupShadowView() {
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.backgroundColor = .white
            shadowView.layer.cornerRadius = 8
            shadowView.backgroundColor = UIColor(hex: "E5F5F3")
        }
        shadowOneView.addShadow(color: .black,
                                      opacity: 0.15,
                                      radius: 11,
                                      offset: .init(width: 0, height: 12))
        shadowTwoView.addShadow(color: .black,
                                      opacity: 0.06,
                                      radius: 3,
                                      offset: .init(width: 0, height: 2))
    }
    
    @objc
    private func tappedStopSharingButton() {
        stopSharing?()
    }
    
    @objc
    private func tappedCancelButton() {
        cancel?()
    }
    
    private func makeConstraints() {
        self.addSubviews([shadowOneView, shadowTwoView])
        self.addSubviews([userInfoTitleLabel, descriptionLabel, stopSharingButton, cancelButton])
        
        userInfoTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-8)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.bottom.equalTo(stopSharingButton.snp.top).offset(-18)
        }
        
        stopSharingButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(48)
            $0.bottom.equalTo(cancelButton.snp.top).offset(-8)
        }
        
        cancelButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(52)
            $0.height.equalTo(58)
            $0.bottom.equalToSuperview()
        }
        
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
}
