//
//  TitleCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.02.2023.
//

import UIKit

final class TitleCell: UITableViewCell {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 15).font
        label.textColor = .black
        label.text = "Shared lists".localized
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setup() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(80)
            $0.centerX.bottom.equalToSuperview()
        }
    }
}
