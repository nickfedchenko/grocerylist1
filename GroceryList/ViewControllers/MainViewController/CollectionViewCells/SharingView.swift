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
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(state: SharingState, image: [UIImage]) {
        switch state {
        case .invite:
            firstImageView.image = R.image.profile_add()
        case .expectation:
            firstImageView.image = R.image.profile_intited()
        case .added:
            firstImageView.image = R.image.profile_icon()
        }
    }
    
    private func setup() {
        self.backgroundColor = .clear
        
        makeConstraints()
    }
    
    private func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        
        return imageView
    }
    
    private  func makeConstraints() {
        self.addSubviews([firstImageView, secondImageView, thirdImageView, fourthImageView])
        firstImageView.addSubview(countLabel)
    }
}
