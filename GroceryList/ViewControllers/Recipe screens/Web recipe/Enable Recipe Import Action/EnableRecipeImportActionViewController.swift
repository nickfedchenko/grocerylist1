//
//  EnableRecipeImportActionViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.08.2023.
//

import UIKit

class EnableRecipeImportActionViewController: UIViewController {

    private let navigationView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.background()?.withAlphaComponent(0.9)
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.back_Chevron(), for: .normal)
        button.tintColor = R.color.primaryDark()
        button.setTitle(R.string.localizable.recipes(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
        button.titleLabel?.textColor = R.color.primaryDark()
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset.bottom = 120
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 22).font
        label.textColor = R.color.primaryDark()
        label.text = "Enable the Recipe Import Action"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 16).font
        label.textColor = .black
        label.text = "Grocery List App allows you to quickly import a recipe to your collection from a website."
        label.numberOfLines = 0
        return label
    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = 25
        return stackView
    }()
    
    private let steps = ImportStep.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = R.color.background()
        setupStackView()
        makeConstraints()
    }
    
    private func setupStackView() {
        stackView.removeAllArrangedSubviews()
        
        steps.enumerated().forEach { index, step in
            let view = StepToEnableActionsView()
            view.configure(step: "\(index + 1).",
                           title: step.title, highlightedInBold: step.highlightedInBold,
                           image: step.image)
            stackView.addArrangedSubview(view)
        }
    }
    
    @objc
    private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    private func makeConstraints() {
        self.view.addSubviews([scrollView, navigationView])
        self.scrollView.addSubview(contentView)
        contentView.addSubviews([titleLabel, descriptionLabel, stackView])
        navigationView.addSubviews([backButton])
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(self.view)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13 + 40 + UIView.safeAreaTop)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.width.equalTo(self.view)
        }
        
        navigationView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}
