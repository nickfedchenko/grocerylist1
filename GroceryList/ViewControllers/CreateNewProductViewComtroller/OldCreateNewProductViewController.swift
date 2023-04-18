//
//  CreateNewProductViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 25.11.2022.
//
// swiftlint:disable file_length
import SnapKit
import UIKit

// TODO: удалю как закончу с версткой экрана !!!! РАССТАВИТЬ AmplitudeManager.shared.logEvent
class OldCreateNewProductViewController: UIViewController {
    
    var viewModel: CreateNewProductViewModel?
    private var imagePicker = UIImagePickerController()
    private var isCategorySelected = false
    private var quantityCount: Double = 0
    private var isImageChanged = false {
        didSet { setupRemoveImage() }
    }
    private var isUserImage = false
    private var userCommentText = ""
    private var quantityValueStep: Double = 1
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - UI
    
    private let topClearView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F9FBEB")
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
        label.textColor = UIColor(hex: "#777777")
        label.text = "Category".localized
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
        view.addShadowForView()
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
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var removeImageButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.removeImage(), for: .normal)
        button.addTarget(self, action: #selector(removeImageTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let quantityTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 15).font
        label.textColor = UIColor(hex: "#657674")
        label.text = "Quantity".localized
        return label
    }()
    
    private lazy var minusButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(minusButtonAction), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(UIImage(named: "minusInactive"), for: .normal)
        return button
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(plusButtonAction), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(UIImage(named: "plusInactive"), for: .normal)
        return button
    }()
    
    private let quantityView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor(hex: "#B8BFCC").cgColor
        view.layer.borderWidth = 1
        view.addShadowForView()
        return view
    }()
    
    private let selectUnitsBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private let selectUnitsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D2D5DA")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.addShadowForView()
        return view
    }()
    
    private let selectUnitsBigView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor(hex: "#31635A").cgColor
        view.layer.borderWidth = 1
        view.isHidden = false
        view.addShadowForView()
        return view
    }()
    
    private let tableview: UITableView = {
        let tableview = UITableView()
        tableview.showsVerticalScrollIndicator = false
        tableview.estimatedRowHeight = UITableView.automaticDimension
        tableview.layer.cornerRadius = 8
        tableview.layer.masksToBounds = true
        return tableview
    }()
    
    private let whiteArrowForSelectUnit: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "whiteArrowRight")
        return imageView
    }()
    
    private let selectUnitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        label.textAlignment = .center
        label.text = "pieces".localized
        return label
    }()
    
    private let quantityLabel: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont.SFPro.semibold(size: 17).font
        textfield.textColor = .black
        textfield.backgroundColor = .white
        textfield.keyboardAppearance = .light
        textfield.keyboardType = .decimalPad
        textfield.attributedPlaceholder = NSAttributedString(
            string: "0",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "#AEB4B2")]
        )
        return textfield
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
    
    private let predictiveTextView = PredictiveTextView()
    private var predictiveTextViewHeight = 86
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPredictiveTextView()
        setupConstraints()
        addKeyboardNotifications()
        setupBackgroundColor()
        addRecognizers()
        setupTableView()
        setupProduct()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTextFieldParametrs()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.makeCustomRound(topLeft: 4, topRight: 40, bottomLeft: 0, bottomRight: 0)
    }
    
    deinit {
        print("create new list deinited")
    }
    
    // MARK: - Setup Product
    private func setupProduct() {
        guard viewModel?.currentProduct != nil else {
            return
        }
        
        topCategoryView.backgroundColor = UIColor(hex: "#80C980")
        topCategoryLabel.textColor = .white
        topCategoryLabel.text = viewModel?.productCategory
        topTextField.text = viewModel?.productName
        if viewModel?.productImage != nil {
            addImageImage.image = viewModel?.productImage
            isImageChanged = true
        }
        isCategorySelected = true
        bottomTextField.text = viewModel?.productDescription
        userCommentText = viewModel?.userComment ?? ""
        readyToSave()
        quantityCount = viewModel?.productQuantityCount ?? 0
        
        if viewModel?.productQuantityCount == nil {
            quantityNotAvailable()
            selectUnitLabel.text = viewModel?.currentSelectedUnit.title
        } else {
            quantityLabel.text = getDecimalString()
            selectUnitLabel.text = viewModel?.productQuantityUnit
            quantityValueStep = viewModel?.productStepValue ?? 1
            quantityAvailable()
        }
    }
    
    private func setupPredictiveTextView() {
        guard FeatureManager.shared.isActivePredictiveText else {
            predictiveTextViewHeight = 0
            return
        }
        
        viewModel?.productsChangedCallback = { [weak self] titles in
            guard let self else { return }
            self.predictiveTextView.configure(texts: titles)
        }
        topTextField.autocorrectionType = .no
        topTextField.spellCheckingType = .no
        predictiveTextView.delegate = self
    }
    
    private func setupRemoveImage() {
        removeImageButton.isHidden = !isImageChanged
    }
    
    // MARK: - ButtonActions
    @objc
    private func plusButtonAction() {
        AmplitudeManager.shared.logEvent(.itemQuantityButtons)
        quantityCount += quantityValueStep
        quantityLabel.text = getDecimalString()
        setupText()
        quantityAvailable()
    }
    
    @objc
    private func minusButtonAction() {
        AmplitudeManager.shared.logEvent(.itemQuantityButtons)
        guard quantityCount > 1 else {
            return quantityNotAvailable()
        }
        quantityCount -= quantityValueStep
        quantityLabel.text = getDecimalString()
        
        setupText()
    }
    
    private func setupText() {
        let quantity = selectUnitLabel.text ?? ""
        
        let words = userCommentText.components(separatedBy: " ")
        let count = quantityCount - quantityValueStep
        let countString = String(format: "%.\(count.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", count)
        let wordsToRemove = "\(countString) \(quantity)".components(separatedBy: " ")
        let result = words.filter { !wordsToRemove.contains($0) }.joined(separator: " ")
        userCommentText = result
        
        let comma = userCommentText.last == "," ? "" : ","
        guard !userCommentText.isEmpty else {
            bottomTextField.text = "\(getDecimalString()) \(quantity) "
            return
        }
        bottomTextField.text = userCommentText + "\(comma) \(getDecimalString()) \(quantity) "
    }
    
    private func getDecimalString() -> String {
        String(format: "%.\(quantityCount.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", quantityCount)
    }
    
    private func setupBackgroundColor() {
        contentView.backgroundColor = viewModel?.getBackgroundColor()
    }
    
    // MARK: - Keyboard and swipe downAction
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(_ notification: NSNotification) {
        let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardFrame = value?.cgRectValue else { return }
        let height = Double(keyboardFrame.height)
        updateConstr(with: height, alpha: 0.5)
    }
    
    func updateConstr(with inset: Double, alpha: Double) {
        UIView.animate(withDuration: 0.3) { [ weak self ] in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(inset)
            }
            self.view.backgroundColor = .black.withAlphaComponent(alpha)
            self.view.layoutIfNeeded()
        }
    }
    
    func updatePredictiveViewConstraints(isVisible: Bool) {
        let height = isVisible ? predictiveTextViewHeight : 0
        predictiveTextView.snp.updateConstraints { $0.height.equalTo(height) }
        contentView.snp.updateConstraints { $0.height.equalTo(268 + height) }
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - swipeDown
    private func hidePanel() {
        topTextField.resignFirstResponder()
        updateConstr(with: -400, alpha: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

// MARK: - Constraints
extension OldCreateNewProductViewController {
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        selectUnitsBigView.transform = CGAffineTransform(scaleX: 1, y: 0)
        view.addSubviews([contentView, topClearView, selectUnitsBackgroundView, selectUnitsBigView])
        contentView.addSubviews([saveButtonView, topCategoryView, textfieldView, quantityTitleLabel, quantityView, minusButton, plusButton, selectUnitsView, predictiveTextView])
        selectUnitsView.addSubviews([whiteArrowForSelectUnit, selectUnitLabel])
        selectUnitsBigView.addSubviews([tableview])
        quantityView.addSubviews([quantityLabel])
        topCategoryView.addSubviews([topCategoryLabel, topCategoryPencilImage])
        textfieldView.addSubviews([checkmarkImage, topTextField, bottomTextField, addImageImage, removeImageButton])
        saveButtonView.addSubview(saveLabel)
        
        topClearView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(contentView.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-268 - predictiveTextViewHeight)
            make.height.equalTo(268 + predictiveTextViewHeight)
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
        
        removeImageButton.snp.makeConstraints { make in
            make.top.equalTo(addImageImage).offset(-8)
            make.trailing.equalTo(addImageImage).offset(8)
            make.width.height.equalTo(16)
        }
        
        quantityTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(29)
            make.top.equalTo(textfieldView.snp.bottom).inset(-15)
            make.height.equalTo(17)
        }
        
        quantityView.snp.makeConstraints { make in
            make.top.equalTo(quantityTitleLabel.snp.bottom).inset(-4)
            make.left.equalTo(minusButton.snp.left)
            make.right.equalTo(plusButton.snp.right)
            make.bottom.equalTo(plusButton.snp.bottom)
        }
        
        quantityLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        minusButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(quantityTitleLabel.snp.bottom).inset(-4)
            make.width.height.equalTo(40)
        }
        
        plusButton.snp.makeConstraints { make in
            make.left.equalTo(minusButton.snp.right).inset(-120)
            make.top.equalTo(quantityTitleLabel.snp.bottom).inset(-4)
            make.width.height.equalTo(40)
        }
        
        selectUnitsView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.top.bottom.equalTo(plusButton)
            make.width.equalTo(134)
        }
        
        whiteArrowForSelectUnit.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(17)
        }
        
        selectUnitLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.right.equalTo(whiteArrowForSelectUnit.snp.left).inset(-16)
            make.centerY.equalToSuperview()
        }
        
        selectUnitsBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectUnitsBigView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(selectUnitsView)
            make.height.equalTo(320)
        }
        
        tableview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        saveButtonView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.height.equalTo(64)
        }
        
        saveLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        predictiveTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(saveButtonView.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(predictiveTextViewHeight)
        }
    }
}
// MARK: - Textfield
extension OldCreateNewProductViewController: UITextFieldDelegate {
    
    private func setupTextFieldParametrs() {
        bottomTextField.delegate = self
        topTextField.delegate = self
        quantityLabel.delegate = self
        topTextField.becomeFirstResponder()
    }
    
    private func readyToSave() {
        saveButtonView.isUserInteractionEnabled = true
        saveButtonView.backgroundColor = UIColor(hex: "#6FB16F")
    }
    
    private func notReadyToSave() {
        saveButtonView.isUserInteractionEnabled = false
        saveButtonView.backgroundColor = UIColor(hex: "#D2D5DA")
    }
    
    private func quantityAvailable() {
        minusButton.setImage(UIImage(named: "minusActive"), for: .normal)
        plusButton.setImage(UIImage(named: "plusActive"), for: .normal)
        quantityLabel.textColor = UIColor(hex: "#31635A")
        quantityView.layer.borderColor = UIColor(hex: "#31635A").cgColor
        selectUnitsView.backgroundColor = UIColor(hex: "#31635A")
    }
    
    private func quantityNotAvailable() {
        minusButton.setImage(UIImage(named: "minusInactive"), for: .normal)
        plusButton.setImage(UIImage(named: "plusInactive"), for: .normal)
        quantityLabel.textColor = UIColor(hex: "#AEB4B2")
        quantityView.layer.borderColor = UIColor(hex: "#B8BFCC").cgColor
        selectUnitsView.backgroundColor = UIColor(hex: "#D2D5DA")
        quantityCount = 0
        quantityLabel.text = "0"
        bottomTextField.text = userCommentText
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        let finalText = string.isEmpty ? String(text.dropLast()) : text + string
        
        if textField == topTextField {
        
            if newLength > 2 && isCategorySelected {
                readyToSave()
            } else {
                notReadyToSave()
            }

            viewModel?.checkIsProductFromCategory(name: finalText)
            
            if newLength == 0 {
                notReadyToSave()
                isImageChanged = false
                addImageImage.image = UIImage(named: "#addImage")
                topCategoryView.backgroundColor = UIColor(hex: "#D2D5DA")
                topCategoryLabel.text = "Category".localized
                quantityNotAvailable()
            }
        }
        
        if textField == bottomTextField {
            userCommentText = finalText
        }
        
        if textField == quantityLabel {
            let textInDouble = finalText.replacingOccurrences(of: ",", with: ".")
           
            quantityCount = Double(textInDouble) ?? 0
            setupText()
            
            if finalText.isEmpty {
                quantityNotAvailable()
            } else {
                quantityAvailable()
            }
          
        }
        
        return newLength <= 25
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == topTextField {
            bottomTextField.becomeFirstResponder()
        } else {
            quantityAvailable()
        }

        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updatePredictiveViewConstraints(isVisible: topTextField == textField)
        guard textField == bottomTextField else {
            return
        }
        AmplitudeManager.shared.logEvent(.secondInputManual)
        let endOfDocument = textField.endOfDocument
        DispatchQueue.main.async {
            textField.selectedTextRange = textField.textRange(from: endOfDocument, to: endOfDocument)
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard textField == bottomTextField else {
            return
        }
        if (bottomTextField.text?.isEmpty ?? true) {
            userCommentText = ""
        }
    }
}

// MARK: - recognizer actions
extension OldCreateNewProductViewController {
    
    private func addRecognizers() {
        
        let tapOnAddImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnAddImageAction))
        addImageImage.addGestureRecognizer(tapOnAddImageRecognizer)
        
        let tapOnCategoryRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnCategoryAction))
        topCategoryView.addGestureRecognizer(tapOnCategoryRecognizer)
        
        let tapOnSelectUnits = UITapGestureRecognizer(target: self, action: #selector(tapOnSelectUnitsAction))
        selectUnitsView.addGestureRecognizer(tapOnSelectUnits)
     
        let tapOnSaveRecognizer = UITapGestureRecognizer(target: self, action: #selector(saveAction))
        saveButtonView.addGestureRecognizer(tapOnSaveRecognizer)
        
        let swipeDownRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(swipeDownRecognizer)
        
        let tapOnBlurViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnBlurViewAction))
        topClearView.addGestureRecognizer(tapOnBlurViewRecognizer)
        
        let tapSelectUnitsBGRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapSelectUnitsBGAction))
        selectUnitsBackgroundView.addGestureRecognizer(tapSelectUnitsBGRecognizer)
        
    }
    
    @objc
    private func tapSelectUnitsBGAction() {
        hideTableview(cell: nil)
    }
    
    @objc
    private func tapOnBlurViewAction() {
        hidePanel()
    }
    
    @objc
    private func tapOnSelectUnitsAction() {
        quantityAvailable()
        selectUnitsBackgroundView.isHidden = false
        selectUnitsBigView.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    @objc
    private func tapOnAddImageAction() {
        AmplitudeManager.shared.logEvent(.photoAdd)
        pickImage()
    }
    
    @objc
    private func tapOnCategoryAction() {
        AmplitudeManager.shared.logEvent(.categoryChange)
        viewModel?.goToSelectCategoryVC()
    }
    
    @objc
    private func saveAction() {
        guard var categoryName = topCategoryLabel.text, let productName = topTextField.text else { return }
        categoryName = categoryName == "Category".localized ? "other".localized : categoryName
        var image: UIImage?
        if isImageChanged { image = addImageImage.image }
        let description = bottomTextField.text ?? ""
        viewModel?.saveProduct(categoryName: categoryName, productName: productName, description: description,
                               image: image, isUserImage: isUserImage)
        
        hidePanel()
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
    
    @objc
    private func removeImageTapped() {
        AmplitudeManager.shared.logEvent(.photoDelete)
        addImageImage.image = R.image.addImage()
        isImageChanged = false
    }
}

extension OldCreateNewProductViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

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
        addImageImage.image = image
        isImageChanged = true
        isUserImage = true
    }
}

extension OldCreateNewProductViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableview.backgroundColor = .white
        tableview.delegate = self
        tableview.dataSource = self
        tableview.isScrollEnabled = true
        tableview.separatorStyle = .none
        tableview.register(UnitsCell.self, forCellReuseIdentifier: "UnitsCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.getNumberOfCells() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableview.dequeueReusableCell(withIdentifier: "UnitsCell", for: indexPath)
                as? UnitsCell, let viewModel = viewModel else { return UITableViewCell() }
        let title = viewModel.getTitleForCell(at: indexPath.row)
        cell.setupCell(title: title, isSelected: false, color: UIColor(hex: "#31635A"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableview.cellForRow(at: indexPath)
        cell?.isSelected = true
        AmplitudeManager.shared.logEvent(.itemUnitsButton)
        hideTableview(cell: cell)
        selectUnitLabel.text = viewModel?.getTitleForCell(at: indexPath.row)
        bottomTextField.text = ""
        viewModel?.cellSelected(at: indexPath.row)
        plusButtonAction()
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func hideTableview(cell: UITableViewCell?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.selectUnitsBigView.transform = CGAffineTransform(scaleX: 1, y: 0)
            self.selectUnitsBackgroundView.isHidden = true
            cell?.isSelected = false
        }
    }
}

extension OldCreateNewProductViewController: CreateNewProductViewModelDelegate {
    func setupController(step: Int) {
        quantityValueStep = Double(step)
        quantityCount = 0
        quantityLabel.text = "0"
    }
    
    func deselectCategory() {
        topCategoryView.backgroundColor = UIColor(hex: "#D2D5DA")
        topCategoryLabel.textColor = UIColor(hex: "#777777")
        topCategoryLabel.text = "Category".localized
        addImageImage.image = UIImage(named: "#addImage")
        isCategorySelected = false
    }
    
    func selectCategory(text: String, imageURL: String, imageData: Data?, defaultSelectedUnit: UnitSystem?) {
        topCategoryView.backgroundColor = UIColor(hex: "#80C980")
        topCategoryLabel.textColor = .white
        topCategoryLabel.text = text
        isCategorySelected = !text.isEmpty
        
        if let defaultSelectedUnit {
            selectUnitLabel.text = defaultSelectedUnit.title
        } else {
            selectUnitLabel.text = UnitSystem.piece.title
        }
        
        if isCategorySelected {
            readyToSave()
        } else {
            deselectCategory()
            notReadyToSave()
            return
        }
        
        if let imageData {
            addImageImage.image = UIImage(data: imageData)
            isImageChanged = true
            return
        }
        
        guard !imageURL.isEmpty else {
            addImageImage.image = UIImage(named: "#addImage")
            isImageChanged = false
            return
        }
        addImageImage.kf.indicatorType = .activity
        addImageImage.kf.setImage(with: URL(string: imageURL), placeholder: nil, options: nil, completionHandler: nil)
        isImageChanged = true
    }
    
    func presentController(controller: UIViewController?) {
        guard let controller else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension OldCreateNewProductViewController: PredictiveTextViewDelegate {
    func selectTitle(_ title: String) {
        AmplitudeManager.shared.logEvent(.itemPredictAdd)
        topTextField.text = title
        viewModel?.checkIsProductFromCategory(name: title)
    }
}
