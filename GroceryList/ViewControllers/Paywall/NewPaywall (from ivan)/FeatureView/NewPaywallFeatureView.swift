//
//  NewPaywallFeatureView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.07.2023.
//

import UIKit

class NewPaywallFeatureView: UIView {

    struct FeatureModel {
        let image: UIImage?
        let color: UIColor?
        let title: String
        let free: Bool
    }
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.updatedPaywall_logoImg()
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = R.color.primaryDark()
        label.font = UIFont.SFProDisplay.heavy(size: 28).font
        label.text = R.string.localizable.unlockPremium()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        var label = UILabel()
        label.textColor = R.color.primaryDark()
        label.font = UIFont.SFProDisplay.semibold(size: 16).font
        label.text = R.string.localizable.withUsefulFeatures()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(classCell: NewPaywallFeatureCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        let inset: CGFloat = UIDevice.isLessPhoneSE ? 350 : UIDevice.isMoreDefaultPhone ? 150 : 220
        collectionView.contentInset.bottom = inset
        collectionView.contentInset.top = 110
        return collectionView
    }()
    
    private lazy var layout: UICollectionViewLayout = {
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: NSCollectionLayoutDimension.estimated(52)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 6
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    private let radialGradientView = RadialGradientView()
    private let freeView = FeatureFreePremiumView(state: .free)
    private let premiumView = FeatureFreePremiumView(state: .premium)
    
    private var features: [FeatureModel] = []
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupFeatures()
        
        self.layer.cornerRadius = 24
        self.backgroundColor = UIColor(hex: "59FFD4")
        self.addDefaultShadowForContentView()
        
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        radialGradientView.layoutIfNeeded()
    }
    
    func updateTitle(isTrial: Bool) {
        titleLabel.text = isTrial ? R.string.localizable.try3DaysForFree() : R.string.localizable.unlockPremium()
    }
    
    private func setupFeatures() {
        let color = ColorManager.shared
        let themeNumbers: [Int] = [1, 4, 9, 6, 2, 5, 11, 0, 8, 12]
        var index = 0
        while index >= 0 {
            if let image = UIImage(named: "feature_new_paywall_\(index)") {
                let title = "NewPaywall.Feature.\(index)".localized
                features.append(.init(image: image,
                                      color: color.getGradient(index: themeNumbers[index]).medium,
                                      title: title,
                                      free: index >= 3))
                index += 1
            } else {
                index = -1
            }
        }
        
        collectionView.reloadData()
    }
    
    private func makeConstraints() {
        self.addSubviews([collectionView])
        collectionView.addSubviews([radialGradientView, iconImageView, titleLabel, subtitleLabel,
                                    freeView, premiumView])

        radialGradientView.snp.makeConstraints {
            $0.center.equalTo(iconImageView)
            $0.width.height.equalTo(183)
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-86)
            $0.leading.equalToSuperview().offset(24)
            $0.width.height.equalTo(57)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-80)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(14)
            $0.trailing.equalTo(self.snp.trailing).offset(-16)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.trailing.equalTo(titleLabel)
        }
        
        freeView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(1)
            $0.trailing.equalTo(premiumView.snp.leading).offset(-4)
            $0.width.equalTo(44)
            $0.height.equalTo(20)
        }
        
        premiumView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(1)
            $0.trailing.equalTo(self.snp.trailing).offset(-24)
            $0.width.equalTo(44)
            $0.height.equalTo(20)
        }
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension NewPaywallFeatureView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                    numberOfItemsInSection section: Int) -> Int {
        features.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: NewPaywallFeatureCell.self,
                                                          indexPath: indexPath)
        cell.configure(feature: features[indexPath.row])
        return cell
    }

}

extension NewPaywallFeatureView: UICollectionViewDelegate {
    
}

class RadialGradientView: UIView {
    
    private lazy var pulse: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .radial
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0.7).cgColor,
                        UIColor.white.withAlphaComponent(0).cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradientLayer)
        return gradientLayer
    }()

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        pulse.frame = bounds
        pulse.cornerRadius = bounds.width / 2.0
    }
}
