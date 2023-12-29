//
//  RateUsTopCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 26.12.2023.
//

import UIKit

final class RateUsTopCell: UICollectionViewCell {

    static let identifier = String(describing: RateUsTopCell.self)
    
    private let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.rateUsHeaderBackground()
        return view
    }()
    
    private let centerImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.rateUsHeaderBackground()
        return view
    }()
    
    private let labelInContainerView: LabelInContainerView = {
        let view = LabelInContainerView()
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#0C5151")
        label.font = R.font.sfProTextBold(size: 34)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#0C5151")
        label.font = R.font.sfProTextSemibold(size: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
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
    func configure(model: RateUsTopCellModel) {
        centerImageView.image = model.backgroundImage
        labelInContainerView.configure(text: model.labelInContainerText)
        titleLabel.text = model.titleLabelText
        subtitleLabel.text = model.subtitleLabelText
    }
}

extension RateUsTopCell {
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        contentView.backgroundColor = .white
    }
    
    private func addSubViews() {
         contentView.addSubviews([
            backgroundImageView,
            centerImageView,
            labelInContainerView,
            titleLabel,
            subtitleLabel
         ])
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(444)
        }
        
        centerImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(264)
            make.height.equalTo(260)
        }
        
        labelInContainerView.snp.makeConstraints { make in
            make.top.equalTo(centerImageView.snp.bottom).inset(-20)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(labelInContainerView.snp.bottom).inset(-8)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-8)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(16).priority(999)
        }
    }
}
