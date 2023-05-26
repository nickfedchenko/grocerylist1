//
//  IconSubView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 25.05.2023.
//

import UIKit

final class IconSubView: UIView {
    
    var icon: UIImage? {
        iconImageView.image
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.SFProRounded.medium(size: 14).font
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.text = R.string.localizable.icon()
        return label
    }()

    private let capitalLetterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.SFProRounded.heavy(size: 22).font
        label.textAlignment = .center
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let dashImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.pantry_circle_dash()
        return imageView
    }()
    
    private let dotsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        return view
    }()
    
    private let dotsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.pantry_icon_dots()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(color: Theme) {
        dotsView.layer.borderColor = color.medium.cgColor
        dotsImageView.image = R.image.pantry_icon_dots()?.withTintColor(color.dark)
    }
    
    func configure(icon: UIImage?, name: String) {
        let icon = icon ?? iconImageView.image
        
        if name.isEmpty {
            iconImageView.image = nil
            capitalLetterLabel.text = ""
            dashImageView.isHidden = false
            dotsView.isHidden = false
            titleLabel.isHidden = false
            return
        }
        
        guard let icon else {
            titleLabel.isHidden = !name.isEmpty
            capitalLetterLabel.isHidden = name.isEmpty
            capitalLetterLabel.text = name.first?.uppercased()
            return
        }
        iconImageView.image = icon
        titleLabel.isHidden = true
        dashImageView.isHidden = true
        dotsView.isHidden = true
        capitalLetterLabel.isHidden = true
    }
    
    private func setup() {
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([dashImageView, titleLabel, capitalLetterLabel, iconImageView, dotsView])
        dotsView.addSubview(dotsImageView)
        
        dashImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.equalToSuperview().offset(2)
            $0.height.equalTo(16)
        }
        
        capitalLetterLabel.snp.makeConstraints {
            $0.center.leading.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        iconImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dotsView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(1)
            $0.trailing.equalToSuperview().offset(6)
            $0.height.width.equalTo(16)
        }
        
        dotsImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(2)
            $0.height.equalTo(6)
        }
    }
}
