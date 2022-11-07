//
//  GroceryTableViewHeader.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import SnapKit
import UIKit

class GroceryCollectionViewHeader: UICollectionReusableView {
    static let identifier = "GroceryCollectionViewHeader"
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupHeader(sectionType: SectionType) {
        guard sectionType != .favorite else { return sectionName.isHidden = true }
        pinchImage.isHidden = true
        sectionName.text = sectionType.rawValue.localized
    }
    
    private let sectionName: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = UIColor(hex: "#818281")
        return label
    }()
    
    private let pinchImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "pinchImage")
        return imageView
    }()
    
    private func setupConstraints() {
        addSubviews([sectionName, pinchImage])
        sectionName.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(4)
        }
        
        pinchImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(30)
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.bottom.equalToSuperview().inset(4)
        }
    }
}
