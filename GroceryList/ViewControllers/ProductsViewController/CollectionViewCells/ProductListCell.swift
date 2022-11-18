//
//  ProductListCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.11.2022.
//

import SnapKit
import UIKit

class ProductListCell: UICollectionViewListCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
         let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
         attrs.bounds.size.height = 56
         return attrs
     }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.textColor = .black
        nameLabel.attributedText = NSAttributedString(string: "")
    }
    
    func setupCell(bcgColor: UIColor?, textColor: UIColor?, text: String?, isPurchased: Bool) {
        contentView.backgroundColor = bcgColor
        checkmarkImage.image = isPurchased ? getImageWithColor(color: textColor) : UIImage(named: "emptyCheckmark")
        guard let text = text else { return }

        nameLabel.attributedText = NSAttributedString(string: text)
        if isPurchased {
            nameLabel.textColor = textColor
        }
    }
    
    func addCheckmark(color: UIColor?, compl: @escaping (() -> Void) ) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.checkmarkImage.image = self.getImageWithColor(color: color)
            self.nameLabel.attributedText = self.nameLabel.text?.strikeThrough()
            self.layoutIfNeeded()
        } completion: { _ in
            compl()
        }
    }
    
    func removeCheckmark(compl: @escaping (() -> Void) ) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.checkmarkImage.image = UIImage(named: "emptyCheckmark")
            self.nameLabel.attributedText = NSAttributedString(string: self.nameLabel.text!)
            self.nameLabel.textColor = .black
            self.layoutIfNeeded()
        } completion: { _ in
            compl()
        }
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
    
    private let contentViews: UIView = {
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
    
    // MARK: - UI
    private func setupConstraints() {
        contentView.addSubviews([contentViews])
        contentViews.addSubviews([nameLabel, checkmarkImage, whiteCheckmarkImage])
        
        contentViews.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
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
       
    }
}
