//
//  ActivityIndicatorView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.08.2023.
//

import UIKit

final class ActivityIndicatorView: UIView {
    
    private var activityView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSpinner() {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        activityIndicator.startAnimating()
        
        activityView = activityIndicator
    }

    func show(for view: UIView) {
        self.backgroundColor = .black.withAlphaComponent(0.03)
        addSpinner()
    }
    
    func removeFromView() {
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
}
