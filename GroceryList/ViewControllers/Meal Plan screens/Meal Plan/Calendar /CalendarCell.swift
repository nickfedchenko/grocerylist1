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
        
        case edit
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
    
    private var popoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.calendarPopover()
        imageView.addShadow(opacity: 0.3, radius: 50, offset: .init(width: 0, height: 10))
        imageView.isHidden = true
        return imageView
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.SFPro.semibold(size: 16).font
        label.textAlignment = .center
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 2
        return stackView
    }()
    
    private var typeOfSelection: TypeOfSelection = .none {
        didSet { setNeedsLayout() }
    }
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayer()
        updateFont()
        
        if typeOfSelection == .edit {
            titleLabel.textColor = .white
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearLayer()
        titleLabel.font = UIFont.SFPro.medium(size: 16).font
        titleLabel.textColor = R.color.primaryDark()
        labelStackView.removeAllArrangedSubviews()
        
        dateLabel.text = ""
        dateLabel.isHidden = true
        popoverImageView.isHidden = true
    }
    
    func configure(selection: TypeOfSelection, date: Date) {
        typeOfSelection = selection

        dateLabel.text = date.getStringDate(format: "E") + "\n" + date.getStringDate(format: "d")
    }
    
    func configure(labelColors: [UIColor]) {
        labelStackView.removeAllArrangedSubviews()
        labelColors.enumerated().forEach { index, color in
            if index > 4 {
                return
            }
            let view = UIView()
            view.backgroundColor = color
            view.setCornerRadius(3)
            
            labelStackView.addArrangedSubview(view)
            view.snp.makeConstraints {
                $0.verticalEdges.equalToSuperview()
                $0.width.height.equalTo(6)
            }
        }
    }
    
    func editHighlight(isVisible: Bool) {
        dateLabel.isHidden = !isVisible
        popoverImageView.isHidden = !isVisible
        
        guard isVisible else {
            clearLayer()
            updateLayer()
            updateFont()
            return
        }
        
        selectedCellLayer.fillColor = UIColor.white.cgColor
        selectedCellLayer.strokeColor = R.color.primaryDark()?.cgColor
        selectedCellLayer.lineWidth = 2
        titleLabel.font = UIFont.SFPro.heavy(size: 16).font
    }
    
    func editSelect() {
        dateLabel.isHidden = true
        popoverImageView.isHidden = true
        
        selectedCellLayer.fillColor = UIColor.white.cgColor
        selectedCellLayer.strokeColor = R.color.edit()?.cgColor
        selectedCellLayer.lineWidth = 4
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.clearLayer()
            self.updateLayer()
            self.updateFont()
        }
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
        case .edit:
            selectedCellLayer.fillColor = R.color.edit()?.cgColor
        }
        selectedCellLayer.path = roundedRect
        self.contentView.layer.insertSublayer(selectedCellLayer, below: self.titleLabel?.layer ?? self.layer)
    }
    
    private func updateFont() {
        switch typeOfSelection {
        case .today, .none, .edit:
            titleLabel.font = UIFont.SFPro.medium(size: 16).font
        case .selectedToday, .selected:
            titleLabel.font = UIFont.SFPro.heavy(size: 16).font
        }
    }
    
    private func clearLayer() {
        selectedCellLayer.path = nil
        selectedCellLayer.fillColor = UIColor.white.cgColor
        selectedCellLayer.strokeColor = UIColor.clear.cgColor
        selectedCellLayer.lineWidth = 0
    }
    
    private func makeConstraints() {
        self.contentView.addSubviews([labelStackView, popoverImageView, dateLabel])
        
        labelStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(36)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(6)
        }
        
        popoverImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-73)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(73)
            $0.width.equalTo(60)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(popoverImageView).offset(10)
            $0.leading.centerX.equalTo(popoverImageView)
        }
    }
}
