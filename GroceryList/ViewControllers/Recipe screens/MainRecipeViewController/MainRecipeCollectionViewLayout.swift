//
//  MainRecipeCollectionViewLayout.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import UIKit

final class MainRecipeCollectionViewLayout {
    
    private let recipeCount: Int
    
    init(recipeCount: Int) {
        self.recipeCount = recipeCount
    }
    
    func makeRecipesLayout() -> UICollectionViewCompositionalLayout {
        let isFolder = UserDefaultsManager.recipeIsFolderView
        return isFolder ? folderLayout() : collectionLayout()
    }
    
    // MARK: collection view
    private func collectionLayout() -> UICollectionViewCompositionalLayout {
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
        let colorSize = NSCollectionLayoutSize(
            widthDimension: .estimated(8),
            heightDimension: .estimated(1)
        )
        
        let colorItem = NSCollectionLayoutItem(layoutSize: colorSize)
        let colorGroupSize = NSCollectionLayoutSize(widthDimension: .estimated(8),
                                                    heightDimension: .estimated(1))
        let colorGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: colorGroupSize, subitem: colorItem, count: 1)
        colorGroup.interItemSpacing = .fixed(8)
        
        let recipeSize = NSCollectionLayoutSize(
            widthDimension: .estimated(128),
            heightDimension: .estimated(1)
        )
        
        let recipeItem = NSCollectionLayoutItem(layoutSize: recipeSize)
        let recipeGroupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(CGFloat((128 * (recipeCount - 1) + 8 * (recipeCount - 1)))),
            heightDimension: .estimated(1)
        )
        
        let recipeGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: recipeGroupSize,
            subitem: recipeItem,
            count: recipeCount - 1
        )
        recipeGroup.interItemSpacing = .fixed(8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(CGFloat((128 * (recipeCount - 1) + 8 * (recipeCount - 1))) + 8),
            heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [colorGroup, recipeGroup])
        
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
        return section
    }
 
    // MARK: folder view
    private func folderLayout() -> UICollectionViewCompositionalLayout {
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
      
        layoutConfig.scrollDirection = .vertical
        let layout = UICollectionViewCompositionalLayout { [weak self] _, _ in
            return self?.makeFolderRecipeSection()
        }
        layout.configuration = layoutConfig
        return layout
    }

    private func makeFolderRecipeSection() -> NSCollectionLayoutSection {
        let columns = 3

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(160)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(160 + 16))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitem: item, count: columns
        )
        group.interItemSpacing = .fixed(16)
        group.contentInsets = .init(top: 16, leading: 16,
                                   bottom: 16, trailing: 16)
        
        let section = NSCollectionLayoutSection(group: group)
        
        
        return section
        
    }
    
}
