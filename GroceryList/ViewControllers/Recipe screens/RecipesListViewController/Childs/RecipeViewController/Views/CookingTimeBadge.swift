//
//  CookingTimeBadge.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.08.2023.
//

import UIKit

final class CookingTimeBadge: UIView {
    
    private let timerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.timerIcon()
        return imageView
    }()
    
    private let timerCountLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProTextMedium(size: 15)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCookingTime(time: Int?) {
        guard let time = time, time > 0 else {
            timerCountLabel.text = "--"
            return
        }
        timerCountLabel.text = String(time) + " " + R.string.localizable.min()
    }
    
    private func setupAppearance() {
        backgroundColor = .black.withAlphaComponent(0.6)
        clipsToBounds = true
        layer.cornerRadius = 4
        layer.cornerCurve = .continuous
    }
    
    private func setupSubviews() {
        addSubviews([timerImage, timerCountLabel])
        timerImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(6)
            make.height.equalTo(20)
            make.width.equalTo(21)
        }
        
        timerCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(12)
            make.leading.equalTo(timerImage.snp.trailing).offset(8)
        }
    }
}
