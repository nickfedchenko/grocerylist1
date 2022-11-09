//
//  CreateNewListViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 09.11.2022.
//

import SnapKit
import UIKit

class CreateNewListViewController: UIViewController {
    
    var viewModel: CreateNewListViewModel?
    weak var router: RootRouter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        addKeyboardNotifications()
        addRecognizers()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTextFieldParametrs()
    }
    
    private func setupTextFieldParametrs() {
        textfield.delegate = self
        textfield.becomeFirstResponder()
    }
    
    @objc
    private func saveAction() {
        hidePanel()
    }
    
    @objc
    private func pickItemsAction() {
        print("pick items from anither list")
    }
    
    private func addRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(saveAction))
        saveButtonView.addGestureRecognizer(tapRecognizer)
        
        let secondTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickItemsAction))
        pickItemsFromList.addGestureRecognizer(secondTapRecognizer)
    }
    
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(_ notification: NSNotification) {
        let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardFrame = value?.cgRectValue else { return }
        let height = Double(keyboardFrame.height)
        updateConstr(with: height)
    }
    
    func updateConstr(with inset: Double) {
        UIView.animate(withDuration: 0.3) { [ weak self ] in
            self?.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(inset)
            }
            self?.view.layoutIfNeeded()
        }
    }
    
    // MARK: - swipeDown
    
    private func hidePanel() {
        textfield.resignFirstResponder()
        updateConstr(with: -400)
        
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
    
    private let textfield: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont.SFPro.medium(size: 17).font
        textfield.textColor = .white
        textfield.backgroundColor = UIColor(hex: "#9CAC53")
        textfield.layer.cornerRadius = 6
        textfield.layer.masksToBounds = true
        textfield.keyboardAppearance = .light
        textfield.placeholder = "NameOfNewList".localized
        textfield.paddingLeft(inset: 20)
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
    
    private var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let pickItemsFromList: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.layer.borderColor = UIColor(hex: "#31635A").cgColor
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        return view
    }()
    
    private let pickItemsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 16).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "PickFromAnotherList".localized
        return label
    }()
    
    private let sortingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 16).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "AutomaticSorting".localized
        label.numberOfLines = 2
        return label
    }()
    
    private let switchView: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = UIColor(hex: "#31635A")
        switcher.isOn = true
        return switcher
    }()
    
    private let pickItemsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "pickImage")
        return imageView
    }()
    
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.addSubview(contentView)
        contentView.addSubviews([textfield, colorCollectionView, saveButtonView,
                                 pickItemsFromList, sortingLabel, switchView])
        pickItemsFromList.addSubviews([pickItemsLabel, pickItemsImage])
        saveButtonView.addSubview(saveLabel)
        
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-385)
            make.height.equalTo(385)
        }
        
        textfield.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(72)
        }
        
        saveButtonView.snp.makeConstraints { make in
            make.bottom.right.left.equalToSuperview()
            make.height.equalTo(64)
        }
        
        colorCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(52)
            make.top.equalTo(textfield.snp.bottom).inset(-24)
        }
        
        pickItemsFromList.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(colorCollectionView.snp.bottom).inset(-20)
            make.height.equalTo(48)
        }
        
        pickItemsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
        
        pickItemsImage.snp.makeConstraints { make in
            make.right.equalTo(pickItemsLabel.snp.left).inset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(26)
            make.width.equalTo(27)
        }
        
        sortingLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(pickItemsFromList.snp.bottom).inset(-20)
            make.right.equalToSuperview().inset(86)
        }
        
        switchView.snp.makeConstraints { make in
            make.top.equalTo(pickItemsFromList.snp.bottom).inset(-20)
            make.right.equalToSuperview().inset(20)
        }
        
        saveLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}

extension CreateNewListViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 30
    }
}

extension CreateNewListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func setupCollectionView() {
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCollectionViewCell")
        colorCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.getNumberOfCells() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ColorCollectionViewCell",
            for: indexPath) as? ColorCollectionViewCell,
              let viewModel = viewModel else { return UICollectionViewCell() }
        let colors = viewModel.getColorForCell(at: indexPath.row)
        cell.setupCell(listColor: colors.0, backgroundColor: colors.1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
