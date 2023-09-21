//
//  CreateNewRecipePhotoView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.03.2023.
//

import UIKit

class CreateNewRecipePhotoView: UIView {

    var imageTapped: (() -> Void)?
    var requiredHeight: Int {
        19 + 20 + 4 + 174
    }
    var image: UIImage? {
        photoImageView.image
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = R.color.darkGray()
        label.text = R.string.localizable.photo()
        return label
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = R.color.mediumGray()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.camera()
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textAlignment = .center
        label.textColor = .white
        label.text = R.string.localizable.youCanAddPhoto()
        label.numberOfLines = 0
        return label
    }()
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setImage(_ image: UIImage?) {
        photoImageView.image = image
        iconImageView.isHidden = image != nil
        descriptionLabel.isHidden = image != nil
    }
    
    private func setup() {
        self.backgroundColor = .clear
        let tapOnImageView = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        shadowTwoView.addGestureRecognizer(tapOnImageView)
        
        setupShadowView()
        makeConstraints()
    }
    
    private func setupShadowView() {
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.backgroundColor = UIColor(hex: "#7A948F")
            shadowView.layer.cornerRadius = 8
        }
        shadowOneView.addShadow(opacity: 0.03,
                                      radius: 8,
                                      offset: .init(width: 0, height: 1))
        shadowTwoView.addShadow(opacity: 0.03,
                                      radius: 4,
                                      offset: .init(width: 0, height: 6))
    }
    
    @objc
    private func imageViewTapped() {
        imageTapped?()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, shadowOneView, shadowTwoView, photoImageView])
        photoImageView.addSubviews([iconImageView, descriptionLabel])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.top.equalToSuperview().offset(19)
            $0.height.equalTo(20)
        }
        
        photoImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.width.equalTo(261)
            $0.height.equalTo(174)
        }
        
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.snp.makeConstraints { $0.edges.equalTo(photoImageView) }
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(photoImageView).offset(50)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalTo(37)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
}
