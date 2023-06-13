//
//  PrototypeCell.swift
//  CalorieTracker
//
//  Created by Vladimir Banushkin on 04.08.2022.
//

import UIKit

final class RecipePreviewCell: UICollectionViewCell {
   private var isFirstLayout = true
    static let identifier = String(describing: RecipePreviewCell.self)
    
    private let mainImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 8
        image.layer.cornerCurve = .continuous
        image.layer.maskedCorners = [.layerMinXMinYCorner]
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .white
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProTextSemibold(size: 15)
        label.textColor = UIColor(hex: "192621")
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Air fryer bacon"
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
    }
    
    func configure(with recipe: ShortRecipeModel) {
        titleLabel.text = recipe.title
        if let photoUrl = URL(string: recipe.photo) {
            mainImage.kf.setImage(with: photoUrl)
            return
        }
        if let imageData = recipe.localImage,
           let image = UIImage(data: imageData) {
            mainImage.image = image
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawShadows()
    }
    
    private func setupSubviews() {
        contentView.backgroundColor = .white
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = 8
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
        [titleLabel, mainImage].forEach {
            contentView.addSubview($0)
        }
        
        mainImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.height.equalTo(36)
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
    
    func drawInlinedStroke() {
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }
}
