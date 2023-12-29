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
    
    private let checkMarkImageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.image = R.image.questionaireeChekmarkNotActive()
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#0C5151")
        label.font = R.font.sfProTextSemibold(size: 17)
        label.numberOfLines = 0 
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            checkMarkImageView.image = isSelected ? R.image.questionaireeChekmarkActive() : R.image.questionaireeChekmarkNotActive()
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods
    func configure(text: String) {
        titleLabel.text = text
    }

}

extension QuestionnaireCell {
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        contentView.backgroundColor = UIColor(hex: "#E8FEFE")
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        //let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
      //  contentView.addGestureRecognizer(tapRecognizer)
    }
    
    private func addSubViews() {
         contentView.addSubviews([checkMarkImageView, titleLabel])
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        checkMarkImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(checkMarkImageView.snp.right).inset(-8)
            make.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(24).priority(999)
        }
    }
    
}
