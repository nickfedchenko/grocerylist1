//
//  EditSelectListViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 11.04.2023.
//

import UIKit
 
protocol EditSelectListDelegate: AnyObject {
    func productsSuccessfullyMoved()
    func productsSuccessfullyCopied()
}

enum EditListState {
    case move
    case copy
    
    var title: String {
        switch self {
        case .move: return R.string.localizable.moveTo()
        case .copy: return R.string.localizable.copyTo()
        }
    }
}

final class EditSelectListViewController: SelectListViewController {
    weak var delegate: EditSelectListDelegate?
    var productsToAdd: [Product]
    var state: EditListState
    
    private let bottomCreateListView = AddListView()
    
    init(with productsSet: [Product], state: EditListState) {
        self.productsToAdd = productsSet
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        makeConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = .black.withAlphaComponent(0.4)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = collectionViewDataSource?.itemIdentifier(for: indexPath) else { return }
        viewModel?.saveCopiedProduct(to: model, products: productsToAdd)
        if state == .move {
            delegate?.productsSuccessfullyMoved()
        } else {
            delegate?.productsSuccessfullyCopied()
        }
        dismiss(animated: true)
    }
    
    private func setup() {
        createListLabel.text = state.title
        createListLabel.textAlignment = .center
        
        closeButton.setImage(nil, for: .normal)
        closeButton.setTitle(R.string.localizable.cancel(), for: .normal)
        closeButton.setTitleColor(R.color.edit(), for: .normal)
        closeButton.titleLabel?.font = UIFont.SFPro.semibold(size: 16).font
        
        let firstRecognizer = UITapGestureRecognizer(target: self, action: #selector(createListAction))
        bottomCreateListView.addGestureRecognizer(firstRecognizer)
    }
    
    @objc
    private func createListAction() {
        viewModel?.createNewListWithEditModeTapped()
    }
    
    private func makeConstraints() {
        contentView.addSubview(bottomCreateListView)
        
        createListLabel.snp.removeConstraints()
        closeButton.snp.removeConstraints()
        
        createListLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.centerX.equalToSuperview()
        }

        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(createListLabel)
            $0.height.equalTo(44)
        }
        
        bottomCreateListView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
            $0.height.equalTo(82)
            $0.width.equalTo(self.view.frame.width / 2)
        }
    }
}
