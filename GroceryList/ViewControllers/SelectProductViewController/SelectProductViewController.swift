//
//  SelectProductViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import SnapKit
import UIKit

class SelectProductViewController: UIViewController {
    
    var viewModel: SelectProductViewModel?
    var contentViewHeigh: Double = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraint()
    }
    
    // MARK: - UI

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private func setupConstraint() {
        view.backgroundColor = .clear
        view.addSubviews([contentView])
       
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-contentViewHeigh)
            make.height.equalTo(contentViewHeigh)
        }
    }
}
