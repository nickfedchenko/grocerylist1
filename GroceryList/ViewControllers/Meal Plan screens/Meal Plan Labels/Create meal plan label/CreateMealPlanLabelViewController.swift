//
//  CreateMealPlanLabelViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 20.09.2023.
//

import UIKit

class CreateMealPlanLabelViewController: UIViewController {

    var viewModel: CreateMealPlanLabelViewModel
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.lightGray()
        return view
    }()
    
    private lazy var textBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadius(8)
        return view
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.font = UIFont.SFPro.semibold(size: 17).font
        textField.textColor = .black
        return textField
    }()
    
    private lazy var crossButton: UIButton = {
        let button = UIButton()
        let color = R.color.primaryDark() ?? .black
        button.setImage(R.image.close_cross()?.withTintColor(color), for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
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
    
    private var activeColor: UIColor? {
        didSet { updateColor() }
    }
    
    init(viewModel: CreateMealPlanLabelViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        viewModel.updateColor = { [weak self] color in
            self?.activeColor = color
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.makeCustomRound(topLeft: 24, topRight: 24)
//        contentView.roundCorners(topLeft: 24, topRight: 24)
    }
    
    private func setup() {
        setupContentView()
        activeColor = viewModel.getColor(by: 0)
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
        saveButton.backgroundColor = isActive ? R.color.primaryDark() : R.color.mediumGray()
        saveButton.setTitleColor(.white.withAlphaComponent(isActive ? 1 : 0.7), for: .normal)
        saveButton.isUserInteractionEnabled = isActive
    }
    
    private func updateColor() {
        textField.tintColor = activeColor
        textField.textColor = activeColor
        textField.attributedPlaceholder = NSAttributedString(
            string: "New Label".localized,
            attributes: [.foregroundColor: activeColor ?? .gray]
        )
    }
    
    private func updateCurrentCollection() {
        guard let label = viewModel.currentLabel else {
            return
        }
        
        textField.text = label.title.localized
    }
    
    @objc
    private func saveButtonTapped() {
        viewModel.save(textField.text)
        hidePanel()
    }
    
    @objc
    private func crossButtonTapped() {
        textField.text = ""
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
        contentView.addSubviews([textBackgroundView, textField, crossButton, colorCollectionView, saveButton])
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(232)
            $0.bottom.equalToSuperview().inset(-232)
        }
        
        textBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(textBackgroundView).offset(16)
            $0.leading.equalTo(textBackgroundView).offset(16)
            $0.center.equalTo(textBackgroundView)
        }
        
        crossButton.snp.makeConstraints {
            $0.top.equalTo(textBackgroundView).offset(8)
            $0.trailing.equalTo(textBackgroundView).offset(-8)
            $0.height.width.equalTo(40)
        }
        
        colorCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalTo(saveButton.snp.top).offset(-24)
        }
        
        saveButton.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
    }
}

extension CreateMealPlanLabelViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateSaveButton(isActive: !(textField.text?.isEmpty ?? true))
    }
}

extension CreateMealPlanLabelViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.contentView) ?? false)
    }
}

extension CreateMealPlanLabelViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.getNumberOfCells()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: ColorCollectionViewCell.self, indexPath: indexPath)
        let color = viewModel.getColor(by: indexPath.row)
        cell.setupCell(listColor: color, backgroundColor: .white)
        cell.isGroceryListCell = false
        return cell
    }
}

extension CreateMealPlanLabelViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        viewModel.setColor(at: indexPath.row)
    }
}
