//
//  StepToEnableActionsView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.08.2023.
//

import UIKit

class StepToEnableActionsView: UIView {
    
    private let stepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .black
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 16).font
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(step: String, title: String, highlightedInBold: String,
                   image: UIImage?) {
        stepLabel.text = step
        titleLabel.text = title
        let boldRange = (title as NSString).range(of: highlightedInBold)
        let boldString = NSMutableAttributedString(string: title)
        boldString.addAttribute(NSAttributedString.Key.font,
                                value: UIFont.SFPro.semibold(size: 16).font ?? .systemFont(ofSize: 16),
                                range: boldRange)
        boldString.addAttribute(NSAttributedString.Key.foregroundColor,
                                value: UIColor.black,
                                range: boldRange)
        titleLabel.attributedText = boldString
        imageView.image = image
    }
    
    private func makeConstraints() {
        self.addSubviews([stepLabel, titleLabel, imageView])
        
        stepLabel.setContentHuggingPriority(.init(1000), for: .horizontal)
        stepLabel.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        stepLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview()
        }
        
        titleLabel.setContentHuggingPriority(.init(1000), for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(stepLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(27)
            $0.bottom.equalToSuperview()
        }
    }
}

