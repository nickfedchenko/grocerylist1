//
//  UnitsCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 30.11.2022.
//

import SnapKit
import UIKit

class UnitsCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = .white
                contentView.backgroundColor = UIColor(hex: "#31635A")
            } else {
                titleLabel.textColor = UIColor(hex: "#31635A")
                contentView.backgroundColor = .white
            }
        }
    }
    
    func setupCell(title: String, isSelected: Bool) {
        titleLabel.text = title
        
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.text = "AddItem".localized
        return label
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#31635A")
        return view
    }()
    
    // MARK: - UI
    private func setupConstraints() {
        backgroundColor = .white
        contentView.addSubviews([titleLabel, separatorLine])
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        separatorLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.right.bottom.left.equalToSuperview()
        }
    }
    
}
