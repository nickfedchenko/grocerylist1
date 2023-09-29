//
//  ContextMenuSubView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 28.09.2023.
//

import UIKit

final class ContextMenuSubView: UIView {
    
    var onViewAction: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let sharingView = SharingView()
    
    private var mainColor: UIColor = .black
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(color: UIColor) {
        titleLabel.textColor = color
        imageView.image = imageView.image?.withTintColor(color)
    }
    
    func configure(title: String, image: UIImage?, color: UIColor) {
        titleLabel.text = title
        titleLabel.textColor = color
        
        imageView.image = image?.withTintColor(color)
    }
    
    func setupSharingView(state: SharingView.SharingState, color: UIColor, images: [String?]) {
        sharingView.isHidden = state != .added
        imageView.isHidden = state == .added
        sharingView.configure(state: state, viewState: .products,
                              color: color, images: images)
    }
    
    private func setup() {
        self.backgroundColor = .white
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(onViewTapped))
        self.addGestureRecognizer(tapOnView)
        
        sharingView.isHidden = true
        
        makeConstraints()
    }
    
    @objc
    private func onViewTapped() {
        onViewAction?()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, imageView, sharingView])
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(imageView.snp.leading).offset(-8)
            $0.height.greaterThanOrEqualTo(40)
        }
        
        imageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(40)
        }
        
        sharingView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}
