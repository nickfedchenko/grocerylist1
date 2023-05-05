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
    private var imagePicker = UIImagePickerController()

    private let preferenciesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 22).font
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
    
    private lazy var hapticView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "Haptic Feedback".localized, isSwitchView: true)
        view.updateSwitcher(isOn: UserDefaultsManager.isHapticOn)
        view.switchValueChanged = { switchValue in
            AmplitudeManager.shared.logEvent(.prefHapticToggle, properties: [.isActive: switchValue ? .yes : .no])
            UserDefaultsManager.isHapticOn = switchValue
        }
        return view
    }()
    
    private lazy var showProductImageView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: R.string.localizable.pictureMatching(), isSwitchView: true)
        view.updateSwitcher(isOn: UserDefaultsManager.isShowImage)
        view.switchValueChanged = { switchValue in
            AmplitudeManager.shared.logEvent(.prefPictureToggle, properties: [.isActive: switchValue ? .yes : .no])
            UserDefaultsManager.isShowImage = switchValue
        }
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
    
    private lazy var selectUnitsView: SelectUnitsView = {
        let view = SelectUnitsView(imperialColor: viewModel?.getBackgroundColorForImperial(),
                                   metricColor: viewModel?.getBackgroundColorForMetric())
        view.systemSelected = { [weak self] selectedSystem in
            self?.viewModel?.systemSelected(system: selectedSystem)
        }
        view.layer.cornerRadius = 12
        view.addDefaultShadowForPopUp()
        return view
    }()
    
    private lazy var registerView: RegisterWithMessageView = {
        let view = RegisterWithMessageView()
        view.registerButtonPressed = { [weak self] in
            self?.viewModel?.registerButtonPressed()
        }
        return view
    }()
    
    private lazy var profileView: SettingsProfileView = {
        let view = SettingsProfileView()
        
        view.saveNewNamePressed = { [weak self] name in
            self?.viewModel?.saveNewUserName(name: name)
        }
        
        view.accountButtonPressed = { [weak self] in
            self?.viewModel?.accountButtonTapped()
        }
        
        view.avatarButtonPressed = { [weak self] in
            self?.viewModel?.avatarButtonTapped()
        }
        return view
    }()
    
    // MARK: - LifeCycle
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectUnitsView.transform = CGAffineTransform(scaleX: 0, y: 0)
        setupConstraints()
        addRecognizer()
        setupNavigationBar(titleText: R.string.localizable.preferencies())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    deinit {
        print("SettingsViewController deinited")
    }
    
    // MARK: - Functions
    
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        view.addSubviews([preferenciesLabel, closeButton, profileView, unitsView, likeAppView,
                          hapticView, showProductImageView, contactUsView, selectUnitsView,
                          registerView])
        
        preferenciesLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(20)
        }
        
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(31)
            make.centerY.equalTo(preferenciesLabel)
            make.height.width.equalTo(40)
        }
        
        profileView.snp.makeConstraints { make in
            make.top.equalTo(preferenciesLabel.snp.bottom).inset(-24)
            make.left.right.equalToSuperview()
        }
        
        unitsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(profileView.snp.bottom).inset(-5)
            make.height.equalTo(54)
        }
        
        hapticView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(unitsView.snp.bottom)
            make.height.equalTo(54)
        }
        
        showProductImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(hapticView.snp.bottom)
            make.height.equalTo(54)
        }
        
        likeAppView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(showProductImageView.snp.bottom)
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
        
        registerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(30)
        }
    }
}

extension SettingsViewController {
    
    @objc
    private func closeButtonAction(_ recognizer: UIPanGestureRecognizer) {
        viewModel?.getTextFromTextField(profileView.textFromScreenName)
        viewModel?.closeButtonTapped()
    }

    private func addRecognizer() {
        let unitsViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(unitsViewAction))
        let likeAppViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(likeAppViewAction))
        let contactUsViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(contactUsAction))
        unitsView.addGestureRecognizer(unitsViewRecognizer)
        likeAppView.addGestureRecognizer(likeAppViewRecognizer)
        contactUsView.addGestureRecognizer(contactUsViewRecognizer)
    }

    func hideUnitsView() {
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.unitsView.setupView(text: "Quantity Units".localized,
                                     unitSustemText: self.viewModel?.getTextForUnitSystemView())
            self.selectUnitsView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.updateUnitSystemView()
        }
    }
    
    func updateUnitSystemView() {
        selectUnitsView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
    }
    
    @objc
    private func unitsViewAction(_ recognizer: UIPanGestureRecognizer) {
        AmplitudeManager.shared.logEvent(.prefUnits)
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
        AmplitudeManager.shared.logEvent(.prefLike)
        guard let
                url = URL(string: "itms-apps://itunes.apple.com/app/id1659848939?action=write-review"),
              UIApplication.shared.canOpenURL(url)
        else { return }
        UIApplication.shared.open(url)
    }
    
    @objc
    private func contactUsAction(_ recognizer: UIPanGestureRecognizer) {
        AmplitudeManager.shared.logEvent(.problemTell)
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["ksennn.vasko0222@yandex.ru"])
            mail.setSubject("Version \(Bundle.main.appVersionLong)(\(Bundle.main.appBuild))")
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
    
    func setupRegisteredView(avatarImage: UIImage?, userName: String?, email: String) {
        registerView.isHidden = true
        profileView.isHidden = false
        
        unitsView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(profileView.snp.bottom).inset(-5)
            make.height.equalTo(54)
        }
        
        profileView.setupView(avatarImage: avatarImage, email: email, userName: userName)
        
    }
    
    func setupNotRegisteredView() {
        registerView.isHidden = false
        profileView.isHidden = true
     
        unitsView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(preferenciesLabel.snp.bottom).inset(-42)
            make.height.equalTo(54)
        }
    }
    
    func updateSelectionView() {
        selectUnitsView.updateColors(imperialColor: viewModel?.getBackgroundColorForImperial(),
                                     metricColor: viewModel?.getBackgroundColorForMetric())
        hideUnitsView()
    }
}

extension SettingsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func pickImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .pageSheet
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        profileView.setupImage(avatarImage: image)
        viewModel?.saveAvatar(image: image)
    }
}
