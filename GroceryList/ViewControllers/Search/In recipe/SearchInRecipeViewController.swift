//
//  SearchInRecipeViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.03.2023.
//

import UIKit

final class SearchInRecipeViewController: SearchViewController {

    var viewModel: SearchInRecipeViewModel?
    
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
        setSearchPlaceholder(viewModel?.placeholder ?? R.string.localizable.recipes())
        searchTextField.delegate = self
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(classCell: RecipeListCell.self)
    }
    
    override func tappedCancelButton() {
        self.dismiss(animated: true)
    }
    
    override func tappedCleanerButton() {
        super.tappedCleanerButton()
        viewModel?.search(text: "")
    }
    
}

extension SearchInRecipeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        UICollectionViewCell()
    }
}

extension SearchInRecipeViewController: UICollectionViewDelegate {
    
}

extension SearchInRecipeViewController: UITextFieldDelegate {
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
