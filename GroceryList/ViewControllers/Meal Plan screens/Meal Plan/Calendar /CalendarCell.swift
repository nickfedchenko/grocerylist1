//
//  CalendarCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 11.09.2023.
//

import FSCalendar
import UIKit

final class CalendarCell: FSCalendarCell {
    
    enum TypeOfSelection: Int {
        case today
        case selectedToday
        case selected
        case none
    }
    
    private var size: CGFloat {
        if UIDevice.isSEorXor12mini {
            return 40
        }
        return 48
    }
    
    private var centerPoint: CGPoint {
        CGPoint(x: self.titleLabel.frame.midX - (size / 2),
                y: self.titleLabel.frame.midY - (size / 2) + 5)
    }
    
    private var rectSize: CGSize {
        CGSize(width: size, height: size)
    }
    
    private var roundedRect: CGPath {
        UIBezierPath(roundedRect: .init(origin: centerPoint, size: rectSize),
                     cornerRadius: 8).cgPath
    }
    
    private var selectedCellLayer = CAShapeLayer()
    
    private var typeOfSelection: TypeOfSelection = .none {
        didSet { setNeedsLayout() }
    }
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayer()
        updateFont()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        selectedCellLayer.path = nil
        selectedCellLayer.fillColor = UIColor.clear.cgColor
        selectedCellLayer.strokeColor = UIColor.clear.cgColor
        selectedCellLayer.lineWidth = 0
        titleLabel.font = UIFont.SFPro.medium(size: 16).font
    }
    
    func configure(selection: TypeOfSelection) {
        typeOfSelection = selection
    }
    
    private func updateLayer() {
        switch typeOfSelection {
        case .today:
            selectedCellLayer.fillColor = UIColor(hex: "ECF0F0").cgColor
        case .selectedToday:
            selectedCellLayer.fillColor = R.color.action()?.cgColor
        case .selected:
            selectedCellLayer.fillColor = UIColor.white.cgColor
            selectedCellLayer.strokeColor = R.color.primaryDark()?.cgColor
            selectedCellLayer.lineWidth = 2
        case .none:
            selectedCellLayer.fillColor = UIColor.clear.cgColor
        }
        selectedCellLayer.path = roundedRect
        self.contentView.layer.insertSublayer(selectedCellLayer, below: self.titleLabel?.layer ?? self.layer)
    }
    
    private func updateFont() {
        switch typeOfSelection {
        case .today, .none:
            titleLabel.font = UIFont.SFPro.medium(size: 16).font
        case .selectedToday, .selected:
            titleLabel.font = UIFont.SFPro.heavy(size: 16).font
        }
    }
}
