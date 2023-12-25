//
//  QuestionnarieThirdControllerLayoutManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.12.2023.
//

import Foundation
import UIKit

final class QuestionnaireThirdControllerLayoutManager {
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
                    UIScreen.main.bounds.width - 40
                ),
                heightDimension: .estimated(
                    1
                )
            )
        )
        
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
            leading: nil,
            top: NSCollectionLayoutSpacing.fixed(16),
            trailing: nil,
            bottom: NSCollectionLayoutSpacing.fixed(16)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .estimated(1)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 41,
                                      leading: 20,
                                      bottom: 0,
                                      trailing: 20)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }

}
