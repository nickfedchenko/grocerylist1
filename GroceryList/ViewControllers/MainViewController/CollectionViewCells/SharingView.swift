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
        case expectation
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
    private var actiteImageViews: [UIImageView] = []
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
    
    func configure(state: SharingState, images: [UIImage] = []) {
        self.state = state
        allImageViews.forEach {
            $0.image = nil
        }
        switch state {
        case .invite:
            firstImageView.image = R.image.profile_add()
            firstImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        case .expectation:
            firstImageView.image = R.image.profile_intited()
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
    
    private func configureImages(_ images: [UIImage]) {
        guard !images.isEmpty else {
            return
        }
        
        switch images.count {
        case 1:
            actiteImageViews = [firstImageView]
            firstImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        case 3:
            actiteImageViews = [thirdImageView, secondImageView, firstImageView]
            secondImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-42) }
            thirdImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-70) }
            thirdImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        case 4:
            actiteImageViews = allImageViews.reversed()
            secondImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-32) }
            thirdImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-50) }
            fourthImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-68) }
            fourthImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        default:
            actiteImageViews = [secondImageView, firstImageView]
            secondImageView.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-44) }
            secondImageView.snp.makeConstraints { $0.leading.equalToSuperview().offset(12) }
        }
        
        actiteImageViews.enumerated().forEach { index, imageView in
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
}
