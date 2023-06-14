//
//  StocksLinkView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.06.2023.
//

import UIKit

final class StocksLinkView: UIView {

    private let linkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.SFPro.medium(size: 16).font
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(theme: Theme) {
        linkImageView.image = R.image.linkBig()?.withTintColor(theme.medium)
        titleLabel.textColor = theme.dark
        self.layer.borderColor = theme.medium.cgColor
    }
    
    func configureLink(listNames: [String]) {
        guard !listNames.isEmpty else {
            titleLabel.text = "Link to Shopping List"
            return
        }
        titleLabel.text = listNames.first
    }
    
    private func setup() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        self.layer.cornerCurve = .continuous
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([linkImageView, titleLabel])
        
        linkImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(4)
            $0.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(linkImageView.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}
