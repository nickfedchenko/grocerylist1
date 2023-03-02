//
//  CreateNewRecipeViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.03.2023.
//

import UIKit

final class CreateNewRecipeViewController: UIViewController {
    
    var viewModel: CreateNewRecipeViewModel?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var navigationView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.greenArrowBack(), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = UIColor(hex: "#1A645A")
        label.text = R.string.localizable.recipes()
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.btn_next(), for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.addDefaultShadowForPopUp()
        return button
    }()
    
    private let contentView = UIView()
    private var imagePicker = UIImagePickerController()
    
    private let nameView = CreateNewRecipeViewWithTextField()
    private let servingsView = CreateNewRecipeViewWithTextField()
    private let collectionView = CreateNewRecipeViewWithTextField()
    private let photoView = CreateNewRecipePhotoView()
    
    private var isVisibleKeyboard = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.view.backgroundColor = UIColor(hex: "#E5F5F3")
        setupCustomView()
        setupStackView()
        makeConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupCustomView() {
        nameView.configure(title: R.string.localizable.name(), state: .required)
        servingsView.configure(title: R.string.localizable.servings().capitalized, state: .required)
        collectionView.configure(title: R.string.localizable.collection(), state: .optional)
        
        nameView.textField.becomeFirstResponder()
        nameView.textFieldReturnPressed = { [weak self] in
            self?.servingsView.textField.becomeFirstResponder()
        }
        servingsView.setOnlyNumber()
        servingsView.textFieldReturnPressed = { [weak self] in
            self?.collectionView.textField.becomeFirstResponder()
        }
        
        collectionView.textFieldReturnPressed = { [weak self] in
            self?.collectionView.textField.resignFirstResponder()
        }
            
        photoView.imageTapped = { [weak self] in
            (self?.isVisibleKeyboard ?? false) ? self?.dismissKeyboard() : self?.pickImage()
        }
    }
    
    private func setupStackView() {
        let titleView = CreateNewRecipeTitleView()
        titleView.setStep(R.string.localizable.step1Of2())
        stackView.addArrangedSubview(titleView)
        titleView.snp.makeConstraints { $0.height.equalTo(titleView.requiredHeight) }
        
        stackView.addArrangedSubview(nameView)
        nameView.snp.makeConstraints { $0.height.equalTo(nameView.requiredHeight) }

        stackView.addArrangedSubview(servingsView)
        servingsView.snp.makeConstraints { $0.height.equalTo(servingsView.requiredHeight) }

        stackView.addArrangedSubview(collectionView)
        collectionView.snp.makeConstraints { $0.height.equalTo(collectionView.requiredHeight) }
        
        stackView.addArrangedSubview(photoView)
        photoView.snp.makeConstraints { $0.height.equalTo(photoView.requiredHeight) }
    }
    
    private func updateNextButton() {
        let isActive = !(nameView.textField.text?.isEmpty ?? true) &&
                       !(servingsView.textField.text?.isEmpty ?? true)
        nextButton.backgroundColor = UIColor(hex: isActive ? "#1A645A" : "#D8ECE9")
        nextButton.layer.shadowOpacity = isActive ? 0.15 : 0
        nextButton.isUserInteractionEnabled = isActive
    }
    
    @objc
    private func backButtonTapped() {
        viewModel?.back()
    }
    
    @objc
    private func nextButtonTapped() {
        guard let name = nameView.textField.text,
              let servings = servingsView.textField.text else {
            print("не заполнены поля")
            return
        }
        viewModel?.saveRecipe(name: name,
                              servings: servings,
                              collection: collectionView.textField.text,
                              photo: photoView.image)
        viewModel?.next()
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        isVisibleKeyboard = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc
    private func dismissKeyboard() {
        isVisibleKeyboard = false
        updateNextButton()
        
        guard let gestureRecognizers = self.view.gestureRecognizers else {
            return
        }
        gestureRecognizers.forEach { $0.isEnabled = false }
        self.view.endEditing(true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([scrollView, navigationView])
        self.scrollView.addSubview(contentView)
        contentView.addSubviews([stackView, nextButton])
        navigationView.addSubviews([backButton, backLabel])
        
        navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(40)
        }
        
        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navigationView.snp.bottom)
            $0.width.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(self.view)
        }
        
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.width.equalTo(self.view)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(37)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
            $0.bottom.equalToSuperview().offset(-80)
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
    }
}

extension CreateNewRecipeViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
        photoView.setImage(image)
    }
}
