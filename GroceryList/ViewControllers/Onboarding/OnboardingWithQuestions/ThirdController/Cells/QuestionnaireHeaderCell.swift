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
    
    private let questionNumberContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E8FEFE")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private var questionNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#00B59B")
        label.font = R.font.sfProTextSemibold(size: 16)
        label.text = R.string.localizable.onboardingWithQuestionsWelcome()
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#0C5151")
        label.font = R.font.sfProTextBold(size: 34)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#0C5151")
        label.font = R.font.sfProTextRegular(size: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = R.string.localizable.onboardingWithQuestionsChooseAnswers()
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    // MARK: - Public methods
    func configure(text: String, questionNumber: String) {
        questionNumberLabel.text = R.string.localizable.onboardingWithQuestionsQuestion() + questionNumber
        titleLabel.text = text
    }
}

extension QuestionnaireHeaderCell {
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        contentView.backgroundColor = .clear
    }
    
    private func addSubViews() {
        contentView.addSubviews([questionNumberContainerView, titleLabel, subtitleLabel])
        questionNumberContainerView.addSubview(questionNumberLabel)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
           // make.height.equalTo(100).priority(999)
        }
    
        questionNumberContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().priority(999)
            make.centerX.equalToSuperview()
        }
        
        questionNumberLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(questionNumberContainerView.snp.bottom).inset(-8)
            make.left.right.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-8)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(8).priority(999)
        }
    }
}
