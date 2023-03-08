//
//  CreateNewCollectionViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import UIKit

final class CreateNewCollectionViewController: UIViewController {

    var viewModel: CreateNewCollectionViewModel?
    
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
        label.textColor = UIColor(hex: "#777777")
        label.text = "Create Collection"
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.tintColor = UIColor(hex: "#1A645A")
        textField.font = UIFont.SFPro.semibold(size: 17).font
        textField.textColor = .black
        return textField
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.menuFolder()
        return imageView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "#1A645A")
        button.setTitle("SAVE", for: .normal)
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
        makeConstraints()
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(hidePanel))
        tapOnView.delegate = self
        self.view.addGestureRecognizer(tapOnView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupContentView() {
        let swipeDownRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(swipeDownRecognizer)
        textField.becomeFirstResponder()
    }
    
    private func updateSaveButton(isActive: Bool) {
        saveButton.backgroundColor = UIColor(hex: isActive ? "#1A645A" : "#D8ECE9")
        saveButton.isUserInteractionEnabled = isActive
    }
    
    @objc
    private func saveButtonTapped() {
        viewModel?.save(textField.text)
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
    
    @objc
    private func hidePanel() {
        textField.resignFirstResponder()
        updateConstraints(with: -400, alpha: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false, completion: nil)
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
    
    private func makeConstraints() {
        self.view.addSubview(contentView)
        contentView.addSubviews([titleView, iconImageView, textField, saveButton])
        titleView.addSubview(titleLabel)
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(177)
            $0.bottom.equalToSuperview().inset(-177)
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
        
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(40)
            $0.bottom.equalTo(saveButton.snp.top).offset(-12)
        }
        
        textField.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(6)
            $0.height.equalTo(20)
        }
        
        saveButton.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
    }
}

extension CreateNewCollectionViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateSaveButton(isActive: !(textField.text?.isEmpty ?? true))
    }
}

extension CreateNewCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.contentView) ?? false)
    }
}
