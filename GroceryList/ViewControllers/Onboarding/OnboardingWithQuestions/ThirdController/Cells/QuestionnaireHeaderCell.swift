//
//  QuestionnaireHeaderCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.12.2023.
//

import Kingfisher
import UIKit

final class QuestionnaireHeaderCell: UICollectionViewCell {
    
    static let identifier = String(describing: QuestionnaireHeaderCell.self)
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    // MARK: - Public methods
    func configure() {

    }
}

extension QuestionnaireHeaderCell {
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        contentView.backgroundColor = .red
    }
    
    private func addSubViews() {

    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(100).priority(999)
        }
        
    }
    
}
