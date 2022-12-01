//
//  CreateNewProductViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 25.11.2022.
//

import SnapKit
import UIKit

class CreateNewProductViewController: UIViewController {
    
    var viewModel: CreateNewProductViewModel?
    private var imagePicker = UIImagePickerController()
    private var isCategorySelected = false
    private var quantityCount = 0
    private var isImageChanged = false

    private var quantityValueStep: Int = 1
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        addKeyboardNotifications()
        setupBackgroundColor()
        addRecognizers()
        setupTableView()
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
    
    @objc
    private func plusButtonAction() {
        quantityCount += quantityValueStep
        quantityLabel.text = String(quantityCount)
        let quantity = selectUnitLabel.text ?? ""
        bottomTextField.text = "\(quantityCount) \(quantity)"
        quantityAvailable()
    }

    @objc
    private func minusButtonAction() {
        guard quantityCount > 1 else { return quantityNotAvailable() }
        quantityCount -= quantityValueStep
        quantityLabel.text = String(quantityCount)
        let quantity = selectUnitLabel.text ?? ""
        bottomTextField.text = "\(quantityCount) \(quantity)"
    }
    
    private func setupTextFieldParametrs() {
        bottomTextField.delegate = self
        topTextField.delegate = self
        topTextField.becomeFirstResponder()
    }
    
    private func setupBackgroundColor() {
        contentView.backgroundColor = viewModel?.getBackgroundColor()
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
    
    // MARK: - swipeDown
    
    private func hidePanel() {
        topTextField.resignFirstResponder()
        updateConstr(with: -400, alpha: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - UI
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
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = UIColor(hex: "#AEB4B2")
        label.text = "0"
        return label
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
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        selectUnitsBigView.transform = CGAffineTransform(scaleX: 1, y: 0)
        view.addSubviews([contentView, selectUnitsBigView])
        contentView.addSubviews([saveButtonView, topCategoryView, textfieldView, quantityTitleLabel, quantityView, minusButton, plusButton, selectUnitsView])
        selectUnitsView.addSubviews([whiteArrowForSelectUnit, selectUnitLabel])
        selectUnitsBigView.addSubviews([tableview])
        quantityView.addSubviews([quantityLabel])
        topCategoryView.addSubviews([topCategoryLabel, topCategoryPencilImage])
        textfieldView.addSubviews([checkmarkImage, topTextField, bottomTextField, addImageImage])
        saveButtonView.addSubview(saveLabel)
        
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-268)
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
        
        selectUnitsBigView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(selectUnitsView)
            make.height.equalTo(320)
        }
        
        tableview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        quantityLabel.text = String(quantityCount)
        bottomTextField.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        if textField == topTextField {
        
            if newLength > 2 && isCategorySelected {
                readyToSave()
            } else {
                notReadyToSave()
            }
            
            if string.isEmpty {
                viewModel?.chekIsProductFromCategory(name: String(text.dropLast()))
            } else {
                viewModel?.chekIsProductFromCategory(name: text + string)
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
}

// MARK: - recognizer actions
extension CreateNewProductViewController {
    
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
        
    }
    
    @objc
    private func tapOnSelectUnitsAction() {
        quantityAvailable()
        selectUnitsBigView.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    @objc
    private func tapOnAddImageAction() {
        pickImage()
    }
    
    @objc
    private func tapOnCategoryAction() {
        viewModel?.goToSelectCategoryVC()
    }
    
    @objc
    private func saveAction() {
        guard var categoryName = topCategoryLabel.text, let productName = topTextField.text else { return }
        categoryName = categoryName == "Category".localized ? "other".localized : categoryName
        var image: UIImage?
        if isImageChanged { image = addImageImage.image }
        let description = bottomTextField.text ?? ""
        viewModel?.saveProduct(categoryName: categoryName, productName: productName, image: image, description: description)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        addImageImage.image = image
        isImageChanged = true
    }
}

extension CreateNewProductViewController: UITableViewDelegate, UITableViewDataSource {
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
        cell.setupCell(title: title, isSelected: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableview.cellForRow(at: indexPath)
        cell?.isSelected = true
        hideTableview(cell: cell)
        selectUnitLabel.text = viewModel?.getTitleForCell(at: indexPath.row)
        bottomTextField.text = ""
        viewModel?.cellSelected(at: indexPath.row)
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func hideTableview(cell: UITableViewCell?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.selectUnitsBigView.transform = CGAffineTransform(scaleX: 1, y: 0)
            cell?.isSelected = false
        }
    }
}

extension CreateNewProductViewController: CreateNewProductViewModelDelegate {
    func setupController(step: Int) {
        quantityValueStep = step
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
    
    func selectCategory(text: String, imageURL: String, preferedUint: String) {
        topCategoryView.backgroundColor = UIColor(hex: "#80C980")
        topCategoryLabel.textColor = .white
        topCategoryLabel.text = text
        isCategorySelected = true
        
        let text = topTextField.text ?? ""
        if text.count > 2 && isCategorySelected {
            readyToSave()
        }
        
        if !preferedUint.isEmpty {
            selectUnitLabel.text = preferedUint
        }
        guard !imageURL.isEmpty else { return }
        addImageImage.kf.indicatorType = .activity
        addImageImage.kf.setImage(with: URL(string: imageURL), placeholder: nil, options: nil, completionHandler: nil)
        isImageChanged = true
    }
    
    func presentController(controller: UIViewController?) {
        guard let controller else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
}
