//
//  FolderRecipePreviewCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 20.06.2023.
//

import Kingfisher
import UIKit

final class FolderRecipePreviewCell: UICollectionViewCell {

    private let containerView = UIView()
    private let topColorView = UIView()
    private let topWhiteView = UIView()
    private let leftColorView = UIView()
    
    private let recipeCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.semibold(size: 13).font
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let mainImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 4
        image.layer.cornerCurve = .continuous
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .white
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.semibold(size: 15).font
        label.textColor = UIColor(hex: "192621")
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImage.image = nil
        topColorView.backgroundColor = .clear
        leftColorView.backgroundColor = .clear
    }
    
    func configure(folderTitle: String, photoUrl: String, imageData: Data?,
                   color: Theme, recipeCount: String) {
        titleLabel.textColor = color.dark
        topColorView.backgroundColor = color.medium
        leftColorView.backgroundColor = color.medium
        
        titleLabel.text = folderTitle
        recipeCountLabel.text = recipeCount

        if let imageData,
           let image = UIImage(data: imageData) {
            mainImage.image = image
            return
        }
        
        if let photoUrl = URL(string: photoUrl) {
            mainImage.kf.setImage(
                with: photoUrl,
                placeholder: nil,
                options: [
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 100, height: 100))),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ])
            return
        }
        
        mainImage.image = R.image.defaultRecipeImage()
    }
    
    private func setupSubviews() {
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve = .continuous
        contentView.addCustomShadow(color: UIColor(hex: "484848"),
                                    offset: .init(width: 0, height: 1))
        contentView.backgroundColor = .white
        topWhiteView.backgroundColor = .white
        containerView.backgroundColor = .white

        containerView.layer.cornerRadius = 12
        containerView.layer.cornerCurve = .continuous
        containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        containerView.clipsToBounds = true

        leftColorView.layer.cornerRadius = 8
        leftColorView.layer.cornerCurve = .continuous
        leftColorView.layer.maskedCorners = [.layerMaxXMaxYCorner]

        topWhiteView.layer.cornerRadius = 8
        topWhiteView.layer.cornerCurve = .continuous
        topWhiteView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        makeConstraints()
    }
    
    private func makeConstraints() {
        self.contentView.addSubviews([containerView])
        containerView.addSubviews([topColorView, leftColorView, topWhiteView,
                                   recipeCountLabel, titleLabel, mainImage])
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topColorView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(12)
        }
        
        leftColorView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.equalTo(32)
            $0.height.equalTo(24)
        }
        
        topWhiteView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalTo(leftColorView.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        recipeCountLabel.snp.makeConstraints {
            $0.edges.equalTo(leftColorView)
        }
        
        mainImage.snp.makeConstraints {
            $0.top.equalTo(leftColorView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(6)
            $0.trailing.equalToSuperview().offset(-6)
            $0.height.equalTo(78)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(mainImage.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }
    }
}
