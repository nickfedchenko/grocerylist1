//
//  SharingHeaderView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 17.02.2023.
//

import UIKit

final class SharingHeaderView: UITableViewHeaderFooterView {
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = UIColor(hex: "#1A645A")
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func configure(_ title: String?) {
        titleLabel.text = title
    }
    
    private func setup() {
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(24)
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
}
