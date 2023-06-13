//
//  CreateNewStockViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.06.2023.
//

import UIKit

final class CreateNewStockViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private var viewModel: CreateNewStockViewModel
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.save().uppercased(), for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let contentView = ViewWithOverriddenPoint()
    private let autoRepeatView = AutoRepeatView()
    private let productView = NameOfStockView()
    private let storeView = StoreOfProductView()
    private let quantityView = QuantityOfProductView()
    private let autoRepeatSettingView = AutoRepeatSettingView()
    private var imagePicker = UIImagePickerController()
    private var isUserImage = false
    private var isShowNewStoreView = false
    private var viewDidLayout = false
    private let inactiveColor = R.color.mediumGray()
    private var unit: UnitSystem = .piece
    
    init(viewModel: CreateNewStockViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        autoRepeatView.makeCustomRound(topLeft: 4, topRight: 40, bottomLeft: 4, bottomRight: 4)
        if !viewDidLayout {
            productView.productTextField.becomeFirstResponder()
            setupCurrentProduct()
            updateStoreView(isVisible: viewModel.isVisibleStore)
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
        
        viewModel.delegate = self
        setupContentView()
        makeConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupContentView() {
        let swipeDownRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(swipeDownRecognizer)
        let tapOnAutoRepeat = UITapGestureRecognizer(target: self, action: #selector(tappedOnAutoRepeatView))
        autoRepeatView.addGestureRecognizer(tapOnAutoRepeat)
        
        setupColor()
        productView.delegate = self
        storeView.delegate = self
        quantityView.delegate = self
        autoRepeatSettingView.delegate = self
        
        if let store = viewModel.getDefaultStore() {
            storeView.setStore(store: store)
        }
        productView.setStock(isAvailability: true)
        storeView.stores = viewModel.stores
        quantityView.systemUnits = viewModel.selectedUnitSystemArray
    }
    
    private func setupColor() {
        let theme = viewModel.getTheme()

        contentView.backgroundColor = theme.light
        productView.backgroundColor = theme.light
        productView.setTintColor(theme.medium)
        productView.setStockColor(color: theme.medium)
        storeView.setupColor(backgroundColor: theme.light, tintColor: theme.medium)
        quantityView.setupColor(backgroundColor: theme.light, tintColor: theme.medium)
        autoRepeatView.backgroundColor = inactiveColor
        saveButton.backgroundColor = inactiveColor
        autoRepeatSettingView.setupColor(theme: theme)
    }
    
    /// если продукт открыт для редактирования, то заполняем поля
    private func setupCurrentProduct() {
        guard viewModel.currentStock != nil else {
            return
        }
        
        autoRepeatView.setRepeat(viewModel.autoRepeatTitle)
        updateAutoRepeatView(isActive: viewModel.isAutoRepeat)
        autoRepeatSettingView.configure(autoRepeat: viewModel.autoRepeatModel,
                                        isReminder: viewModel.isReminder)
        
        productView.productTextField.text = viewModel.productName
        productView.descriptionTextField.text = viewModel.userComment
        productView.setStock(isAvailability: viewModel.isAvailability)
        if let productImage = viewModel.productImage {
            productView.setImage(productImage)
        }
        if let quantityValue = viewModel.productQuantityCount {
            quantityView.setupCurrentQuantity(unit: viewModel.productQuantityUnit ?? .piece,
                                              value: quantityValue)
        }
        if let store = viewModel.productStore {
            storeView.setStore(store: store)
        }
        if let cost = viewModel.productCost {
            storeView.setCost(value: cost)
        }
        viewModel.setCostOfProductPerUnit()
    }
    
    private func updateSaveButton(isActive: Bool) {
        let color = isActive ? viewModel.getTheme().dark : inactiveColor
        saveButton.backgroundColor = color
        saveButton.isUserInteractionEnabled = isActive
    }
    
    private func updateAutoRepeatView(isActive: Bool) {
        let color = isActive ? viewModel.getTheme().medium : inactiveColor
        autoRepeatView.backgroundColor = color
    }
    
    @objc
    private func saveButtonTapped() {
        viewModel.saveStock(productName: productView.productTitle ?? "",
                            description: productView.descriptionTitle ?? "",
                            isAvailability: productView.isAvailability,
                            image: productView.productImage,
                            isUserImage: isUserImage,
                            store: storeView.store,
                            quantity: quantityView.quantity,
                            isAutoRepeat: autoRepeatSettingView.isAutoRepeat,
                            autoRepeatSetting: autoRepeatSettingView.notification,
                            isReminder: autoRepeatSettingView.isReminder)
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
    private func tappedOnAutoRepeatView() {
        view.endEditing(true)
        
        autoRepeatSettingView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view)
            $0.top.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }
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
    
    private func hidePanel() {
        updateConstraints(with: -500, alpha: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func updateConstraints(with inset: Double, alpha: Double) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-inset)
            }
            self.view.backgroundColor = .black.withAlphaComponent(alpha)
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateStoreView(isVisible: Bool) {
        storeView.isHidden = !isVisible
        let height = (isVisible ? 280 : 220)
        contentView.snp.updateConstraints { $0.height.greaterThanOrEqualTo(height) }
        storeView.snp.updateConstraints {
            $0.top.equalTo(productView.snp.bottom).offset(isVisible ? 20 : 0)
            $0.height.equalTo(isVisible ? 40 : 0)
        }
    }
    
    private func makeConstraints() {
        self.view.addSubview(contentView)
        contentView.addSubviews([saveButton, autoRepeatView, productView, storeView, quantityView,
                                 autoRepeatSettingView])
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(280)
            $0.bottom.equalToSuperview().offset(280)
        }
        
        autoRepeatView.snp.makeConstraints {
            $0.bottom.equalTo(contentView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        productView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(autoRepeatView.snp.bottom).offset(20)
            $0.height.equalTo(56)
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
        
        autoRepeatSettingView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view)
            $0.top.equalTo(self.view.snp.bottom)
        }
    }
}

extension CreateNewStockViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.contentView) ?? false)
    }
}

extension CreateNewStockViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        productView.setImage(image)
        isUserImage = true
    }
}

extension CreateNewStockViewController: CreateNewProductViewModelDelegate {
    func selectCategory(text: String, imageURL: String, imageData: Data?, defaultSelectedUnit: UnitSystem?) {
        productView.setImage(imageURL: imageURL, imageData: imageData)
        quantityView.setDefaultUnit(defaultSelectedUnit ?? .piece)
        
        if !imageURL.isEmpty || imageData != nil {
            isUserImage = false
        }
    }
    
    func newStore(store: Store?) {
        isShowNewStoreView = false
        storeView.stores = viewModel.stores
        if let store {
            storeView.setStore(store: store)
        }
    }
    
    func presentController(controller: UIViewController?) {
        guard let controller else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension CreateNewStockViewController: CategoryViewDelegate {
    func categoryTapped() { }
}

extension CreateNewStockViewController: NameOfProductViewDelegate {
    func enterProductName(name: String?) {
        guard let name else { return }
        updateSaveButton(isActive: name.count >= 1)
        viewModel.checkIsProductFromCategory(name: name)
        
        if name.count == 0 {
            productView.reset()
            storeView.reset()
            quantityView.reset()
        }
    }
    
    func isFirstResponderProductTextField(_ flag: Bool) { }
    
    func tappedAddImage() {
        pickImage()
    }
}

extension CreateNewStockViewController: StoreOfProductViewDelegate {
    func tappedNewStore() {
        updateConstraints(with: -500, alpha: 0)
        isShowNewStoreView = true
        viewModel.goToCreateNewStore()
    }
    
    func updateCost(_ cost: Double?) {
        guard let cost, quantityView.quantity > 0 else {
            viewModel.costOfProductPerUnit = cost
            return
        }
        viewModel.costOfProductPerUnit = cost / quantityView.quantity
    }
}

extension CreateNewStockViewController: QuantityOfProductViewDelegate {
    func unitSelected(_ unit: UnitSystem) {
        self.unit = unit
    }
    
    func updateQuantityValue(_ quantity: Double) {
        let quantityString = String(format: "%.\(quantity.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", quantity)
        productView.setQuantity(quantity > 0 ? "\(quantityString) \(unit.title)" : "")
    }
    
    func tappedMinusPlusButtons(_ quantity: Double) {
        guard let costOfProductPerUnit = viewModel.costOfProductPerUnit else {
            return
        }
        let cost = quantity * costOfProductPerUnit
        storeView.setCost(value: "\(cost)")
    }
}

extension CreateNewStockViewController: AutoRepeatSettingViewDelegate {
    func tappedDone() {
        productView.productTextField.becomeFirstResponder()
        
        autoRepeatSettingView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view)
            $0.top.equalTo(self.view.snp.bottom)
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }
    }
    
    func changeRepeat(_ autoRepeat: String?) {
        updateAutoRepeatView(isActive: autoRepeat != nil)
        guard let autoRepeat else {
            return
        }
        autoRepeatView.setRepeat(autoRepeat)
    }
}
