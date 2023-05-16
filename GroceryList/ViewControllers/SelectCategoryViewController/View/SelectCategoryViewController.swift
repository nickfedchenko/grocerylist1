//
//  SelectCategoryViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.11.2022.
//

import SnapKit
import UIKit

class SelectCategoryViewController: UIViewController {
    
    var viewModel: SelectCategoryViewModel?
    private var searchViewHeight = 96.0
    
    // MARK: - UI
    private let navigationView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var arrowBackButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(arrowBackButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "greenArrowBack"), for: .normal)
        return button
    }()
    
    private let titleCenterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.text = "SelectCategory".localized
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "greenPlus"), for: .normal)
        return button
    }()
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .vertical
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let searchView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.addShadowForView(radius: 5, height: -2)
        return view
    }()
    
    private let textfieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.addShadowForView()
        return view
    }()
    
    private let pinchView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#000000")
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    private let searchImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "greenLoopImage")
        return imageView
    }()
    
    private let textField: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont.SFPro.medium(size: 16).font
        textfield.textColor = .black
        textfield.backgroundColor = .white
        textfield.keyboardAppearance = .light
        textfield.spellCheckingType = .no
        textfield.autocorrectionType = .no
        textfield.attributedPlaceholder = NSAttributedString(
            string: "SearcInCategory".localized,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "#657674")]
        )
        return textfield
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupController()
        setupCollectionView()
        setupTextFieldParametrs()
        addRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardNotifications()
    }
    
    deinit {
        print("select category deinited ")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    // MARK: - Functions
    private func setupController() {
        view.backgroundColor = viewModel?.getBackgroundColor()
        navigationView.backgroundColor = viewModel?.getBackgroundColor().withAlphaComponent(0.9)
        searchView.backgroundColor = R.color.lightGray()
        titleCenterLabel.textColor = viewModel?.getForegroundColor()
    }
    
    @objc
    private func arrowBackButtonPressed() {
        viewModel?.goBackButtonPressed()
    }
    
    @objc
    private func addButtonPressed() {
        viewModel?.addNewCategoryTapped()
    }
    
    private func setupTextFieldParametrs() {
        textField.delegate = self
    }
    
    // MARK: - Keyboard
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(_ notification: NSNotification) {
        let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardFrame = value?.cgRectValue else { return }
        let height = Double(keyboardFrame.height)
        updateConstr(with: height)
    }
    
    @objc
    private func keyboardWillHide(_ notification: NSNotification) {
        updateConstr(with: 0)
    }
    
    func updateConstr(with inset: Double) {
        UIView.animate(withDuration: 0.1) { [ weak self ] in
            guard let self = self else { return }
            self.searchView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(inset)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Recognizer
    private func addRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        searchView.addGestureRecognizer(panRecognizer)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        
        let tempTranslation = recognizer.translation(in: searchView)
        if tempTranslation.y >= 100 {
            textField.resignFirstResponder()
        }
        
        if tempTranslation.y <= -100 {
            textField.becomeFirstResponder()
        }
       
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        view.addSubviews([collectionView, navigationView, searchView])
        navigationView.addSubviews([arrowBackButton, titleCenterLabel, addButton])
        searchView.addSubviews([textfieldView, pinchView])
        textfieldView.addSubviews([searchImage, textField])
        
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.right.left.equalToSuperview()
            make.height.equalTo(66)
        }
        
        arrowBackButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        titleCenterLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(26)
            make.width.equalTo(44)
            make.height.equalTo(44)
            make.centerY.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(searchView.snp.bottom)
            make.top.equalTo(navigationView.snp.top)
        }
        
        searchView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(0)
            make.height.equalTo(searchViewHeight)
        }
        
        textfieldView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        searchImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(7)
            make.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(26)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(searchImage.snp.right).inset(-7)
            make.top.bottom.equalToSuperview().inset(8)
            make.right.equalToSuperview().inset(8)
        }
        
        pinchView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(5)
        }
    }
}

// MARK: - Textfield
extension SelectCategoryViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        if string.isEmpty {
            viewModel?.searchByWord(word: String(text.dropLast()))
        } else {
            viewModel?.searchByWord(word: text + string)
        }
        return newLength <= 25
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - CollcetionView
extension SelectCategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(SelectCategoryCell.self, forCellWithReuseIdentifier: "SelectCategoryCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.getNumberOfCells() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectCategoryCell",
            for: indexPath) as? SelectCategoryCell, let viewModel = viewModel else { return UICollectionViewCell() }
        let backgroundColor = viewModel.getBackgroundColor()
        let foregroundColor = viewModel.getForegroundColor()
        let title = viewModel.getTitleText(at: indexPath.row)
        let isSelected = viewModel.isCellSelected(at: indexPath.row)
        cell.setupCell(title: title, isSelected: isSelected, foregroundColor: foregroundColor, lineColor: backgroundColor)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 66, left: 0, bottom: 96, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.selectCell(at: indexPath.row)
        let selectedCategoryName = viewModel?.getTitleText(at: indexPath.row)
        
        viewModel?.categorySelected(with: selectedCategoryName)
    }
    
    func updateCollectionContentInset() {
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        var contentInsetTop = collectionView.bounds.size.height

            contentInsetTop -= contentSize.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
        }
        collectionView.contentInset = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)
    }
}

// MARK: - Delegate
extension SelectCategoryViewController: SelectCategoryViewModelDelegate {
    func presentController(controller: UIViewController?) {
        guard let controller else { return }
        self.present(controller, animated: true)
    }
    
    func reloadData() {
        collectionView.reloadData()
        updateCollectionContentInset()
    }
    
    func dismissController() {
        guard navigationController == nil else {
            navigationController?.popToRootViewController(animated: true)
            return
        }
        self.dismiss(animated: true)
    }
}
