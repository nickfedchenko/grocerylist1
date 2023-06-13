//
//  AddToAnotherListViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.02.2023.
//

import UIKit

final class AddToAnotherListViewController: SelectListViewController {
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
