//
//  CheckmarkView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 31.01.2023.
//

import UIKit

final class CheckmarkView: UIView {
    private var title: String
    private var fontScale: CGFloat
    private lazy var checkmarkImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "paywallCheckmark")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        var view = UILabel()
        view.textColor = R.color.darkGray()
        view.font = R.font.sfProTextSemibold(size: 15)
        view.text = "Fdfdf"
        view.numberOfLines = 0
        return view
    }()
    
    // MARK: - LifeCycle
    
    init(title: String, using fontScale: CGFloat = 1) {
        self.title = title
        self.fontScale = fontScale
        super.init(frame: .zero)
        titleLabel.text = title
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func adjustForDefaultPaywall() {
        titleLabel.font = R.font.sfProTextSemibold(size: 11)
    }
    
    // MARK: - Constraints
    private func setupConstraint() {
        self.addSubviews([checkmarkImage, titleLabel])
        
//        snp.makeConstraints { make in
//            make.height.equalTo(24)
//        }
        
        checkmarkImage.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(checkmarkImage.snp.right).inset(-8)
//            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview()
        }
    }
}
