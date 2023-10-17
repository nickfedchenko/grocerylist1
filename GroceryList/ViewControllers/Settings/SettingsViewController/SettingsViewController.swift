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

    private let navigationView = UIView()
    
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
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private lazy var unitsView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "Quantity Units".localized, unitSustemText: viewModel?.getTextForUnitSystemView())
        return view
    }()
    
    private lazy var iCloudDataBackupView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: R.string.localizable.iCloudDataBackup(), isSwitchView: true)
        view.updateSwitcher(isOn: UserDefaultsManager.shared.isICloudDataBackupOn)
        view.switchValueChanged = { switchValue in
            Vibration.rigid.vibrate()
            self.viewModel?.tappedICloudDataBackup(switchValue, completion: {
                view.updateSwitcher(isOn: UserDefaultsManager.shared.isICloudDataBackupOn)
            })
        }
        return view
    }()
    
    private lazy var hapticView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "Haptic Feedback".localized, isSwitchView: true)
        view.updateSwitcher(isOn: UserDefaultsManager.shared.isHapticOn)
        view.switchValueChanged = { switchValue in
            Vibration.rigid.vibrate()
            AmplitudeManager.shared.logEvent(.prefHapticToggle, properties: [.isActive: switchValue ? .yes : .valueNo])
            UserDefaultsManager.shared.isHapticOn = switchValue
            CloudManager.shared.saveCloudSettings()
        }
        return view
    }()
    
    private lazy var showProductImageView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: R.string.localizable.settingsPictureMatching(), isSwitchView: true)
        view.updateSwitcher(isOn: UserDefaultsManager.shared.isShowImage)
        view.switchValueChanged = { switchValue in
            Vibration.rigid.vibrate()
            AmplitudeManager.shared.logEvent(.prefPictureToggle, properties: [.isActive: switchValue ? .yes : .valueNo])
            UserDefaultsManager.shared.isShowImage = switchValue
            CloudManager.shared.saveCloudSettings()
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
    
    private lazy var helpAndFaqView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "Help & FAQ".localized)
        return view
    }()
    
    private lazy var selectUnitsView: SelectUnitsView = {
        let view = SelectUnitsView(imperialColor: viewModel?.getBackgroundColorForImperial(),
                                   metricColor: viewModel?.getBackgroundColorForMetric())
        view.systemSelected = { [weak self] selectedSystem in
            Vibration.selection.vibrate()
            self?.viewModel?.systemSelected(system: selectedSystem)
        }
        view.layer.cornerRadius = 12
        view.addDefaultShadowForPopUp()
        return view
    }()
    
    private lazy var registerView: RegisterWithMessageView = {
        let view = RegisterWithMessageView()
        view.registerButtonPressed = { [weak self] in
            Vibration.medium.vibrate()
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
        helpAndFaqView.isHidden = !FeatureManager.shared.isActiveFAQ
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
        view.backgroundColor = R.color.background()
        navigationView.backgroundColor = R.color.background()?.withAlphaComponent(0.9)
        
        self.view.addSubviews([scrollView, navigationView])
        self.scrollView.addSubview(contentView)
        navigationView.addSubviews([preferenciesLabel, closeButton])
        contentView.addSubviews([profileView, unitsView, iCloudDataBackupView, likeAppView,
                                 hapticView, showProductImageView, contactUsView,
                                 selectUnitsView, helpAndFaqView, registerView])
        
        navigationView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(preferenciesLabel).offset(8)
        }
        
        preferenciesLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(20)
        }
        
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(31)
            make.centerY.equalTo(preferenciesLabel)
            make.height.width.equalTo(40)
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(self.view.frame.height - UIView.safeAreaTop)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        
        profileView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(72)
            make.left.right.equalToSuperview()
        }
        
        unitsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(profileView.snp.bottom).inset(-5)
            make.height.equalTo(54)
        }
        
        iCloudDataBackupView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(unitsView.snp.bottom)
            make.height.equalTo(54)
        }
        
        hapticView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(iCloudDataBackupView.snp.bottom)
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
        
        helpAndFaqView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(contactUsView.snp.bottom)
            make.height.equalTo(54)
        }
        
        registerView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(helpAndFaqView.snp.bottom).offset(-24)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
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
        let helpAndFaqViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(helpAndFaqAction))
        unitsView.addGestureRecognizer(unitsViewRecognizer)
        likeAppView.addGestureRecognizer(likeAppViewRecognizer)
        contactUsView.addGestureRecognizer(contactUsViewRecognizer)
        helpAndFaqView.addGestureRecognizer(helpAndFaqViewRecognizer)
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
        Vibration.selection.vibrate()
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
        Vibration.selection.vibrate()
        AmplitudeManager.shared.logEvent(.prefLike)
        guard let
                url = URL(string: "itms-apps://itunes.apple.com/app/id1659848939?action=write-review"),
              UIApplication.shared.canOpenURL(url)
        else { return }
        UIApplication.shared.open(url)
    }
    
    @objc
    private func contactUsAction(_ recognizer: UIPanGestureRecognizer) {
        Vibration.selection.vibrate()
        AmplitudeManager.shared.logEvent(.problemTell)
        let controller = ContactUsViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc
    private func helpAndFaqAction(_ recognizer: UIPanGestureRecognizer) {
        Vibration.selection.vibrate()
        let controller = FAQViewController()
        self.navigationController?.pushViewController(controller, animated: true)
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
        scrollView.isScrollEnabled = true
        
        profileView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(72)
            make.left.right.equalToSuperview()
        }
        
        registerView.snp.remakeConstraints { make in
            make.top.greaterThanOrEqualTo(helpAndFaqView.snp.bottom).offset(-24)
            make.height.equalTo(0)
            make.bottom.equalToSuperview().inset(30)
        }
        
        profileView.setupView(avatarImage: avatarImage, email: email, userName: userName)
        
    }
    
    func setupNotRegisteredView() {
        registerView.isHidden = false
        profileView.isHidden = true
        scrollView.isScrollEnabled = false
     
        profileView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(72)
            make.height.equalTo(0)
            make.left.right.equalToSuperview()
        }
        
        registerView.snp.remakeConstraints { make in
            make.top.greaterThanOrEqualTo(helpAndFaqView.snp.bottom).offset(-24)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
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
