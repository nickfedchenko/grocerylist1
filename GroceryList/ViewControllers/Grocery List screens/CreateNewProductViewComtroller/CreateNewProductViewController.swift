//
//  CreateNewProductViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.04.2023.
//

import UIKit

class CreateNewProductViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    var viewModel: CreateNewProductViewModel?
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.save().uppercased(), for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    let contentView = ViewWithOverriddenPoint()
    let categoryView = CategoryView()
    let productView = NameOfProductView()
    let storeView = StoreOfProductView()
    let quantityView = QuantityOfProductView()
    let predictiveTextView = PredictiveTextView()
    let autoCategoryView = AutoCategoryInfoView()
    var imagePicker = UIImagePickerController()
    let originPredictiveTextViewHeight = 86
    var predictiveTextViewHeight = 86
    var contentViewHeight = 280
    var isUserImage = false
    var isShowNewStoreView = false
    var viewDidLayout = false
    let inactiveColor = R.color.mediumGray() ?? UIColor(hex: "#ACB4B4")
    var unit: UnitSystem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoryView.makeCustomRound(topLeft: 4, topRight: 40, bottomLeft: 4, bottomRight: 4)
        if !viewDidLayout {
            productView.productTextView.becomeFirstResponder()
            setupCurrentProduct()
            updateStoreView(isVisible: viewModel?.isVisibleStore ?? true)
            viewDidLayout.toggle()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        guard let location = touch?.location(in: self.contentView) else { return }
        if !storeView.shortView.frame.contains(location) {
            storeView.tappedOutsideCostView()
        }
    }
    
    private func setup() {
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        tapOnView.delegate = self
        self.view.addGestureRecognizer(tapOnView)
        
        viewModel?.delegate = self
        setupContentView()
        makeConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupContentView() {
        let swipeDownRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(swipeDownRecognizer)
        let tapOnCategoryRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOnCategoryView))
        categoryView.addGestureRecognizer(tapOnCategoryRecognizer)
        
        setupColor()
        setupPredictiveTextView()
        setupAutoCategoryView()
        categoryView.delegate = self
        productView.delegate = self
        storeView.delegate = self
        quantityView.delegate = self
        
        if let store = viewModel?.getDefaultStore() {
            storeView.setStore(store: store)
        }
        storeView.stores = viewModel?.stores ?? []
        quantityView.systemUnits = viewModel?.selectedUnitSystemArray ?? []
    }
    
    func setupColor() {
        let colorForForeground = viewModel?.getColorForForeground ?? .black
        let colorForBackground = viewModel?.getColorForBackground ?? .white
        
        contentView.backgroundColor = colorForBackground
        productView.backgroundColor = colorForBackground
        productView.setTintColor(colorForForeground)
        storeView.setupColor(backgroundColor: colorForBackground, tintColor: colorForForeground)
        quantityView.setupColor(backgroundColor: colorForBackground, tintColor: colorForForeground)
        categoryView.setupColor(viewColor: inactiveColor, buttonTintColor: .white)
        saveButton.backgroundColor = inactiveColor
    }
    
    /// устанавливаем предиктивный ввод
    func setupPredictiveTextView() {
        viewModel?.productsChangedCallback = { [weak self] titles in
            guard let self else { return }
            self.predictiveTextView.configure(texts: titles)
        }
        productView.productTextView.autocorrectionType = .no
        productView.productTextView.spellCheckingType = .no
        predictiveTextView.delegate = self
    }
    
    /// устанавливаем автокатегорию
    func setupAutoCategoryView() {
        guard FeatureManager.shared.isActiveAutoCategory != nil else {
            autoCategoryView.isHidden = true
            return
        }
        
        guard !UIDevice.isSEorXor12mini else {
            autoCategoryView.isHidden = true
            if UserDefaultsManager.countInfoMessage < 10 {
                viewModel?.showAutoCategoryAlert()
            }
            return
        }
        
        autoCategoryView.isHidden = UserDefaultsManager.countInfoMessage >= 10
        autoCategoryView.tappedOk = { [weak self] in
            UserDefaultsManager.countInfoMessage = 11
            self?.autoCategoryHideTap()
        }
        autoCategoryView.tappedOnView = { [weak self] in
            self?.autoCategoryHideTap()
        }
    }
    
    private func autoCategoryHideTap() {
        guard !autoCategoryView.isHidden else {
            return
        }
        
        UserDefaultsManager.countInfoMessage += 1
        autoCategoryView.fadeOut()
    }
    
    /// если продукт открыт для редактирования, то заполняем поля
    func setupCurrentProduct() {
        guard viewModel?.currentProduct != nil else {
            return
        }
        
        let colorForForeground = viewModel?.getColorForForeground ?? .black
        updateCategory(isActive: !(viewModel?.productCategory?.isEmpty ?? true), categoryTitle: viewModel?.productCategory)
        productView.productTextView.text = viewModel?.productName
        productView.descriptionTextField.text = viewModel?.userComment
        productView.productTextView.checkPlaceholder()
        if let productImage = viewModel?.productImage {
            productView.setImage(productImage)
        }
        if let quantityValue = viewModel?.productQuantityCount {
            quantityView.setupCurrentQuantity(unit: viewModel?.productQuantityUnit,
                                              value: quantityValue)
        }
        if let store = viewModel?.productStore {
            storeView.setStore(store: store)
        }
        if let cost = viewModel?.productCost {
            storeView.setCost(value: cost)
        }
        viewModel?.setCostOfProductPerUnit()
        updateSaveButton(isActive: productView.productTextView.text.count >= 1)
    }
    
    func updateCategory(isActive: Bool, categoryTitle: String?) {
        let colorForForeground = viewModel?.getColorForForeground ?? UIColor(hex: "#278337")
        let color = isActive ? colorForForeground : inactiveColor
        let title = isActive ? categoryTitle : R.string.localizable.category()
        categoryView.setCategoryInProduct(title, backgroundColor: color)
    }
    
    private func updateSaveButton(isActive: Bool) {
        let color = isActive ? viewModel?.getColorForForeground : inactiveColor
        saveButton.backgroundColor = color
        saveButton.isUserInteractionEnabled = isActive
    }
    
    @objc
    func saveButtonTapped() {
        viewModel?.saveProduct(categoryName: categoryView.categoryTitle ?? R.string.localizable.other(),
                               productName: productView.productTitle ?? "",
                               description: productView.descriptionTitle ?? "",
                               image: productView.productImage,
                               isUserImage: isUserImage,
                               store: storeView.store, quantity: quantityView.quantity)
        hidePanel()
    }
    
    @objc
    private func tappedOnView() {
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
    private func tappedOnCategoryView() {
        AmplitudeManager.shared.logEvent(.categoryChange)
        viewModel?.goToSelectCategoryVC()
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        guard !isShowNewStoreView else { return }
        let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardFrame = value?.cgRectValue else { return }
        let height = Double(keyboardFrame.height)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateConstraints(with: height, alpha: 0.2)
        }
    }
    
    func hidePanel() {
        updateConstraints(with: -500, alpha: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func updateConstraints(with inset: Double, alpha: Double) {
        contentView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(contentViewHeight + predictiveTextViewHeight)
            $0.bottom.equalToSuperview().offset(-inset)
        }
        
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self else { return }
            self.view.backgroundColor = .black.withAlphaComponent(alpha)
            self.view.layoutIfNeeded()
        }
    }
    
    private func updatePredictiveViewConstraints(isVisible: Bool) {
        predictiveTextViewHeight = isVisible ? originPredictiveTextViewHeight : 0
        predictiveTextView.snp.updateConstraints { $0.height.equalTo(predictiveTextViewHeight) }
        contentView.snp.updateConstraints { $0.height.greaterThanOrEqualTo(contentViewHeight + predictiveTextViewHeight) }
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }
    }
    
    func updateStoreView(isVisible: Bool) {
        storeView.isHidden = !isVisible
        contentViewHeight = isVisible ? 280 : 220
        let height = contentViewHeight + predictiveTextViewHeight
        contentView.snp.updateConstraints { $0.height.greaterThanOrEqualTo(height) }
        storeView.snp.updateConstraints {
            $0.top.equalTo(productView.snp.bottom).offset(isVisible ? 20 : 0)
            $0.height.equalTo(isVisible ? 40 : 0)
        }
    }
    
    func applyPredictiveInput(_ title: String) {
        AmplitudeManager.shared.logEvent(.itemPredictAdd)
        productView.productTextView.text = title
        viewModel?.checkIsProductFromCategory(name: title)
    }
    
    func updateQuantity(_ quantity: Double) {
        let quantityString = String(format: "%.\(quantity.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", quantity)
        productView.setQuantity(quantity > 0 ? "\(quantityString) \(unit?.title ?? "")" : "")
    }
    
    func tappedQuantityButtons(_ quantity: Double) {
        guard let costOfProductPerUnit = viewModel?.costOfProductPerUnit else {
            return
        }
        let cost = quantity * costOfProductPerUnit
        storeView.setCost(value: "\(cost)")
    }
    
    func updateProductView(text: String, imageURL: String, imageData: Data?, defaultSelectedUnit: UnitSystem?) {
        updateCategory(isActive: !text.isEmpty, categoryTitle: text)
        productView.setImage(imageURL: imageURL, imageData: imageData)
        quantityView.setDefaultUnit(defaultSelectedUnit)
        
        if !imageURL.isEmpty || imageData != nil {
            isUserImage = false
        }
    }
    
    func setupUserImage(_ image: UIImage?) {
        productView.setImage(image)
        isUserImage = true
    }
    
    func makeConstraints() {
        self.view.addSubviews([contentView, autoCategoryView])
        contentView.addSubviews([saveButton, categoryView, productView, storeView, quantityView,
                                 predictiveTextView])
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(contentViewHeight + predictiveTextViewHeight)
            $0.bottom.equalToSuperview().offset(contentViewHeight + predictiveTextViewHeight)
        }
        
        categoryView.snp.makeConstraints {
            $0.bottom.equalTo(contentView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        productView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(categoryView.snp.bottom).offset(20)
            $0.height.greaterThanOrEqualTo(56)
        }
        
        storeView.snp.makeConstraints {
            $0.top.equalTo(productView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        quantityView.snp.makeConstraints {
            $0.top.equalTo(storeView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(quantityView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        makeFeatureConstraints()
    }
    
    private func makeFeatureConstraints() {
        predictiveTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(saveButton.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(predictiveTextViewHeight)
        }
        
        autoCategoryView.snp.makeConstraints {
            $0.bottom.equalTo(categoryView.snp.top).offset(4)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(335)
            $0.height.equalTo(162)
        }
    }
}

extension CreateNewProductViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.contentView) ?? false)
    }
}

extension CreateNewProductViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func pickImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .pageSheet
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        setupUserImage(image)
    }
}

extension CreateNewProductViewController: CreateNewProductViewModelDelegate {
    func selectCategory(text: String, imageURL: String, imageData: Data?, defaultSelectedUnit: UnitSystem?) {
        updateProductView(text: text, imageURL: imageURL, imageData: imageData,
                          defaultSelectedUnit: defaultSelectedUnit)
    }
    
    func newStore(store: Store?) {
        isShowNewStoreView = false
        storeView.stores = viewModel?.stores ?? []
        if let store {
            storeView.setStore(store: store)
        }
    }
    
    func presentController(controller: UIViewController?) {
        guard let controller else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func showKeyboard() {
        productView.productTextView.becomeFirstResponder()
    }
}

extension CreateNewProductViewController: CategoryViewDelegate {
    func categoryTapped() {
        autoCategoryHideTap()
        tappedOnCategoryView()
    }
}

extension CreateNewProductViewController: PredictiveTextViewDelegate {
    func selectTitle(_ title: String) {
        applyPredictiveInput(title)
    }
}

extension CreateNewProductViewController: NameOfProductViewDelegate {
    func enterProductName(name: String?) {
        guard let name else { return }
        updateSaveButton(isActive: name.count >= 1)
        viewModel?.checkIsProductFromCategory(name: name)
        
        if name.count == 0 {
            updateCategory(isActive: false, categoryTitle: "")
            productView.reset()
            storeView.reset()
            quantityView.reset()
        }
    }
    
    func isFirstResponderProductTextField(_ flag: Bool) {
        updatePredictiveViewConstraints(isVisible: flag)
    }
    
    func tappedAddImage() {
        pickImage()
    }
}

extension CreateNewProductViewController: StoreOfProductViewDelegate {
    func tappedNewStore() {
        updateConstraints(with: -500, alpha: 0)
        isShowNewStoreView = true
        viewModel?.goToCreateNewStore()
    }
    
    func updateCost(_ cost: Double?) {
        guard let cost, quantityView.quantity > 0 else {
            viewModel?.costOfProductPerUnit = cost
            return
        }
        viewModel?.costOfProductPerUnit = cost / quantityView.quantity
    }
}

extension CreateNewProductViewController: QuantityOfProductViewDelegate {
    func unitSelected(_ unit: UnitSystem?) {
        self.unit = unit
        viewModel?.setUnit(unit)
        updateQuantity(quantityView.quantity)
    }
    
    func updateQuantityValue(_ quantity: Double) {
        updateQuantity(quantity)
    }
    
    func tappedMinusPlusButtons(_ quantity: Double) {
        tappedQuantityButtons(quantity)
    }
}
