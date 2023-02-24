//
//  SharingView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.02.2023.
//

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
    
    private var activeImageViews: [UIImageView] = []
    private var allImageViews: [UIImageView] {
        [firstImageView, secondImageView, thirdImageView, fourthImageView]
    }
    private var images: [UIImage] = []
    var state: SharingState = .invite {
        didSet { updateState() }
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func clearView() {
        state = .invite
        images.removeAll()
        allImageViews.forEach {
            $0.isHidden = true
            $0.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func configure(image: UIImage) {
        images.append(image)
        allImageViews.forEach {
            $0.image = nil
        }
        updateState()
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
    
    private func updateState() {
        switch state {
        case .invite:
            firstImageView.isHidden = false
            firstImageView.image = R.image.profile_add()
            firstImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        case .added:
            firstImageView.isHidden = false
            firstImageView.image = R.image.profile_intited()
            firstImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
            configureImages(images)
        }
    }
    
    private func configureImages(_ images: [UIImage]) {
        guard !images.isEmpty else {
            return
        }
        updateAllImageViewsConstraints()
        switch images.count {
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
        
        activeImageViews.enumerated().forEach { index, imageView in
            imageView.isHidden = false
            imageView.image = images[safe: index]
            imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
            imageView.layer.borderWidth = 2
            imageView.layer.cornerRadius = 16
        }
        
        if images.count > 4 {
            countLabel.text = "\(images.count - 1)"
            firstImageView.image = nil
            firstImageView.backgroundColor = UIColor(hex: "#00D6A3")
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
