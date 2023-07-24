//
//  UpdatedPaywallFeaturesView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 12.07.2023.
//

import UIKit

class UpdatedPaywallFeaturesView: UIView {
    
    private let imageView = UIImageView(image: R.image.updatedPaywall_feature())
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = UIDevice.isSEorXor12mini ? 0 : 24
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let features: [(title: String, subTitle: String)] = [
        (R.string.localizable.today(), R.string.localizable.todaySubtitle()),
        (R.string.localizable.after2Days(), R.string.localizable.after2DaysSubtitle()),
        (R.string.localizable.after3Days(), R.string.localizable.after3DaysSubtitle())
    ]
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFit
        
        features.forEach { feature in
            let view = FeaturesStepView()
            view.configure(title: feature.title, subTitle: feature.subTitle)
            
            stackView.addArrangedSubview(view)
        }

        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeConstraints() {
        self.addSubviews([imageView, stackView])

        imageView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.width.equalTo(39)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIDevice.isSE2 ? 0 : 16)
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.bottom.trailing.equalToSuperview()
        }
    }
}

final private class FeaturesStepView: UIView {
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = R.color.primaryDark()
        label.font = UIFont.SFProDisplay.medium(size: 20).font
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        var label = UILabel()
        label.textColor = R.color.darkGray()
        label.font = UIFont.SFProDisplay.medium(size: 14).font
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, subTitle: String) {
        titleLabel.text = title
        subTitleLabel.text = subTitle
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, subTitleLabel])

        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
}
