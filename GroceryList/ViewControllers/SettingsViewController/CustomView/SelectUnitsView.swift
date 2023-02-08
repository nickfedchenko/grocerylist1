//
//  SelectUnitsView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.02.2023.
//

import Foundation
import UIKit

final class SelectUnitsView: UIView {
    
    var systemSelected: ((SelectedUnitSystem) -> Void)?
    
    private lazy var imperialView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()
    
    private let imperialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "Imperial".localized
        return label
    }()
    
    private var metricView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        view.layer.masksToBounds = true
        return view
    }()
    
    private let metriclLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "Metric".localized
        return label
    }()
    
    // MARK: - LifeCycle
    
    init(imperialColor: UIColor?, metricColor: UIColor?) {
        super.init(frame: .zero)
        updateColors(imperialColor: imperialColor, metricColor: metricColor)
        setupView()
        setupConstraint()
        addRecognizer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Constraints
    
    func updateColors(imperialColor: UIColor?, metricColor: UIColor?) {
        imperialView.backgroundColor = imperialColor
        metricView.backgroundColor = metricColor
    }
    
    private func setupView() {
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.isHidden = false
        self.addShadowForView()
    }
    
    private func setupConstraint() {
        self.addSubviews([imperialView, metricView])
        metricView.addSubview(metriclLabel)
        imperialView.addSubview(imperialLabel)
     
        imperialView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        metricView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        metriclLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16)
        }
        
        imperialLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16)
        }
    }
    
    private func addRecognizer() {
        let imperialViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(imperialViewAction))
        imperialView.addGestureRecognizer(imperialViewRecognizer)
        let metricViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(metricViewAction))
        metricView.addGestureRecognizer(metricViewRecognizer)
    }
    
    @objc
    private func imperialViewAction(_ recognizer: UIPanGestureRecognizer) {
        imperialView.backgroundColor = .white
        metricView.backgroundColor = .white
        systemSelected?(.imperial)
    }
    
    @objc
    private func metricViewAction(_ recognizer: UIPanGestureRecognizer) {
        imperialView.backgroundColor = .white
        metricView.backgroundColor = .white
        systemSelected?(.metric)
    }
}
