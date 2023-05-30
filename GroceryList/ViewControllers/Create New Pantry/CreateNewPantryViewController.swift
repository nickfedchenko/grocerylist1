//
//  CreateNewPantryViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 25.05.2023.
//

import UIKit

class CreateNewPantryViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    private var viewModel: CreateNewPantryViewModel
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerCurve = .continuous
        view.addCustomShadow(radius: 11, offset: CGSize(width: 0, height: -12))
        return view
    }()
    
    private lazy var nameView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let textfield = UITextField()
        textfield.delegate = self
        textfield.font = UIFont.SFPro.semibold(size: 20).font
        textfield.textColor = .white
        textfield.tintColor = .white
        textfield.keyboardAppearance = .light
        textfield.attributedPlaceholder = NSAttributedString(
            string: " " + R.string.localizable.listName(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        return textfield
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(classCell: ColorCollectionViewCell.self)
        collectionView.contentInset.left = 20
        collectionView.selectItem(at: IndexPath(row: 0, section: 0),
                                  animated: false, scrollPosition: .left)
        return collectionView
    }()
    
    private let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 16).font
        label.text = R.string.localizable.synchronizeStockList()
        label.numberOfLines = 0
        return label
    }()
    
    private let infoDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 14).font
        label.text = R.string.localizable.foodAutomaticallyAppear()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        return label
    }()
    
    private let synchronizeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.pantry_synchronize()
        return imageView
    }()
    
    private let selectListButton: UIButton = {
        var button = UIButton()
        button.setTitle(R.string.localizable.selectList(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.layer.borderWidth = 1
        button.contentEdgeInsets.left = 10
        button.contentEdgeInsets.right = 10
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = R.color.mediumGray()
        button.setTitle(R.string.localizable.save().uppercased(), for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let templateView = PantryListTemplateView()
    private let iconView = IconSubView()
    private let sharingView = SharingView()
    
    init(viewModel: CreateNewPantryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        nameTextField.becomeFirstResponder()
        
        setupTemplates()
        updateColor()
        makeConstraints()
        
        addRecognizer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupTemplates() {
        templateView.delegate = self
        templateView.configure(templates: viewModel.getPantryTemplates())
    }
    
    private func updateSaveButton(isActive: Bool) {
        guard isActive != saveButton.isUserInteractionEnabled else {
            return
        }
        let color = isActive ? viewModel.selectedTheme.dark : R.color.mediumGray()
        saveButton.backgroundColor = color
        saveButton.isUserInteractionEnabled = isActive
    }
    
    private func addRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(panRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnIconView))
        iconView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc
    private func saveButtonTapped() {
        viewModel.savePantryList(name: nameTextField.text,
                                 icon: iconView.icon,
                                 synchronizedLists: [])
        hidePanel()
    }

    @objc
    private func keyboardWillShow(_ notification: NSNotification) {
        let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardFrame = value?.cgRectValue else {
            return
        }
        let height = Double(keyboardFrame.height)
        updateBottomConstraint(view: contentView, with: -height)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
    
    @objc
    private func tapOnIconView() {
        viewModel.showAllIcons(by: self, icon: iconView.icon)
    }
    
    private func updateBottomConstraint(view: UIView, with offset: Double) {
        view.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(offset)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    private func hidePanel() {
        nameTextField.resignFirstResponder()
        updateBottomConstraint(view: contentView, with: 400)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func makeConstraints() {
        self.view.addSubviews([templateView, contentView])
        contentView.addSubviews([nameView, colorCollectionView, infoTitleLabel, infoDescriptionLabel,
                                 synchronizeImageView, selectListButton, saveButton])
        nameView.addSubviews([iconView, nameTextField, sharingView])
        
        templateView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(contentView.snp.top).offset(50)
        }
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(364)
            $0.height.equalTo(364)
        }
        
        makeNameViewConstraints()
        
        colorCollectionView.snp.makeConstraints {
            $0.top.equalTo(nameView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        makeSynchronizeBlockConstraints()
        
        saveButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(64)
        }
    }
    
    private func makeNameViewConstraints() {
        nameView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        iconView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(8)
            $0.height.width.equalTo(40)
        }
        
        nameTextField.snp.makeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(10)
            $0.center.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        sharingView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-12)
            $0.trailing.bottom.equalToSuperview().offset(-12)
        }
    }
    
    private func makeSynchronizeBlockConstraints() {
        infoTitleLabel.snp.makeConstraints {
            $0.top.equalTo(colorCollectionView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(42)
            $0.centerX.equalToSuperview()
        }
        
        infoDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(infoTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(infoTitleLabel)
            $0.height.equalTo(34)
        }
        
        synchronizeImageView.snp.makeConstraints {
            $0.centerY.equalTo(selectListButton)
            $0.leading.equalTo(infoTitleLabel)
            $0.width.equalTo(112)
            $0.height.equalTo(32)
        }
        
        selectListButton.snp.makeConstraints {
            $0.top.equalTo(infoDescriptionLabel.snp.bottom).offset(8)
            $0.trailing.equalTo(infoTitleLabel)
            $0.height.equalTo(39)
        }
    }
}

extension CreateNewPantryViewController: CreateNewPantryViewModelDelegate {
    func updateColor() {
        let theme = viewModel.selectedTheme
        contentView.backgroundColor = theme.light
        templateView.configure(backgroundColor: theme.dark)
        nameView.backgroundColor = theme.medium
        infoTitleLabel.textColor = theme.dark
        infoDescriptionLabel.textColor = theme.dark
        iconView.configure(color: theme)
        selectListButton.layer.borderColor = theme.medium.cgColor
        selectListButton.setTitleColor(theme.dark, for: .normal)
        synchronizeImageView.image = R.image.pantry_synchronize()?.withTintColor(theme.medium)
    }
    
    func selectedIcon(_ icon: UIImage?) {
        iconView.configure(icon: icon)
    }
}

extension CreateNewPantryViewController: PantryListTemplateViewDelegate {
    func selectTemplate(_ index: Int) {
        let template = viewModel.selectedTemplate(by: index)
        iconView.configure(icon: template.icon, name: template.title)
        nameTextField.text = template.title
    }
}

extension CreateNewPantryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return (textField.text?.count ?? 0) <= 30
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let name = textField.text else {
            iconView.configure(icon: nil, name: "")
            return
        }
        updateSaveButton(isActive: name.count >= 1)
        iconView.configure(icon: nil, name: name)
    }
}

extension CreateNewPantryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.getNumberOfCells()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: ColorCollectionViewCell.self, indexPath: indexPath)
        let textFieldColor = viewModel.getMediumColor(by: indexPath.row)
        let backgroundColor = viewModel.getLightColor(by: indexPath.row)
        cell.setupCell(listColor: textFieldColor, backgroundColor: backgroundColor)
        cell.isGroceryListCell = false
        return cell
    }
}

extension CreateNewPantryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        viewModel.setColor(at: indexPath.row)
    }
}

extension CreateNewPantryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
