//
//  CreateNewProductViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 25.11.2022.
//

import Foundation

import SnapKit
import UIKit

class CreateNewProductViewController: UIViewController {
    
    var viewModel: CreateNewProductViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        addKeyboardNotifications()
        addRecognizers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTextFieldParametrs()
    }
    
    deinit {
        print("create new list deinited")
    }
    
    private func setupTextFieldParametrs() {
        topTextField.delegate = self
        topTextField.becomeFirstResponder()
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
        updateConstr(with: height)
    }
    
    func updateConstr(with inset: Double) {
        UIView.animate(withDuration: 0.3) { [ weak self ] in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(inset)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - swipeDown
    
    private func hidePanel() {
        topTextField.resignFirstResponder()
        updateConstr(with: -400)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UI
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F9FBEB")
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    private let topCategoryView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D2D5DA")
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    private let topCategoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        label.text = "Here should be category name"
        return label
    }()
    
    private let topCategoryPencilImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "whitePencil")
        return imageView
    }()
    
    private let textfieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "emptyCheckmark")
        return imageView
    }()
    
    private let topTextField: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont.SFPro.medium(size: 17).font
        textfield.textColor = .black
        textfield.backgroundColor = .white
        textfield.keyboardAppearance = .light
        textfield.attributedPlaceholder = NSAttributedString(
            string: "Name".localized,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "#D2D5DA")]
        )
        return textfield
    }()
    
    private let bottomTextField: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont.SFPro.medium(size: 15).font
        textfield.textColor = .black
        textfield.backgroundColor = .white
        textfield.keyboardAppearance = .light
        textfield.placeholder = "Name".localized
        textfield.attributedPlaceholder = NSAttributedString(
            string: "AddNote".localized,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "#D2D5DA")]
        )
        return textfield
    }()
    
    private let addImageImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "#addImage")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let saveButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D2D5DA")
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let saveLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 20).font
        label.textColor = .white
        label.text = "Save".localized.uppercased()
        return label
    }()
    
    // MARK: - Constraints
    private func setupConstraints() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.addSubviews([contentView])
        contentView.addSubviews([saveButtonView, topCategoryView, textfieldView])
        topCategoryView.addSubviews([topCategoryLabel, topCategoryPencilImage])
        textfieldView.addSubviews([checkmarkImage, topTextField, bottomTextField, addImageImage])
        saveButtonView.addSubview(saveLabel)
        
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-385)
            make.height.equalTo(268)
        }
        
        topCategoryView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(48)
        }
        
        topCategoryLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(28)
        }
        
        topCategoryPencilImage.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(35)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(25)
        }
        
        textfieldView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(topCategoryView.snp.bottom).inset(-8)
            make.height.equalTo(56)
        }
        
        checkmarkImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        topTextField.snp.makeConstraints { make in
            make.top.equalTo(checkmarkImage.snp.top)
            make.left.equalTo(checkmarkImage.snp.right).inset(-12)
            make.right.equalTo(addImageImage.snp.left).inset(-12)
            make.height.equalTo(21)
        }
        
        bottomTextField.snp.makeConstraints { make in
            make.left.right.equalTo(topTextField)
            make.top.equalTo(topTextField.snp.bottom).inset(-2)
            make.height.equalTo(19)
        }
        
        addImageImage.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        saveButtonView.snp.makeConstraints { make in
            make.bottom.right.left.equalToSuperview()
            make.height.equalTo(64)
        }
        
        saveLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
// MARK: - Textfield
extension CreateNewProductViewController: UITextFieldDelegate {
    
    private func readyToSave() {
        saveButtonView.isUserInteractionEnabled = true
        saveButtonView.backgroundColor = UIColor(hex: "#31635A")
    }
    
    private func notReadyToSave() {
        saveButtonView.isUserInteractionEnabled = false
        saveButtonView.backgroundColor = UIColor(hex: "#D2D5DA")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        if newLength > 2 {
            readyToSave()
        } else {
            notReadyToSave()
        }
        return newLength <= 30
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

// MARK: - recognizer actions
extension CreateNewProductViewController {
    
    private func addRecognizers() {
        
        let tapOnAddImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnAddImageAction))
        addImageImage.addGestureRecognizer(tapOnAddImageRecognizer)
        
        let tapOnCategoryRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnCategoryAction))
        topCategoryView.addGestureRecognizer(tapOnCategoryRecognizer)
     
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(saveAction))
        saveButtonView.addGestureRecognizer(tapRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(panRecognizer)
        
    }
    
    @objc
    private func tapOnAddImageAction() {
        print("tap on add image")
    }
    
    @objc
    private func tapOnCategoryAction() {
        print("tap on category")
    }
    
    @objc
    private func saveAction() {
        hidePanel()
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
}

extension CreateNewProductViewController: CreateNewProductViewModelDelegate {
    func presentController(controller: UIViewController?) {
        guard let controller else { return }
        present(controller, animated: true)
    }
    
    func updateLabelText(text: String) {
       
    }
}
