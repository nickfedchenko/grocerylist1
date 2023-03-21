//
//  MoreRecipeCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 20.02.2023.
//

import UIKit

final class MoreRecipeCell: UICollectionViewCell {
    private var isFirstLayout = true
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedSemibold(size: 40)
        label.textColor = UIColor(hex: "192621")
        label.textAlignment = .center
        label.textColor = .white
        label.text = "25"
        return label
    }()
    
    private let moreLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProTextSemibold(size: 15)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = "more recipes"
        return label
    }()
    
    private(set) var sectionIndex: Int = -1
    weak var delegate: RecipesFolderHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(at sectionIndex: Int, title: String) {
        titleLabel.text = title
        self.sectionIndex = sectionIndex
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawShadows()
    }
    
    private func setupSubviews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        self.addGestureRecognizer(tap)
        
        contentView.backgroundColor = UIColor(hex: "#62D3B4")
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = 8
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
        contentView.addSubviews([titleLabel, moreLabel])
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        
        moreLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(18)
            make.bottom.equalToSuperview().offset(-26)
        }
    }
    
    private func drawShadows() {
        guard isFirstLayout else { return }
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowColor = UIColor(hex: "06BBBB").cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.2
        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowPath = shadowPath.cgPath
        shadowLayer.shadowColor = UIColor(hex: "123E5E").cgColor
        shadowLayer.shadowOpacity = 0.25
        shadowLayer.shadowRadius = 2
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0.5)
        layer.insertSublayer(shadowLayer, at: 0)
        drawInlinedStroke()
        isFirstLayout = false
    }
    
    private func drawInlinedStroke() {
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }
    
    @objc
    private func tappedOnView() {
        delegate?.headerTapped(at: sectionIndex)
    }
}
