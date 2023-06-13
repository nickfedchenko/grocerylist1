//
//  MainRecipeCollectionViewLayout.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import UIKit

final class MainRecipeCollectionViewLayout {
    func makeRecipesLayout() -> UICollectionViewCompositionalLayout {
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfig.interSectionSpacing = 24
      
        layoutConfig.scrollDirection = .vertical
        let layout = UICollectionViewCompositionalLayout { [weak self] _, _ in
            return self?.makeRecipeSection()
        }
        layout.configuration = layoutConfig
        return layout
    }
    
    private func makeRecipeSection() -> NSCollectionLayoutSection {
        let recipeCount = 12
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(128),
            heightDimension: .estimated(1)
        )
        
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(CGFloat(128 * recipeCount + (8 * recipeCount - 2))),
            heightDimension: .estimated(1)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: recipeCount
        )
        
        group.interItemSpacing = .fixed(8)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(24)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading,
            absoluteOffset: CGPoint(x: 0, y: -8)
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [header]
        section.supplementariesFollowContentInsets = true
        section.contentInsets.leading = 20
        return section
        
    }
}
