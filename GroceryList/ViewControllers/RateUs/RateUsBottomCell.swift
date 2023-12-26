//
//  RateUsBottomCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 26.12.2023.
//

import UIKit

final class RateUsBottomCell: UICollectionViewCell {

    static let identifier = String(describing: RateUsTopCell.self)
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods
    func configure() {
        
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
         
         ])
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(55).priority(999)
        }
    }
    
}
