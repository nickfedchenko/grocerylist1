//
//  SharingView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.02.2023.
//

import Kingfisher
import UIKit

final class SharingView: UIView {
    
    enum SharingState {
        case invite
        case added
    }
    
    private lazy var firstImageView: UIImageView = createImageView()
    private lazy var secondImageView: UIImageView = createImageView()
    private lazy var thirdImageView: UIImageView = createImageView()
    private lazy var fourthImageView: UIImageView = createImageView()
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    private var state: SharingState = .invite
    private var activeImageViews: [UIImageView] = []
    private var allImageViews: [UIImageView] {
        [firstImageView, secondImageView, thirdImageView, fourthImageView]
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func clearView() {
        countLabel.text = ""
        allImageViews.forEach {
            $0.isHidden = true
            $0.layer.borderColor = UIColor.clear.cgColor
            $0.backgroundColor = .clear
            $0.image = nil
        }
        updateAllImageViewsConstraints()
    }
    
    func configure(state: SharingState, images: [String?] = []) {
        self.state = state
        allImageViews.forEach {
            $0.image = nil
        }
        switch state {
        case .invite:
            firstImageView.isHidden = false
            firstImageView.image = R.image.profile_add()
            firstImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        case .added:
            configureImages(images)
        }
    }
    
    private func setup() {
        self.backgroundColor = .clear
        makeConstraints()
    }
    
    private func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }
    
    private func configureImages(_ images: [String?]) {
        updateAllImageViewsConstraints()
        guard !images.isEmpty else {
            firstImageView.isHidden = false
            firstImageView.image = R.image.profile_intited()
            firstImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
            return
        }
        updateActiveImageViewsConstraints(imageCount: images.count)
        
        activeImageViews.enumerated().forEach { index, imageView in
            imageView.isHidden = false
            imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
            imageView.layer.borderWidth = 2
            imageView.layer.cornerRadius = 16
            
            guard let userAvatarUrl = images[index],
                  let url = URL(string: userAvatarUrl) else {
                return imageView.image = R.image.profile_icon()
            }
            
            imageView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 30, height: 30))),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ])

        }
        
        if images.count > 4 {
            countLabel.text = "\(images.count - 1)"
            firstImageView.image = nil
            firstImageView.backgroundColor = UIColor(hex: "#00D6A3")
        }
    }
    
    private func updateActiveImageViewsConstraints(imageCount: Int) {
        switch imageCount {
        case 1:
            activeImageViews = [firstImageView]
            firstImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        case 3:
            activeImageViews = [thirdImageView, secondImageView, firstImageView]
            secondImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-42) }
            thirdImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-70) }
            thirdImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        case 4:
            activeImageViews = allImageViews.reversed()
            secondImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-32) }
            thirdImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-50) }
            fourthImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-68) }
            fourthImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        default:
            activeImageViews = [secondImageView, firstImageView]
            secondImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-44) }
            secondImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        }
    }
    
    private  func makeConstraints() {
        self.addSubviews(allImageViews)
        firstImageView.addSubview(countLabel)
        
        allImageViews.forEach { imageView in
            imageView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().offset(-16)
                $0.height.width.equalTo(32)
            }
        }
        
        countLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.leading.equalToSuperview().offset(4)
        }
    }

    private func updateAllImageViewsConstraints() {
        allImageViews.forEach { imageView in
            imageView.snp.removeConstraints()
            
            imageView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().offset(-16)
                $0.height.width.equalTo(32)
            }
            imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
