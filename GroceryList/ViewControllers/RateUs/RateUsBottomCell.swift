//
//  RateUsBottomCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 26.12.2023.
//

import UIKit

final class RateUsBottomCell: UICollectionViewCell {

    static let identifier = String(describing: RateUsTopCell.self)
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#0C5151")
        label.font = R.font.sfProTextSemibold(size: 17)
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.rateUsArrowImage()
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods
    func configure(model: RateUsBottomCellModel) {
        imageView.image = model.image
        titleLabel.text = model.title
    }
}

extension RateUsBottomCell {
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        contentView.backgroundColor = UIColor(hex: "#E8FEFE")
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
    }
    
    private func addSubViews() {
        contentView.addSubviews([
            imageView,
            titleLabel,
            arrowImageView
        ])
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(88).priority(999)
        }
        
        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).inset(-8)
            make.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
        }
    }
    
}
