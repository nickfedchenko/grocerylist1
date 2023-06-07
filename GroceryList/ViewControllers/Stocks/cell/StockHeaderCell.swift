//
//  StockHeaderCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.06.2023.
//

import UIKit

class StockHeaderCell: UICollectionReusableView {
    
    private let sectionName: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 19).font
        label.textColor = R.color.mediumGray()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sectionName.isHidden = true
    }
    
    func setupHeader(section: PantryStocks) {
        sectionName.text = section.name
        sectionName.isHidden = section.typeOFCell == .normal

        sectionName.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(section.typeOFCell == .normal ? 0 : -8)
        }
    }
    
    private func makeConstraints() {
        addSubviews([sectionName])
        
        sectionName.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
            $0.height.equalTo(24)
        }
    }
}
