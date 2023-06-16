//
//  AutoRepeatView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.06.2023.
//

import UIKit

class AutoRepeatView: UIView {
    
    private lazy var autoRepeatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.autoRepeat()
        return imageView
    }()
    
    private lazy var autoRepeatLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        label.text = R.string.localizable.autoRepeat()
        return label
    }()
    
    private lazy var calendarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.calendar()
        return imageView
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setRepeat(_ autoRepeat: String?) {
        autoRepeatLabel.text = autoRepeat ?? R.string.localizable.autoRepeat()
    }
    
    private func setup() {
        makeConstraints()
    }

    private func makeConstraints() {
        self.addSubviews([autoRepeatImageView, autoRepeatLabel, calendarImageView])
        
        autoRepeatImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(40)
        }
        
        autoRepeatLabel.snp.makeConstraints {
            $0.leading.equalTo(autoRepeatImageView.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(calendarImageView.snp.leading)
        }
        
        calendarImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-28)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(40)
        }
    }
}
