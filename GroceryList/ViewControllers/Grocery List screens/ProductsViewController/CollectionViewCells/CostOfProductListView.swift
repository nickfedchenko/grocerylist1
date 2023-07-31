//
//  CostOfProductListView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.04.2023.
//

import UIKit

class CostOfProductListView: UIView {

    private lazy var storeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 11).font
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var costLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 11).font
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let storeView = UIView()
    private let costView = UIView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureColor(_ color: UIColor) {
        storeView.backgroundColor = color
        costView.backgroundColor = color
    }
    
    func configureStore(title: String?) {
        storeLabel.text = title
        
        storeView.isHidden = title == nil
        let maskedCornersCost: CACornerMask = title == nil ? [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
                                                           : [.layerMaxXMaxYCorner]
        storeView.clipsToBounds = true
        storeView.layer.cornerRadius = 4
        storeView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        costView.clipsToBounds = true
        costView.layer.cornerRadius = 4
        costView.layer.maskedCorners = maskedCornersCost
    }
    
    func configureCost(value: Double?) {
        let currencySymbol = Locale.current.currencySymbol ?? ""
        guard let value else {
            costLabel.text = "--- " + currencySymbol
            return
        }
        let quantityString = String(format: "%.\(value.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", value)
        costLabel.text = quantityString + " " + currencySymbol
    }
    
    private func setup() {
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([storeView, costView])
        storeView.addSubview(storeLabel)
        costView.addSubview(costLabel)
        
        storeView.snp.makeConstraints {
            $0.leading.bottom.top.equalToSuperview()
            $0.trailing.equalTo(costView.snp.leading)
        }
        
        costView.snp.makeConstraints {
            $0.trailing.bottom.top.equalToSuperview()
            $0.width.equalTo(48)
        }
        
        storeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.center.equalToSuperview()
            $0.height.equalTo(11)
        }
        
        costLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
