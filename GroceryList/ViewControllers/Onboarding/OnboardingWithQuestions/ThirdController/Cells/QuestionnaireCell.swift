//
//  QuestionnaireCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.12.2023.
//

import Kingfisher
import UIKit

final class QuestionnaireCell: UICollectionViewCell {
    
    static let identifier = String(describing: QuestionnaireCell.self)
    
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

extension QuestionnaireCell {
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        contentView.backgroundColor = .blue
    }
    
    private func addSubViews() {
      //   contentView.addSubview(imageView)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50).priority(999)
        }
    }
    
}
