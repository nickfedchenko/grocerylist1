//
//  ImportWebRecipeCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 31.07.2023.
//

import UIKit

final class ImportWebRecipeCell: UITableViewCell {

    var tapTitle: (() -> Void)?
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.textColor = R.color.primaryDark()
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    private func setup() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        let tapOnLabel = UITapGestureRecognizer(target: self, action: #selector(tappedLabel))
        titleLabel.addGestureRecognizer(tapOnLabel)
        
        makeConstraints()
    }
    
    @objc
    private func tappedLabel() {
        tapTitle?()
    }
    
    private func makeConstraints() {
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
