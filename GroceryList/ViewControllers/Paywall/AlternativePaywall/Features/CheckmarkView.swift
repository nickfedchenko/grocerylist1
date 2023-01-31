//
//  CheckmarkView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 31.01.2023.
//

import UIKit

final class CheckmarkView: UIView {
    
    private lazy var checkmarkImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "paywallCheckmark")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        var view = UILabel()
        view.textColor = UIColor(hex: "#617774")
        view.font = UIFont.SFPro.semibold(size: 17).font
        view.text = "Fdfdf"
        return view
    }()
    
    // MARK: - LifeCycle
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Constraints
    private func setupConstraint() {
        self.addSubviews([checkmarkImage, titleLabel])
        
        snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        
        checkmarkImage.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(checkmarkImage.snp.right).inset(-8)
            make.centerY.equalToSuperview()
        }
    }
}
