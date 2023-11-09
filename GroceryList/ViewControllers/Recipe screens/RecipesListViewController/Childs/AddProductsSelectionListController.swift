//
//  AddProductsSelectionList.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 07.12.2022.
//

import UIKit

protocol AddProductsSelectionListDelegate: AnyObject {
    func ingredientsSuccessfullyAdded()
}

final class AddProductsSelectionListController: SelectListViewController {
    var productsToAdd: [Product]
    weak var delegate: AddProductsSelectionListDelegate?
    
    private let createListView = AddListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        correctTitleLabel()
        makeConstraints()
        
        let createListViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(createListAction))
        createListView.addGestureRecognizer(createListViewRecognizer)
        createListView.setText(R.string.localizable.list().uppercased())
        createListView.setColor(background: R.color.primaryDark(), image: R.color.primaryDark())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addShadow()
    }
    
    init(with productsSet: [Product]) {
        self.productsToAdd = productsSet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = collectionViewDataSource?.itemIdentifier(for: indexPath) else { return }
        let cell = collectionView.cellForItem(at: indexPath) as? SelectListCollectionCell
        cell?.theme = viewModel?.getTheme(at: indexPath)
        cell?.markAsSelect(isSelect: true)
        viewModel?.shouldAdd(to: model, products: productsToAdd)
        delegate?.ingredientsSuccessfullyAdded()
        Vibration.success.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true)
        }
    }
    
    private func correctTitleLabel() {
        createListLabel.text = R.string.localizable.addTo()
        createListLabel.textAlignment = .center
        
        closeButton.setImage(nil, for: .normal)
        closeButton.setTitle(R.string.localizable.cancel(), for: .normal)
        closeButton.setTitleColor(R.color.darkGray(), for: .normal)
        closeButton.titleLabel?.font = UIFont.SFPro.semibold(size: 16).font
    }
    
    private func addShadow() {
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
        contentView.addDefaultShadowForPopUp()
    }
    
    @objc
    private func createListAction() {
        viewModel?.createNewListWithEditModeTapped()
    }
    
    private func makeConstraints() {
        contentView.addSubview(createListView)
        
        createListLabel.snp.removeConstraints()
        closeButton.snp.removeConstraints()
        
        createListLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.centerX.equalToSuperview()
        }

        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalTo(createListLabel)
            $0.height.equalTo(44)
        }
        
        createListView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().offset(2)
            $0.height.equalTo(82)
            $0.width.equalTo(self.view.frame.width / 2)
        }
    }
    
}
