//
//  MealPlanCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 12.09.2023.
//

import UIKit

protocol MealPlanCellDelegate: AnyObject {
    func tapMoveButton(gesture: UILongPressGestureRecognizer)
    func tapContextMenu(point: CGPoint, cell: PantryCell)
    func tapSharing(cell: PantryCell)
}

class MealPlanCell: UICollectionViewCell {



}
