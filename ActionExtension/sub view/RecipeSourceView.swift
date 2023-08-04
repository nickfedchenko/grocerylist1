//
//  RecipeSourceView.swift
//  ActionExtension
//
//  Created by Хандымаа Чульдум on 03.08.2023.
//

import UIKit

class RecipeSourceView: UIView {

    private lazy var sourceTitleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedBold(size: 18)
        label.textColor = R.color.primaryDark()
        label.text = R.string.localizable.recipeSource()
        return label
    }()
    
    lazy var sourceLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(url: String) {
        let underlineString = NSMutableAttributedString(string: url)
        let range = (url as NSString).range(of: url)
        underlineString.addAttribute(NSAttributedString.Key.underlineStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: range)
        underlineString.addAttribute(NSAttributedString.Key.font,
                                     value: UIFont.SFPro.medium(size: 17).font ?? .systemFont(ofSize: 17),
                                     range: range)
        underlineString.addAttribute(NSAttributedString.Key.foregroundColor,
                                     value: R.color.primaryDark() ?? .gray,
                                     range: range)
        sourceLabel.attributedText = underlineString
    }
    
    private func makeConstraints() {
        self.addSubviews([sourceTitleLabel, sourceLabel])
        
        sourceTitleLabel.snp.makeConstraints {
            $0.horizontalEdges.top.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        sourceLabel.snp.makeConstraints {
            $0.top.equalTo(sourceTitleLabel.snp.bottom).offset(10)
            $0.height.greaterThanOrEqualTo(17)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
