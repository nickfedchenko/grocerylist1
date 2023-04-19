//
//  UnitsCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 30.11.2022.
//

import SnapKit
import UIKit

class UnitsCell: UITableViewCell {
    
    enum UnitsState {
        case unit
        case anyStore
        case newStore
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        newStoreButton.isHidden = true
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = .white
                contentView.backgroundColor = color
            } else {
                titleLabel.textColor = state != .anyStore ? color : .white
                contentView.backgroundColor = state != .anyStore ? .white : UIColor(hex: "#ACB4B4")
            }
        }
    }
    
    var state: UnitsState = .unit
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newStoreButton.isHidden = true
        titleLabel.isHidden = false
        self.backgroundColor = .white
        titleLabel.textColor = color
    }
    
    func setupCell(title: String, isSelected: Bool, color: UIColor) {
        titleLabel.text = title
        titleLabel.textColor = color
        separatorLine.backgroundColor = color
        self.color = color
    }
    
    // MARK: store cell
    func setupAnyStore(color: UIColor) {
        titleLabel.text = R.string.localizable.anyStore()
        titleLabel.textColor = .white
        separatorLine.backgroundColor = color
    }
    
    func setupNewStore(color: UIColor) {
        separatorLine.backgroundColor = color
        titleLabel.isHidden = true
        newStoreButton.isHidden = false
        newStoreButton.isUserInteractionEnabled = false
        newStoreButton.setTitle(" " + R.string.localizable.newStore(), for: .normal)
        newStoreButton.setTitleColor(color, for: .normal)
        newStoreButton.setImage(R.image.marker()?.withTintColor(color), for: .normal)
        newStoreButton.imageView?.contentMode = .scaleAspectFit
        newStoreButton.titleLabel?.font = UIFont.SFPro.semibold(size: 17).font
        
        let lineView = UIView(frame: CGRect(x: 0, y: newStoreButton.frame.size.height,
                                            width: newStoreButton.frame.size.width + 2, height: 1))
        lineView.backgroundColor = color
        newStoreButton.addSubview(lineView)
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .black
        label.text = "AddItem".localized
        return label
    }()
    
    private let newStoreButton = UIButton()
    
    private let separatorLine = UIView()
    private var color: UIColor = .clear
    
    // MARK: - UI
    private func setupConstraints() {
        backgroundColor = .white
        contentView.addSubviews([newStoreButton, titleLabel, separatorLine])
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        separatorLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.right.bottom.left.equalToSuperview()
        }
        
        newStoreButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
}
