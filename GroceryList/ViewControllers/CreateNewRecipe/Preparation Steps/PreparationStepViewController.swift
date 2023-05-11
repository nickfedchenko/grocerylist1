//
//  PreparationStepViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 06.03.2023.
//

import UIKit

final class PreparationStepViewController: UIViewController {

    var viewModel: PreparationStepViewModel?
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E5F5F3")
        return view
    }()
    
    private lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#FCFCFE")
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 16).font
        label.textColor = R.color.primaryDark()
        return label
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.font = UIFont.SFPro.medium(size: 18).font
        textView.contentInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 8)
        textView.textColor = .black
        textView.layer.cornerRadius = 16
        return textView
    }()
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor =  R.color.primaryDark()
        button.setTitle(R.string.localizable.save().uppercased(), for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.makeCustomRound(topLeft: 4, topRight: 40, bottomLeft: 0, bottomRight: 0)
    }
    
    private func setup() {
        setupContentView()
        updateSaveButton(isActive: false)
        setupShadowView()
        makeConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupContentView() {
        let swipeDownRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(swipeDownRecognizer)
        
        let title = R.string.localizable.step() + " " + "\(viewModel?.stepNumber ?? 1)"
        titleLabel.text = title
        textView.becomeFirstResponder()
    }
    
    private func updateSaveButton(isActive: Bool) {
        saveButton.backgroundColor = isActive ? R.color.primaryDark() : UIColor(hex: "#D8ECE9")
        saveButton.isUserInteractionEnabled = isActive
    }
    
    @objc
    private func saveButtonTapped() {
        viewModel?.save(step: textView.text)
        hidePanel()
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardFrame = value?.cgRectValue else { return }
        let height = Double(keyboardFrame.height)
        updateConstraints(with: height, alpha: 0.2)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
    
    private func updateConstraints(with inset: Double, alpha: Double) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints {
                $0.bottom.equalToSuperview().inset(inset)
            }
            self.view.backgroundColor = .black.withAlphaComponent(alpha)
            self.view.layoutIfNeeded()
        }
    }

    private func hidePanel() {
        textView.resignFirstResponder()
        updateConstraints(with: -400, alpha: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func setupShadowView() {
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.backgroundColor = UIColor(hex: "#E5F5F3")
            shadowView.layer.cornerRadius = 16
        }
        shadowOneView.addCustomShadow(color: UIColor(hex: "#484848"),
                                      opacity: 0.15,
                                      radius: 1,
                                      offset: .init(width: 0, height: 0.5))
        shadowTwoView.addCustomShadow(color: UIColor(hex: "#858585"),
                                      opacity: 0.1,
                                      radius: 6,
                                      offset: .init(width: 0, height: 6))
    }
    
    private func makeConstraints() {
        self.view.addSubview(contentView)
        contentView.addSubviews([shadowOneView, shadowTwoView, titleView, textView, saveButton])
        titleView.addSubview(titleLabel)
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(293)
            $0.bottom.equalToSuperview().inset(-293)
        }
        
        titleView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(17)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(149)
            $0.bottom.equalTo(saveButton.snp.top).offset(-16)
        }
        
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.snp.makeConstraints { $0.edges.equalTo(textView) }
        }
        
        saveButton.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
    }
}

extension PreparationStepViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButton(isActive: !textView.text.isEmpty)
    }
}
