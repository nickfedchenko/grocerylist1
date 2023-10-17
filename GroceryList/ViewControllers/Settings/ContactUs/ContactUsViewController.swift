//
//  ContactUsViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 05.10.2023.
//

import UIKit

class ContactUsViewController: UIViewController {

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset.bottom = 150
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.greenArrowBack(), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backLabel: UILabel = {
        let label = UILabel()
        let tapOnLabel = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        label.addGestureRecognizer(tapOnLabel)
        label.isUserInteractionEnabled = true
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = R.color.primaryDark()
        label.text = R.string.localizable.cancel()
        return label
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.send() + "  ", for: .normal)
        button.setImage(R.image.send_feedback(), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        button.addDefaultShadowForPopUp()
        return button
    }()
    
    private let topSafeAreaView = UIView()
    private let navigationView = UIView()
    private let contentView = UIView()
    
    private let emailView = CreateNewRecipeViewWithTextField()
    private let messageView = CreateNewRecipeViewWithTextField()
    private let messageHeight = 40 + 2 * 48
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.view.backgroundColor = R.color.background()
        topSafeAreaView.backgroundColor = R.color.background()
        navigationView.backgroundColor = R.color.background()
        
        setupCustomView()
        setupStackView()
        makeConstraints()

        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupCustomView() {
        emailView.textView.keyboardType = .emailAddress
        emailView.configure(title: R.string.localizable.contactUsYourEmail(), state: .required)
        emailView.textFieldReturnPressed = { [weak self] in
            self?.messageView.textView.becomeFirstResponder()
        }
        emailView.updateLayout = { [weak self] in
            guard let self else { return }
            self.emailView.snp.updateConstraints {
                $0.height.equalTo(self.emailView.requiredHeight)
            }
        }
        
        messageView.configure(title: R.string.localizable.contactUsHowCanWeHelp(),
                              state: .required, modeIsTextField: false)
        messageView.updateLayout = { [weak self] in
            guard let self else { return }
            let requiredHeight = self.messageView.requiredHeight
            let messageHeight = requiredHeight > self.messageHeight ? requiredHeight : self.messageHeight
            self.messageView.snp.updateConstraints {
                $0.height.greaterThanOrEqualTo(messageHeight)
            }
        }
        
        messageView.setTextFieldHeight(height: 2 * 48)
        
        checkSendButton()
    }

    private func checkSendButton() {
        let email = emailView.textView.text
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

        let isCorrectEmail = emailPredicate.evaluate(with: email)
        let message = !messageView.isEmpty
        
        let isActive = isCorrectEmail && message
        
        sendButton.backgroundColor = isActive ? R.color.primaryDark() : R.color.lightGray()
        sendButton.layer.shadowOpacity = isActive ? 0.15 : 0
        sendButton.isUserInteractionEnabled = isActive
    }
    
    private func setupStackView() {
        stackView.addArrangedSubview(navigationView)
        stackView.addArrangedSubview(emailView)
        stackView.addArrangedSubview(messageView)
    }
    
    private func setInfo() -> String {
        let version = Bundle.main.appVersionLong
        let build = Bundle.main.appBuild
        let systemVersion = UIDevice.current.systemVersion
        let device = UIDevice.current.name
        
        let info = """
\n\n
App version: \(version)(\(build))
Model: \(device)
OS version: \(systemVersion)
\n
"""
        return info
    }
    
    @objc
    private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc
    private func sendButtonTapped() {
        let email = emailView.textView.text
        let message = messageView.textView.text
        
        guard let email, let message else {
            return
        }
        var name = UserAccountManager.shared.getUser()?.username
        
        let sendMail = SendMail(name: (name?.isEmpty ?? true) ? "User" : name ?? "User",
                                email: email,
                                subject: "Grocery List",
                                message: message + setInfo())
        
        NetworkEngine().sendMail(sendMail: sendMail) { _ in }
        Vibration.medium.vibrate()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                               as? NSValue)?.cgRectValue {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                                   bottom: keyboardSize.height, right: 0)
            scrollView.scrollRectToVisible(messageView.frame, animated: true)
        }
    }
    
    @objc
    private func dismissKeyboard() {
        checkSendButton()
        scrollView.contentInset = .zero
        
        guard let gestureRecognizers = self.view.gestureRecognizers else {
            return
        }
        gestureRecognizers.forEach { $0.isEnabled = false }
        self.view.endEditing(true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([scrollView, topSafeAreaView, sendButton])
        self.scrollView.addSubview(contentView)
        contentView.addSubviews([stackView])
        navigationView.addSubviews([backButton, backLabel])
        
        topSafeAreaView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        navigationView.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalToSuperview()
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview()
            $0.height.width.equalTo(40)
        }
        
        backLabel.snp.makeConstraints {
            $0.leading.equalTo(backButton.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24)
        }

        sendButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(stackView.snp.bottom).offset(37)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
            $0.bottom.greaterThanOrEqualTo(self.view).offset(-80)
        }
        
        makeCustomViewConstraints()
    }
    
    private func makeCustomViewConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(self.view)
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(self.view)
        }
        
        emailView.snp.makeConstraints {
            $0.height.equalTo(emailView.requiredHeight)
            $0.width.equalToSuperview()
        }

        messageView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(messageHeight)
            $0.width.equalToSuperview()
        }
    }
}
