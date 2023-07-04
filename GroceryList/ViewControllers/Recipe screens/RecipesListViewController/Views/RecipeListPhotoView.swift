//
//  RecipeListPhotoView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.06.2023.
//

import UIKit
import Kingfisher
 
protocol RecipeListPhotoViewDelegate: AnyObject {
    func choosePhotoButtonTapped()
}

class RecipeListPhotoView: UIView {
    
    weak var delegate: RecipeListPhotoViewDelegate?
     
    private let gradientView = UIView()
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 32
        imageView.layer.cornerCurve = .continuous
        imageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        imageView.clipsToBounds = true
        
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        
        return imageView
    }()
    
    private lazy var choosePhotoButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.choosePhoto(), for: .normal)
        button.addTarget(self, action: #selector(choosePhotoTapped), for: .touchUpInside)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        let color = UIColor(hex: "FFF6EA")
        gradientView.applyGradient([color,
                                    color.withAlphaComponent(0.8),
                                    color.withAlphaComponent(0),
                                    .clear],
                                   locations: [0.0, 0.4, 0.6, 1])
    }
    
    func setPhoto(_ photo: String, localImage: Data?) {
        if let imageData = localImage,
           let image = UIImage(data: imageData) {
            photoImageView.image = image
            return
        }
        
        if let photoUrl = URL(string: photo) {
            photoImageView.kf.setImage(with: photoUrl)
        }
    }
    
    func setImage(image: UIImage?) {
        photoImageView.image = image
    }
    
    @objc
    private func choosePhotoTapped() {
        delegate?.choosePhotoButtonTapped()
    }
    
    private func setupSubviews() {
        self.addSubviews([photoImageView, gradientView, choosePhotoButton])
        
        photoImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(-2)
            $0.trailing.equalToSuperview().offset(2)
            $0.height.equalTo(280)
        }
        
        gradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        choosePhotoButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().offset(-16)
            $0.width.height.equalTo(40)
        }
    }
}
