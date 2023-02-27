//
//  UITableViewExtension.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.02.2023.
//

import UIKit

extension UITableView {
    func register<T>(classCell: T.Type) where T: UITableViewCell {
        self.register(classCell, forCellReuseIdentifier: classCell.className)
    }
    
    func reusableCell<T>(classCell: T.Type, indexPath: IndexPath) -> T where T: UITableViewCell {
        if let newCell = self.dequeueReusableCell(withIdentifier: classCell.className, for: indexPath) as? T {
            return newCell
        }
        return T(style: .default, reuseIdentifier: classCell.className)
    }
    
    func registerHeader<T>(classHeader: T.Type) where T: UITableViewHeaderFooterView {
        self.register(classHeader, forHeaderFooterViewReuseIdentifier: classHeader.className)
    }
    
    func reusableHeader<T>(classHeader: T.Type) -> T where T: UITableViewHeaderFooterView {
        if let header = self.dequeueReusableHeaderFooterView(withIdentifier: classHeader.className) as? T {
            return header
        }
        return T(reuseIdentifier: classHeader.className)
    }
}

extension UICollectionView {
    func register<T>(classCell: T.Type) where T: UICollectionViewCell {
        self.register(classCell, forCellWithReuseIdentifier: classCell.className)
    }
    
    func reusableCell<T>(classCell: T.Type, indexPath: IndexPath) -> T where T: UICollectionViewCell {
        if let newCell = self.dequeueReusableCell(withReuseIdentifier: classCell.className, for: indexPath) as? T {
            return newCell
        }
        return T()
    }
    
    func registerHeader<T>(classHeader: T.Type) where T: UICollectionReusableView {
        self.register(classHeader,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: classHeader.className)
    }
    
    func reusableHeader<T>(classHeader: T.Type, indexPath: IndexPath) -> T? where T: UICollectionReusableView {
        if let header = self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                              withReuseIdentifier: classHeader.className,
                                                              for: indexPath) as? T {
            return header
        }
        return nil
    }
}

extension NSObject {
    class var className: String {
        let array = String(describing: self).components(separatedBy: ".")
        return array.last ?? "className"
    }
}
