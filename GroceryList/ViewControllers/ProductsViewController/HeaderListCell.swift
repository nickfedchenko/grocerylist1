//
//  HeaderListCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.11.2022.
//

import SnapKit
import UIKit

class HeaderListCell: UICollectionViewListCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(bcgColor: UIColor?) {
     //   contentView.backgroundColor = bcgColor
    }
    
    private let contentViews: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#70B170")
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        return label
    }()
    
    // MARK: - UI
    private func setupConstraints() {
        self.addSubviews([contentViews])
        contentViews.addSubviews([nameLabel])
        
        contentViews.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(11)
        }
       
    }
}
