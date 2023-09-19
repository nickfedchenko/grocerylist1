//
//  MealPlanLabelsViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.09.2023.
//

import UIKit

class MealPlanLabelsViewController: UIViewController {

    private let grabberBackgroundView = UIView()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "3C3C43", alpha: 0.3)
        view.setCornerRadius(2.5)
        return view
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "045C5C")
        button.setTitle("Done".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.heavy(size: 17).font
        button.addTarget(self, action: #selector(tappedDoneButton), for: .touchUpInside)
        button.contentEdgeInsets.left = 20
        button.contentEdgeInsets.right = 20
        button.layer.cornerRadius = 20
        button.layer.cornerCurve = .continuous
        button.layer.maskedCorners = [.layerMinXMaxYCorner]
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.heavy(size: 24).font
        label.textColor = R.color.primaryDark()
        label.text = R.string.localizable.mealPlanLabel()
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        grabberBackgroundView.backgroundColor = .white.withAlphaComponent(0.95)
        
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 20).font
        label.textColor = R.color.darkGray()
        label.text = "Экран еще не готов\n😅"
        label.numberOfLines = 0
        
        self.view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        makeConstraints()
    }

    @objc
    private func tappedDoneButton() {
        self.dismiss(animated: true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([grabberBackgroundView, grabberView, titleLabel, doneButton])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(24)
        }
        
        grabberBackgroundView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(5)
            $0.width.equalTo(36)
        }
        
        doneButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.greaterThanOrEqualTo(120)
        }
        doneButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        doneButton.setContentHuggingPriority(.init(1000), for: .horizontal)
    }
}
