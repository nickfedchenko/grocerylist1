//
//  AddProductsSelectionList.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 07.12.2022.
//

import UIKit

final class AddProductsSelectionListController: UIViewController {
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    let viewModel = AddProductsListViewModel()
    
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (_, _) -> NSCollectionLayoutSection? in
            return self?.createLayout()
        }
        return layout
    }
    
    private func createLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(72))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .estimated(44))
        let layutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutHeaderSize,
                                                                             elementKind: UICollectionView.elementKindSectionHeader,
                                                                             alignment: .top)
        return layutSectionHeader
    }
}
