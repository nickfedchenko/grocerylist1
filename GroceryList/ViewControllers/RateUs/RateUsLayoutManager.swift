//
//  RateUsLayoutManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 26.12.2023.
//

import Foundation
import UIKit

final class RateUsLayoutManager {
    func makeCollectionLayout() -> UICollectionViewCompositionalLayout {
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfig.scrollDirection = .horizontal
        let layout = UICollectionViewCompositionalLayout { [weak self] _, _ in
            return self?.makeSectionWithPadding()
        }
        layout.configuration = layoutConfig
        return layout
        
    }
    
    private func makeSectionWithPadding() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .absolute(
                    UIScreen.main.bounds.width
                ),
                heightDimension: .estimated(
                    1
                )
            )
        )
        
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
            leading: nil,
            top: NSCollectionLayoutSpacing.fixed(8),
            trailing: nil,
            bottom: NSCollectionLayoutSpacing.fixed(8)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .estimated(1)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: -8,
                                      leading: 0,
                                      bottom: 46,
                                      trailing: 0)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }

}
