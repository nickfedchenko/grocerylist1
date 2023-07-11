//
//  CreateNewRecipeStepTwoViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.03.2023.
//

import UIKit

final class CreateNewRecipeStepTwoViewController: UIViewController {

    var viewModel: CreateNewRecipeStepTwoViewModel?
    
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
        label.text = R.string.localizable.back()
        return label
    }()
    
    private lazy var savedToDraftsButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.saveToDrafts(), for: .normal)
        button.setTitleColor(R.color.background(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.setImage(R.image.collection()?.withTintColor(R.color.background() ?? .white),
                        for: .normal)
        button.layer.cornerRadius = 8
        button.semanticContentAttribute = .forceRightToLeft
        button.contentEdgeInsets.left = 8
        button.addTarget(self, action: #selector(savedToDraftsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.saverecipetO(), for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.backgroundColor = R.color.primaryDark()
        button.layer.shadowOpacity = 0.15
        button.addDefaultShadowForPopUp()
        return button
    }()
    
    private let topSafeAreaView = UIView()
    private let navigationView = UIView()
    private let contentView = UIView()
    
    private let savedToDraftsAlertView = CreateNewRecipeSavedToDraftsAlertView()
    private let titleView = CreateNewRecipeTitleView()
    private let timeView = CreateNewRecipeViewWithTextField()
    private let servingsView = CreateNewRecipeViewWithTextField()
    private let kcalView = CreateNewRecipeKcalView()
    private let photoView = CreateNewRecipePhotoView()
    
    private let imagePicker = UIImagePickerController()
    private var isVisibleKeyboard = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.view.backgroundColor = R.color.background()
        setupNavigationView()
        setupCustomView()
        setupStackView()
        makeConstraints()
        
        setupCurrentRecipe()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground),
                                               name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func setupNavigationView() {
        topSafeAreaView.backgroundColor = R.color.background()
        navigationView.backgroundColor = R.color.background()
        
        if viewModel?.isDraftRecipe ?? false {
            savedToDrafts()
        }
        updateSavedToDraftsButton()
        savedToDraftsAlertView.isHidden = true
        savedToDraftsAlertView.leaveCreatingRecipeTapped = { [weak self] in
            self?.savedToDraftsAlertView.fadeOut()
            self?.viewModel?.back()
        }
        
        savedToDraftsAlertView.continueWorkTapped = { [weak self] in
            self?.savedToDraftsAlertView.fadeOut()
        }
    }
    
    private func setupCustomView() {
        titleView.setRecipe(title: R.string.localizable.recipeCreation())
        titleView.setStep(R.string.localizable.step2Of2())
        timeView.setOnlyNumber()
        timeView.configure(title: R.string.localizable.preparationTimeMinutes(), state: .recommended)
        timeView.textFieldReturnPressed = { [weak self] in
            self?.servingsView.textView.becomeFirstResponder()
        }
        
        servingsView.configure(title: R.string.localizable.servings().capitalized, state: .recommended)
        servingsView.setOnlyNumber()

        photoView.imageTapped = { [weak self] in
            (self?.isVisibleKeyboard ?? false) ? self?.dismissKeyboard() : self?.pickImage()
        }
    }

    private func setupStackView() {
        stackView.addArrangedSubview(navigationView)
        stackView.addArrangedSubview(titleView)
        stackView.addArrangedSubview(timeView)
        stackView.addArrangedSubview(servingsView)
        stackView.addArrangedSubview(kcalView)
        stackView.addArrangedSubview(photoView)
    }
    
    private func setupCurrentRecipe() {
        guard let currentRecipe = viewModel?.currentRecipe else {
            return
        }
        savedToDraftsButton.isHidden = true
        
        if let cookingTime = currentRecipe.cookingTime?.asString {
            timeView.setText(cookingTime)
        }
        servingsView.setText(currentRecipe.totalServings.asString)
        kcalView.setKcalValue(value: currentRecipe.values?.dish)
        if let imageData = currentRecipe.localImage,
            let image = UIImage(data: imageData) {
            photoView.setImage(image)
        }
    }
    
    private func savedToDrafts() {
        savedToDraftsButton.setTitle(R.string.localizable.savedInDrafts(), for: .normal)
        savedToDraftsButton.setTitleColor(R.color.darkGray(), for: .normal)
        savedToDraftsButton.setImage(R.image.collection()?.withTintColor(R.color.darkGray() ?? .black),
                                     for: .normal)
        savedToDraftsButton.backgroundColor = R.color.background()
        savedToDraftsButton.layer.borderColor = R.color.darkGray()?.cgColor
        savedToDraftsButton.layer.borderWidth = 1
        savedToDraftsButton.isUserInteractionEnabled = false
    }
    
    private func updateSavedToDraftsButton() {
        savedToDraftsButton.backgroundColor = R.color.darkGray()
        let isActive = savedToDraftsButton.titleLabel?.text == R.string.localizable.savedInDrafts()
        savedToDraftsButton.isUserInteractionEnabled = !isActive
        if isActive {
            savedToDraftsButton.backgroundColor = R.color.background()
        }
    }
    
    private func pickImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .pageSheet
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc
    private func backButtonTapped() {
        viewModel?.back()
    }
    
    @objc
    private func nextButtonTapped() {
        viewModel?.saveRecipeTo(time: timeView.textView.text?.asInt,
                                servings: servingsView.textView.text.asInt,
                                image: photoView.image,
                                kcal: kcalView.kcal)
    }
    
    @objc
    private func savedToDraftsButtonTapped() {
        viewModel?.isDraftRecipe = true
        savedToDrafts()
        viewModel?.savedToDrafts(time: timeView.textView.text?.asInt,
                                 servings: servingsView.textView.text.asInt,
                                 image: photoView.image,
                                 kcal: kcalView.kcal)
        savedToDraftsAlertView.fadeIn()
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        isVisibleKeyboard = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc
    private func appMovedToBackground() {
        viewModel?.savedToDrafts(time: timeView.textView.text?.asInt,
                                 servings: servingsView.textView.text.asInt,
                                 image: photoView.image,
                                 kcal: kcalView.kcal)
    }
    
    @objc
    private func dismissKeyboard() {
        isVisibleKeyboard = false
        guard let gestureRecognizers = self.view.gestureRecognizers else {
            return
        }
        gestureRecognizers.forEach { $0.isEnabled = false }
        self.view.endEditing(true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([scrollView, topSafeAreaView, nextButton, savedToDraftsAlertView])
        self.scrollView.addSubview(contentView)
        contentView.addSubviews([stackView])
        navigationView.addSubviews([backButton, backLabel, savedToDraftsButton])
        
        topSafeAreaView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(stackView.snp.bottom).offset(37)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
            $0.bottom.greaterThanOrEqualTo(self.view).offset(-80)
        }
        
        savedToDraftsAlertView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
        
        savedToDraftsButton.snp.makeConstraints {
            $0.leading.greaterThanOrEqualTo(backLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview()
            $0.height.equalTo(40)
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
            $0.edges.equalToSuperview()
            $0.width.equalTo(self.view)
        }
    }
    
    private func makeCustomViewConstraints() {
        navigationView.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalToSuperview()
        }
        
        titleView.snp.makeConstraints {
            $0.height.equalTo(titleView.requiredHeight)
            $0.width.equalToSuperview()
        }
        
        timeView.snp.makeConstraints {
            $0.height.equalTo(timeView.requiredHeight)
            $0.width.equalToSuperview()
        }
                
        servingsView.snp.makeConstraints {
            $0.height.equalTo(servingsView.requiredHeight)
            $0.width.equalToSuperview()
        }

        kcalView.snp.makeConstraints {
            $0.height.equalTo(kcalView.requiredHeight)
            $0.width.equalToSuperview()

        }

        photoView.snp.makeConstraints {
            $0.height.equalTo(photoView.requiredHeight)
            $0.width.equalToSuperview()
        }
    }
}

extension CreateNewRecipeStepTwoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        photoView.setImage(image)
    }
}
