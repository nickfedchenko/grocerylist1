//
//  CreateNewRecipeViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.03.2023.
//

import UIKit

final class CreateNewRecipeStepOneViewController: UIViewController {
    
    var viewModel: CreateNewRecipeStepOneViewModel?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset.top = CGFloat(titleView.requiredHeight + 40)
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
    
    private let topSafeAreaView = UIView()
    private let navigationView = UIView()
    private let contentView = UIView()
    private var imagePicker = UIImagePickerController()
    private let titleView = CreateNewRecipeTitleView()
    private let nameView = CreateNewRecipeViewWithTextField()
    private let servingsView = CreateNewRecipeViewWithTextField()
    private let collectionView = CreateNewRecipeViewWithButton()
    private let photoView = CreateNewRecipePhotoView()
    
    private var isVisibleKeyboard = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.view.backgroundColor = UIColor(hex: "#E5F5F3")
        navigationView.backgroundColor = UIColor(hex: "#E5F5F3").withAlphaComponent(0.9)
        topSafeAreaView.backgroundColor = UIColor(hex: "#E5F5F3").withAlphaComponent(0.9)
        setupCustomView()
        setupStackView()
        makeConstraints()
        
        viewModel?.changeCollections = { [weak self] collectionTitles in
            var title = ""
            collectionTitles.forEach { title.append("\($0), ") }
            if !title.isEmpty {
                title.removeLast(2)
            }
            self?.collectionView.updateCollectionPlaceholder(title)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupCustomView() {
        titleView.setStep(R.string.localizable.step1Of2())
        nameView.configure(title: R.string.localizable.name(), state: .required)
        servingsView.configure(title: R.string.localizable.servings().capitalized, state: .required)
        servingsView.setOnlyNumber()
        collectionView.closeStackButton(isVisible: false)
        collectionView.configure(title: R.string.localizable.collection(), state: .optional)
        
        nameView.textField.becomeFirstResponder()
        nameView.textFieldReturnPressed = { [weak self] in
            self?.servingsView.textField.becomeFirstResponder()
        }
        collectionView.buttonPressed = { [weak self] in
            self?.viewModel?.openCollection()
        }
            
        photoView.imageTapped = { [weak self] in
            (self?.isVisibleKeyboard ?? false) ? self?.dismissKeyboard() : self?.pickImage()
        }
    }
    
    private func setupStackView() {
        stackView.addArrangedSubview(nameView)
        stackView.addArrangedSubview(servingsView)
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(photoView)
    }
    
    private func updateNextButton(isActive: Bool) {
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
              let servings = servingsView.textField.text?.asInt else {
            print("что-то пошло не так, проверьте обязательные поля")
            updateNextButton(isActive: false)
            return
        }
        viewModel?.saveRecipe(title: name,
                              servings: servings,
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
        let isActive = !(nameView.textField.text?.isEmpty ?? true) &&
                       !(servingsView.textField.text?.isEmpty ?? true)
        updateNextButton(isActive: isActive)
        
        guard let gestureRecognizers = self.view.gestureRecognizers else {
            return
        }
        gestureRecognizers.forEach { $0.isEnabled = false }
        self.view.endEditing(true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([scrollView, topSafeAreaView, navigationView, titleView])
        self.scrollView.addSubview(contentView)
        contentView.addSubviews([stackView, nextButton])
        navigationView.addSubviews([backButton, backLabel])
        
        topSafeAreaView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(40)
        }
        
        titleView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(navigationView.snp.bottom)
            $0.height.equalTo(titleView.requiredHeight)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(37)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
            $0.bottom.equalToSuperview().offset(-80)
        }
        
        makeScrollConstraints()
        makeNavViewConstraints()
        makeCustomViewConstraints()
    }
    
    private func makeNavViewConstraints() {
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
    
    private func makeScrollConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
    }
    
    private func makeCustomViewConstraints() {
        nameView.snp.makeConstraints {
            $0.height.equalTo(nameView.requiredHeight)
            $0.width.equalToSuperview()
        }
        
        servingsView.snp.makeConstraints {
            $0.height.equalTo(servingsView.requiredHeight)
            $0.width.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.height.equalTo(collectionView.requiredHeight)
            $0.width.equalToSuperview()
            
        }
        
        photoView.snp.makeConstraints {
            $0.height.equalTo(photoView.requiredHeight)
            $0.width.equalToSuperview()
        }
    }
}

extension CreateNewRecipeStepOneViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
