//
//  PrototypeCell.swift
//  CalorieTracker
//
//  Created by Vladimir Banushkin on 04.08.2022.
//

import Kingfisher
import UIKit

final class RecipePreviewCell: UICollectionViewCell {
    private var isFirstLayout = true
    
    private let backgroundImageView = UIView()
    private let badgeView = UIView()
    
    private let mainImage: UIImageView = {
        let image = UIImageView()
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
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.semibold(size: 12).font
        label.textColor = .white
        return label
    }()
    
    private let timeImage = UIImageView(image: R.image.recipeTimeIcon())
    
    private let kcalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.semibold(size: 12).font
        label.textColor = .white
        return label
    }()
    
    private let kcalImage = UIImageView(image: R.image.recipeKcalIcon())
    private let favoriteImage = UIImageView(image: R.image.recipeFavoriteIcon())
    
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
        kcalImage.isHidden = true
        kcalLabel.isHidden = true
        favoriteImage.isHidden = true
        badgeView.layer.cornerRadius = 0
        badgeView.snp.remakeConstraints { make in
            make.bottom.leading.equalToSuperview()
            make.height.equalTo(18)
            make.trailing.equalToSuperview()
        }
    }
    
    func configure(with recipe: ShortRecipeModel, color: Theme) {
        titleLabel.textColor = color.dark
        contentView.backgroundColor = color.light
        
        titleLabel.text = recipe.title
        timeLabel.text = recipe.time < 0 ? "--" : "\(recipe.time)"
        
        favoriteImage.isHidden = !recipe.isFavorite
        
        if let kcal = recipe.values?.serving?.kcal {
            kcalImage.isHidden = false
            kcalLabel.isHidden = false
            
            kcalLabel.text = "\(Int(kcal))"
            kcalLabel.snp.makeConstraints { make in
                make.trailing.equalTo(-8)
                make.top.equalToSuperview().offset(3)
            }
        } else if let kcal = recipe.values?.dish?.kcal {
            kcalImage.isHidden = false
            kcalLabel.isHidden = false
            
            kcalLabel.text = "\(Int(kcal))"
            kcalLabel.snp.makeConstraints { make in
                make.trailing.equalTo(-8)
                make.top.equalToSuperview().offset(3)
            }
        } else {
            badgeView.layer.cornerRadius = 8
            badgeView.snp.remakeConstraints { make in
                make.bottom.leading.equalToSuperview()
                make.height.equalTo(18)
                make.trailing.equalTo(timeLabel.snp.trailing).offset(8)
            }
        }
        
        if let imageData = recipe.localImage,
           let image = UIImage(data: imageData) {
            mainImage.image = image
            return
        }
        
        if let photoUrl = URL(string: recipe.photo) {
            mainImage.kf.setImage(
                with: photoUrl,
                placeholder: nil,
                options: [
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 100, height: 100))),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ])
//            mainImage.kf.setImage(with: photoUrl)
            return
        }
        mainImage.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawShadows()
    }
    
    private func setupSubviews() {
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = 8
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
        
        badgeView.layer.cornerCurve = .continuous
        badgeView.layer.maskedCorners = [.layerMaxXMinYCorner]
        badgeView.clipsToBounds = true

        backgroundImageView.layer.cornerRadius = 7
        backgroundImageView.layer.cornerCurve = .continuous
        backgroundImageView.layer.masksToBounds = true
        
        badgeView.backgroundColor = .black.withAlphaComponent(0.6)
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.contentView.addSubviews([backgroundImageView, titleLabel])
        backgroundImageView.addSubviews([mainImage, badgeView, favoriteImage])
        badgeView.addSubviews([timeImage, timeLabel, kcalImage, kcalLabel])
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(1)
            make.trailing.equalToSuperview().offset(-1)
            make.height.equalTo(79)
        }
        
        mainImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(backgroundImageView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        
        badgeView.snp.makeConstraints { make in
            make.bottom.leading.equalToSuperview()
            make.height.equalTo(18)
            make.trailing.equalToSuperview()
        }

        favoriteImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(3)
            make.trailing.equalToSuperview().offset(-3)
            make.height.width.equalTo(20)
        }
        
        makeBadgeViewConstraints()
    }
    
    private func makeBadgeViewConstraints() {
        timeImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(16)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(timeImage.snp.trailing)
            make.top.equalToSuperview().offset(3)
        }
        
        kcalImage.snp.makeConstraints { make in
            make.trailing.equalTo(kcalLabel.snp.leading)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(16)
        }
    }
    
    private func drawShadows() {
        guard isFirstLayout else { return }
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowColor = UIColor(hex: "06BBBB").cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.2
        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowPath = shadowPath.cgPath
        shadowLayer.shadowColor = UIColor(hex: "123E5E").cgColor
        shadowLayer.shadowOpacity = 0.25
        shadowLayer.shadowRadius = 2
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0.5)
        layer.insertSublayer(shadowLayer, at: 0)
        drawInlinedStroke()
        isFirstLayout = false
    }
    
    private func drawInlinedStroke() {
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }
}
