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
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func setup() {
        super.setup()
        setSearchPlaceholder(R.string.localizable.lists())
        searchTextField.delegate = self
    }
    
    override func setupTableView() {
        super.setupTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120
        tableView.register(classCell: SearchInListCell.self)
    }
    
    override func tappedCancelButton() {
        self.dismiss(animated: true)
    }
    
    override func tappedCleanerButton() {
        super.tappedCleanerButton()
        viewModel?.search(text: "")
    }
}

extension SearchInListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.listCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(classCell: SearchInListCell.self, indexPath: indexPath)
        guard let list = viewModel?.getList(by: indexPath.row) else {
            return UITableViewCell()
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

extension SearchInListViewController: UITableViewDelegate {
    
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
