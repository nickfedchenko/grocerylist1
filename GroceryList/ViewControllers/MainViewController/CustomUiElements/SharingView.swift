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
    
    enum ViewState {
        case main
        case products
        case productsSettings
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
    
    func configure(state: SharingState, viewState: ViewState, color: UIColor, images: [String?] = []) {
        self.state = state
        allImageViews.forEach {
            $0.image = nil
        }
        switch state {
        case .invite:
            firstImageView.isHidden = false
            configurePlusImage(imageView: firstImageView, color: color,
                               viewState: viewState, imagesIsEmpty: true)
            firstImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        case .added:
            if viewState == .productsSettings {
                configureImages(images, color: color)
                return
            }
            configureImages(images, color: color, viewState: viewState)
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
    
    private func configureImages(_ images: [String?], color: UIColor, viewState: ViewState) {
        updateAllImageViewsConstraints()
        guard !images.isEmpty else {
            secondImageView.isHidden = false
            configurePlusImage(imageView: secondImageView, color: color,
                               viewState: viewState, imagesIsEmpty: true)
            secondImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
            return
        }
        
        let count = images.count >= 3 ? 3 : images.count + 1
        updateActiveImageViewsConstraints(imageCount: count)
        
        let plusImageView = activeImageViews.removeFirst()
        configurePlusImage(imageView: plusImageView, color: color,
                           viewState: viewState, imagesIsEmpty: false)
        
        if images.count >= 3 {
            countLabel.text = "\(images.count - 1)"
            let countImageView = activeImageViews.removeLast()
            countImageView.image = nil
            countImageView.backgroundColor = color
            configureImageView(countImageView)
        }
        
        setupImage(imageUrl: images)
    }
    
    private func configureImages(_ images: [String?], color: UIColor) {
        updateAllImageViewsConstraints()
        guard !images.isEmpty else {
            firstImageView.isHidden = false
            firstImageView.image = R.image.profile_intited()?.withTintColor(.black)
            firstImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
            return
        }
        updateActiveImageViewsConstraints(imageCount: images.count)
        setupImage(imageUrl: images)
        
        if images.count > 4 {
            countLabel.text = "\(images.count - 1)"
            firstImageView.image = nil
            firstImageView.backgroundColor = color
        }
    }
    
    private func setupImage(imageUrl: [String?]) {
        activeImageViews.enumerated().forEach { index, imageView in
            configureImageView(imageView)
            
            guard let userAvatarUrl = imageUrl[index],
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
    }
    
    private func configurePlusImage(imageView: UIImageView, color: UIColor,
                                    viewState: ViewState, imagesIsEmpty: Bool) {
        var image = R.image.sharing_plus()
        if state == .invite || imagesIsEmpty {
            image = viewState == .products ? R.image.profile_add() : R.image.sharing_plus()
        }
        imageView.image = image?.withTintColor(viewState == .products ? color : .white)
        imageView.backgroundColor = viewState == .products ? .white : color
        guard image != R.image.profile_add() else {
            imageView.backgroundColor = .clear
            return
        }
        configureImageView(imageView)
    }
    
    private func configureImageView(_ imageView: UIImageView) {
        imageView.isHidden = false
        imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = 16
        imageView.layer.cornerCurve = .continuous
    }
    
    private func updateActiveImageViewsConstraints(imageCount: Int) {
        switch imageCount {
        case 1:
            activeImageViews = [firstImageView]
            firstImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        case 3:
            activeImageViews = [thirdImageView, secondImageView, firstImageView]
            secondImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-26) }
            thirdImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-54) }
            thirdImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        case 4:
            activeImageViews = allImageViews.reversed()
            secondImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-16) }
            thirdImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-36) }
            fourthImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-52) }
            fourthImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        default:
            activeImageViews = [secondImageView, firstImageView]
            secondImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-28) }
            secondImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        }
    }
    
    private  func makeConstraints() {
        self.addSubviews(allImageViews)
        firstImageView.addSubview(countLabel)
        
        allImageViews.forEach { imageView in
            imageView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview()
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
                $0.trailing.equalToSuperview()
                $0.height.width.equalTo(32)
            }
            imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
