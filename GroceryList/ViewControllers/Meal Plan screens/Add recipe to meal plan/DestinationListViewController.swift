//
//  DestinationListViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.09.2023.
//

import UIKit

protocol DestinationListDelegate: AnyObject {
    func selectedListId(_ listId: UUID)
}

class DestinationListViewController: EditSelectListViewController {

    weak var destinationListDelegate: DestinationListDelegate?
    
    override func viewDidLoad() {
        self.contentViewHeigh = self.view.frame.height - 60
        super.viewDidLoad()
        
        createListLabel.text = R.string.localizable.destinationList()
        
        closeButton.setTitleColor(R.color.darkGray(), for: .normal)
        
        closeButton.snp.removeConstraints()
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalTo(createListLabel)
            $0.height.equalTo(24)
        }
    }
    
    init() {
        super.init(with: [], state: .copy)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = collectionViewDataSource?.itemIdentifier(for: indexPath) else { return }
        destinationListDelegate?.selectedListId(model.id)
        dismiss(animated: true)
    }
}
