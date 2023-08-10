//
//  ActivityIndicatorView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 24.03.2023.
//

import NVActivityIndicatorView
import UIKit

final class SynchronizationActivityView: UIView {
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        view.addDefaultShadowForPopUp()
        view.backgroundColor = R.color.action()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.semibold(size: 14).font
        label.textColor = R.color.primaryDark()
        label.text = "Synchronization".localized
        return label
    }()
    
    private var activityView = NVActivityIndicatorView(frame: .zero,
                                                       type: .ballClipRotatePulse,
                                                       color: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews([backgroundView, activityView, titleLabel])
        
        backgroundView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(160)
            $0.height.equalTo(80.5)
        }
        
        activityView.snp.makeConstraints {
            $0.top.equalTo(backgroundView).offset(19)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(activityView.snp.bottom).offset(9)
            $0.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(for view: UIView) {
        self.backgroundColor = .black.withAlphaComponent(0.2)
        view.addSubview(self)
        self.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
        activityView.startAnimating()
    }
    
    func removeFromView() {
        activityView.stopAnimating()
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
}
