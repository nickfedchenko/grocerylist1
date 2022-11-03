//
//  GroceryTableViewHeader.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import SnapKit
import UIKit

class GroceryTableViewHeader: UITableViewHeaderFooterView {
    static let identifier = "GroceryTableViewHeader"
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    func setupHeader(nameOfSection: String?) {
        if nameOfSection != nil { pinchImage.isHidden = true }
        sectionName.text = nameOfSection
    }
    
    private let sectionName: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = UIColor(hex: "#818281")
        label.text = ".jbkjhvkghvk"
        return label
    }()
    
    private let pinchImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "pinchImage")
        return imageView
    }()
    
    private func setupConstraints() {
        contentView.addSubviews([sectionName, pinchImage])
        sectionName.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(30)
            make.centerY.equalToSuperview()
        }
        
        pinchImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(30)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
    }
}
