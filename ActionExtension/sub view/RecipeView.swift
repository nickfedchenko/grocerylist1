//
//  RecipeView.swift
//  ActionExtension
//
//  Created by Хандымаа Чульдум on 02.08.2023.
//

import UIKit

class RecipeView: UIView {
    
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
        label.numberOfLines = 0
        return label
    }()
    
    private let messageView = RecipeEditMessageView()
    private let imageAndKcalView = RecipeImageAndKcalView()
    private let descriptionView = RecipeDescriptionView()
    private let ingredientsView = RecipeIngredientsView()
    private let instructionsView = RecipeInstructionsView()
    private let sourceView = RecipeSourceView()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        makeConstraints()
        
        updateMessageViewConstraints(isVisible: !UserDefaultsManager.shared.isVisibleEditMessageView)
        messageView.tappedCrossButton = { [weak self] in
            UserDefaultsManager.shared.isVisibleEditMessageView = true
            self?.updateMessageViewConstraints(isVisible: false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(recipe: WebRecipe, url: String) {
        titleLabel.text = recipe.title
        imageAndKcalView.configure(recipe: recipe)
        if let description = recipe.info {
            descriptionView.configure(description: description)
        } else {
            descriptionView.snp.remakeConstraints {
                $0.top.equalTo(imageAndKcalView.snp.bottom).offset(0)
                $0.height.equalTo(0)
            }
        }
        ingredientsView.configure(recipe: recipe)
        instructionsView.configure(recipe: recipe)
        sourceView.configure(url: url)
        imageAndKcalView.addShadow(color: .init(hex: "858585"), opacity: 0.1,
                                   radius: 6, offset: .init(width: 0, height: 4))
    }
    
    private func updateMessageViewConstraints(isVisible: Bool) {
        messageView.snp.remakeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            
            if isVisible {
                $0.height.greaterThanOrEqualTo(53)
            } else {
                $0.height.equalTo(0)
            }
        }
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.layoutIfNeeded()
        } completion: { _ in
            self.messageView.isVisible(isVisible)
        }
    }
    
    private func makeConstraints() {
        self.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        contentView.addSubviews([messageView, titleLabel, imageAndKcalView, descriptionView,
                                 ingredientsView, instructionsView, sourceView])

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(self)
        }
        
        messageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.greaterThanOrEqualTo(53)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(messageView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        imageAndKcalView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        descriptionViewMakeConstraints()
        
        ingredientsView.snp.makeConstraints {
            $0.top.equalTo(descriptionView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        instructionsView.snp.makeConstraints {
            $0.top.equalTo(ingredientsView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        sourceView.snp.makeConstraints {
            $0.top.equalTo(instructionsView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
    
    func descriptionViewMakeConstraints() {
        descriptionView.setContentHuggingPriority(.init(1000), for: .vertical)
        descriptionView.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        descriptionView.snp.makeConstraints {
            $0.top.equalTo(imageAndKcalView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
}
