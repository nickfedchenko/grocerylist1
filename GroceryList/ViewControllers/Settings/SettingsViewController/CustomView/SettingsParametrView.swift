//
//  SettingsParametrView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//

import SnapKit
import UIKit

class SettingsParametrView: UIView {
    
    var switchValueChanged: ((Bool) -> Void)?
    
    init() {
        super.init(frame: .zero)
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(text: String, unitSustemText: String? = nil,
                   isSwitchView: Bool = false, isAttrHidden: Bool = false,
                   titleColor: UIColor = .titleColor) {
        
        if let unitSustemText {
            unitSystemLabel.text = unitSustemText
        }
        if isSwitchView {
            rightChevron.isHidden = true
            switchView.isHidden = false
        }
        
        if isAttrHidden {
            rightChevron.isHidden = true
            switchView.isHidden = true
            textLabel.textColor = .black
        }
        textLabel.text = text
        textLabel.textColor = titleColor
    }
    
    func updateSwitcher(isOn: Bool) {
        switchView.isOn = isOn
    }
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.medium(size: 16).font
        label.textColor = UIColor(hex: "#31635A")
        label.numberOfLines = 2
        return label
    }()
    
    private let unitSystemLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.medium(size: 16.fitW).font
        label.textColor = .black
        return label
    }()
    
    private let rightChevron: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "rightChevronGreen")
        return imageView
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F4FFF5")
        return view
    }()
    
    private let switchView: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = UIColor(hex: "#31635A")
        switcher.isHidden = true
        return switcher
    }()
    
    @objc
    private func switchChanged() {
        switchValueChanged?(switchView.isOn)
    }
    
    private func setupConstraints() {
        addSubviews([textLabel, lineView, rightChevron, unitSystemLabel, switchView])
        
        textLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
//            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        unitSystemLabel.snp.makeConstraints { make in
            make.right.equalTo(rightChevron.snp.left).inset(-17)
            make.centerY.equalToSuperview()
        }
        
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
        
        switchView.snp.makeConstraints { make in
            make.left.equalTo(textLabel.snp.right)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        rightChevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(12)
        }
    }
}
