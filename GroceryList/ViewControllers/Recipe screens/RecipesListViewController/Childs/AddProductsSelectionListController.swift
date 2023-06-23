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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        correctTitleLabel()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addFoodToListMode()
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
        viewModel?.shouldAdd(to: model, products: productsToAdd)
        delegate?.ingredientsSuccessfullyAdded()
        dismiss(animated: true)
    }

    private func correctTitleLabel() {
        createListLabel.text = R.string.localizable.selectList()
    }
    
}
