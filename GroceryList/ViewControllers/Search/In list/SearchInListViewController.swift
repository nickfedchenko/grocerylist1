//
//  SearchInListViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.03.2023.
//

import UIKit

final class SearchInListViewController: SearchViewController {
    
    var viewModel: SearchInListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.updateData = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    override func setup() {
        super.setup()
        setSearchPlaceholder(R.string.localizable.lists())
        searchTextField.delegate = self
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(classCell: SearchInListCell.self)
    }
    
    override func tappedCancelButton() {
        self.dismiss(animated: true)
    }
    
    override func tappedCleanerButton() {
        super.tappedCleanerButton()
        viewModel?.search(text: "")
    }
}

extension SearchInListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.listCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: SearchInListCell.self, indexPath: indexPath)
        guard let list = viewModel?.getList(by: indexPath.row) else {
            return UICollectionViewCell()
        }
        cell.configureList(list)
        cell.configureProducts(viewModel?.getProducts(by: indexPath.row))
        cell.listTapped = { [weak self] in
            self?.dismiss(animated: true, completion: {
                self?.viewModel?.showList(list)
            })
        }
        cell.shareTapped = { [weak self] in
            self?.viewModel?.showSharing(list)
        }
        cell.purchaseTapped = { [weak self] product in
            self?.viewModel?.updatePurchasedStatus(product: product)
        }
        return cell
    }
}

extension SearchInListViewController: UICollectionViewDelegate {
    
}

extension SearchInListViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        setCleanerButton(isVisible: (textField.text?.count ?? 0) >= 3)
        guard (textField.text?.count ?? 0) >= 3 else {
            return
        }
        viewModel?.search(text: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }
}
