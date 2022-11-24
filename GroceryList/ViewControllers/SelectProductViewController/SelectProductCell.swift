//
//  SelectProductCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 24.11.2022.
//

import SnapKit
import UIKit

class SelectProductCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(bcgColor: UIColor?, foregroundColor: UIColor?, text: String?, rightImage: UIImage?, isSelected: Bool, isSelectAllButton: Bool) {
        selectAllView.backgroundColor = foregroundColor
        selectAllView.isHidden = !isSelectAllButton
        checkmarkImage.image = isSelected ? getImageWithColor(color: foregroundColor) : UIImage(named: "emptyCheckmark")
        rightImageView.image = rightImage
        nameLabel.text = text
    }
    
    func getImageWithColor(color: UIColor?) -> UIImage? {
        let size = CGSize(width: 28, height: 28)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let color = color else { return nil }
        color.setFill()
        UIRectFill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = image else { return nil }
        return image.rounded(radius: 100)
    }
    
    // MARK: - UI
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "emptyCheckmark")
        return imageView
    }()
    
    private let whiteCheckmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "whiteCheckmark")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        return label
    }()
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let selectAllView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let selectAllLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.text = "selectAll".localized
        label.textColor = .white
        return label
    }()
    
    private func setupConstraints() {
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        contentView.addSubviews([containerView])
        containerView.addSubviews([nameLabel, checkmarkImage, whiteCheckmarkImage, rightImageView, selectAllView])
        selectAllView.addSubviews([selectAllLabel])
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        checkmarkImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(checkmarkImage.snp.right).inset(-12)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(8)
        }
        
        whiteCheckmarkImage.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(checkmarkImage)
            make.width.height.equalTo(17)
        }
        
        rightImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.width.height.equalTo(32)
            make.centerY.equalToSuperview()
        }
        
        selectAllView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectAllLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
    }
}
