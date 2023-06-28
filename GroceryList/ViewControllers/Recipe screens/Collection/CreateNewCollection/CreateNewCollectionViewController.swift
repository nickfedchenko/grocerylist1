//
//  CreateNewCollectionViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import UIKit

final class CreateNewCollectionViewController: UIViewController {

    var viewModel: CreateNewCollectionViewModel?
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E5F5F3")
        return view
    }()
    
    private lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.mediumGray()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 16).font
        label.textColor = .white
        label.text = R.string.localizable.createCollection()
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.font = UIFont.SFPro.semibold(size: 17).font
        textField.textColor = .black
        return textField
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.menuFolder()
        return imageView
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
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.save().uppercased(), for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var activeColor: Theme? {
        didSet { updateColor() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        viewModel?.updateColor = { [weak self] theme in
            self?.activeColor = theme
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.makeCustomRound(topLeft: 4, topRight: 40, bottomLeft: 0, bottomRight: 0)
    }
    
    private func setup() {
        setupContentView()
        activeColor = viewModel?.getColor(by: 0)
        updateSaveButton(isActive: false)
        updateCurrentCollection()
        makeConstraints()
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(hidePanel))
        tapOnView.delegate = self
        self.view.addGestureRecognizer(tapOnView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupContentView() {
        let swipeDownRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(swipeDownRecognizer)
        textField.becomeFirstResponder()
    }
    
    private func updateSaveButton(isActive: Bool) {
        saveButton.backgroundColor = isActive ? activeColor?.medium : R.color.mediumGray()
        saveButton.setTitleColor(.white.withAlphaComponent(isActive ? 1 : 0.7), for: .normal)
        saveButton.isUserInteractionEnabled = isActive
    }
    
    private func updateColor() {
        textField.tintColor = activeColor?.dark
        iconImageView.image = R.image.menuFolder()?.withTintColor(activeColor?.dark ?? .black)
        let isActive = !(textField.text?.isEmpty ?? true)
        saveButton.backgroundColor = isActive ? activeColor?.medium : R.color.mediumGray()
    }
    
    private func updateCurrentCollection() {
        guard let collection = viewModel?.currentCollection else {
            return
        }
        
        activeColor = viewModel?.getColor(by: collection.color)
        colorCollectionView.selectItem(at: IndexPath(row: collection.color, section: 0),
                                       animated: false, scrollPosition: .left)
        textField.text = collection.title
    }
    
    @objc
    private func saveButtonTapped() {
        viewModel?.save(textField.text)
        hidePanel()
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardFrame = value?.cgRectValue else { return }
        let height = Double(keyboardFrame.height)
        updateConstraints(with: height, alpha: 0.2)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
    
    @objc
    private func hidePanel() {
        textField.resignFirstResponder()
        updateConstraints(with: -400, alpha: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func updateConstraints(with inset: Double, alpha: Double) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints {
                $0.bottom.equalToSuperview().inset(inset)
            }
            self.view.backgroundColor = .black.withAlphaComponent(alpha)
            self.view.layoutIfNeeded()
        }
    }
    
    private func makeConstraints() {
        self.view.addSubview(contentView)
        contentView.addSubviews([titleView, iconImageView, textField, colorCollectionView, saveButton])
        titleView.addSubview(titleLabel)
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(251)
            $0.bottom.equalToSuperview().inset(-251)
        }
        
        titleView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(17)
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(40)
            $0.bottom.equalTo(colorCollectionView.snp.top).offset(-12)
        }
        
        textField.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(6)
            $0.height.equalTo(20)
        }
        
        colorCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalTo(saveButton.snp.top).offset(-25)
        }
        
        saveButton.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
    }
}

extension CreateNewCollectionViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateSaveButton(isActive: !(textField.text?.isEmpty ?? true))
    }
}

extension CreateNewCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.contentView) ?? false)
    }
}

extension CreateNewCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel?.getNumberOfCells() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: ColorCollectionViewCell.self, indexPath: indexPath)
        let theme = viewModel?.getColor(by: indexPath.row)
        cell.setupCell(listColor: theme?.medium ?? .white, backgroundColor: theme?.light ?? .white)
        cell.isGroceryListCell = false
        return cell
    }
}

extension CreateNewCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        viewModel?.setColor(at: indexPath.row)
    }
}
