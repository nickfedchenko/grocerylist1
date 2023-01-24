//
//  SettingsViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//

import MessageUI
import SnapKit
import StoreKit
import UIKit

class SettingsViewController: UIViewController {
    
    var viewModel: SettingsViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectUnitsView.transform = CGAffineTransform(scaleX: 0, y: 0)
        setupConstraints()
        addRecognizer()
    }
    
    deinit {
        print("SettingsViewController deinited")
    }
    
    @objc
    private func closeButtonAction(_ recognizer: UIPanGestureRecognizer) {
        viewModel?.closeButtonTapped()
    }
    
    // MARK: - UI
    
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        return view
    }()
    
    private let preferenciesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 22).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "preferencies".localized
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setImage(UIImage(named: "greenCross"), for: .normal)
        return button
    }()
    
    private lazy var unitsView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "Quantity Units".localized, unitSustemText: viewModel?.getTextForUnitSystemView())
        return view
    }()
    
    private let hapticView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "Haptic Feedback".localized, isHaptickView: true)
        return view
    }()
    
    private let likeAppView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "DoYouLikeApp?".localized)
        return view
    }()
    
    private let contactUsView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "Problems?".localized)
        return view
    }()
    
    private let selectUnitsView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.isHidden = false
        view.addShadowForView()
        return view
    }()
    
    private lazy var imperialView: UIView = {
        let view = UIView()
        view.backgroundColor = viewModel?.getBackgroundColorForImperial()
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()
    
    private let imperialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "Imperial".localized
        return label
    }()
    
    private lazy var metricView: UIView = {
        let view = UIView()
        view.backgroundColor = viewModel?.getBackgroundColorForMetric()
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        view.layer.masksToBounds = true
        return view
    }()
    
    private let metriclLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "Metric".localized
        return label
    }()
    
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        view.addSubviews([preferenciesLabel, closeButton, unitsView, hapticView, likeAppView, contactUsView, contactUsView, selectUnitsView])
        selectUnitsView.addSubviews([imperialView, metricView])
        metricView.addSubview(metriclLabel)
        imperialView.addSubview(imperialLabel)
        
        preferenciesLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(20)
        }
        
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(31)
            make.centerY.equalTo(preferenciesLabel)
            make.height.width.equalTo(18)
        }
        
        unitsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(preferenciesLabel.snp.bottom).inset(-42)
            make.height.equalTo(54)
        }
        
        hapticView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(unitsView.snp.bottom)
            make.height.equalTo(54)
        }
        
        likeAppView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(hapticView.snp.bottom)
            make.height.equalTo(54)
        }
        
        contactUsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(likeAppView.snp.bottom)
            make.height.equalTo(54)
        }
        
        selectUnitsView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.top.equalTo(unitsView.snp.top).inset(4)
            make.width.equalTo(254)
            make.height.equalTo(92)
        }
        
        imperialView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        metricView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        metriclLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16)
        }
        
        imperialLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16)
        }
        
    }
}

extension SettingsViewController {
    
    private func addRecognizer() {
        let unitsViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(unitsViewAction))
        let likeAppViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(likeAppViewAction))
        let contactUsViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(contactUsAction))
        unitsView.addGestureRecognizer(unitsViewRecognizer)
        likeAppView.addGestureRecognizer(likeAppViewRecognizer)
        contactUsView.addGestureRecognizer(contactUsViewRecognizer)
        
        let imperialViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(imperialViewAction))
        imperialView.addGestureRecognizer(imperialViewRecognizer)
        let metricViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(metricViewAction))
        metricView.addGestureRecognizer(metricViewRecognizer)
    }
    
    @objc
    private func imperialViewAction(_ recognizer: UIPanGestureRecognizer) {
        viewModel?.imperialSystemSelected()
        imperialView.backgroundColor = .white
        metricView.backgroundColor = .white
        imperialView.backgroundColor = viewModel?.getBackgroundColorForImperial()
        hideUnitsView()
    }
    
    @objc
    private func metricViewAction(_ recognizer: UIPanGestureRecognizer) {
        viewModel?.metricSystemSelected()
        imperialView.backgroundColor = .white
        metricView.backgroundColor = .white
        metricView.backgroundColor = viewModel?.getBackgroundColorForMetric()
        hideUnitsView()
    }
    
    func hideUnitsView() {
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.selectUnitsView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.updateUnitSystemView()
        }
    }
    
    func updateUnitSystemView() {
        selectUnitsView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        unitsView.setupView(text: "Quantity Units".localized, unitSustemText: viewModel?.getTextForUnitSystemView())
    }
    
    @objc
    private func unitsViewAction(_ recognizer: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.selectUnitsView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.view.layoutIfNeeded()
        } completion: { _ in
        }
    }
    
    @objc
    private func likeAppViewAction(_ recognizer: UIPanGestureRecognizer) {
        guard let
                url = URL(string: "itms-apps://itunes.apple.com/app/id1659848939?action=write-review"),
              UIApplication.shared.canOpenURL(url)
        else { return }
        UIApplication.shared.open(url)
    }
    
    @objc
    private func contactUsAction(_ recognizer: UIPanGestureRecognizer) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["ksennn.vasko0222@yandex.ru"])
            mail.setMessageBody("<p>Hey! I have some questions!</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            print("Send mail not allowed")
        }
    }
  
}

// MARK: - Contact Us
extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true)
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    
}
