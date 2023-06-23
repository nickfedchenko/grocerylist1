//
//  PasswordResetViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.02.2023.
//

import UIKit

class PasswordResetViewController: UIViewController {
    
    var viewModel: PasswordResetViewModel?
    
    private lazy var contentView: PasswordResetView = {
        let view = PasswordResetView()
        view.closeButtonPressed = { [weak self] in
            self?.viewModel?.closeButtonPressed()
        }
        
        view.resetButtonPressed = { [weak self] text in
            self?.viewModel?.resetButtonPressed(text: text)
        }
        return view
    }()
    
    private let viewForTypeToDissmiss = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addRecognizer()
        setupConstraints()
        addKeyboardNotifications()
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        view.addSubviews([contentView, viewForTypeToDissmiss])
        
        viewForTypeToDissmiss.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(contentView.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(-100)
            make.left.right.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - Recognizer
    private func addRecognizer() {
        let taptoHideRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToHideAction))
        viewForTypeToDissmiss.addGestureRecognizer(taptoHideRecognizer)
    }
    
    @objc
    private func tapToHideAction() {
        dismissController()
    }
    
    // MARK: - Keyboard
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(_ notification: NSNotification) {
        let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardFrame = value?.cgRectValue else { return }
        let height = Double(keyboardFrame.height)
        updateConstr(with: height + 19, alpha: 0.5, compl: nil)
    }

    private func updateConstr(with inset: Double, alpha: Double, compl: (() -> Void)?) {
        UIView.animate(withDuration: 0.3) { [ weak self ] in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(inset)
            }
            self.view.backgroundColor = .black.withAlphaComponent(alpha)
            self.view.layoutIfNeeded()
        } completion: { _ in
            compl?()
        }
    }
    
}

extension PasswordResetViewController: PasswordResetViewModelDelegate {
    func dismissController() {
        contentView.resignTextFieldFiresResponder()
        updateConstr(with: -300, alpha: 0) { [weak self] in
            self?.dismiss(animated: false)
        }
    }
    
    func applySecondState() {
        contentView.applySecondState()
    }
    
    func setupTextfieldText(text: String) {
        contentView.setupTextfieldText(text: text)
    }
}
