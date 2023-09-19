//
//  RecipeInstructionsView.swift
//  ActionExtension
//
//  Created by Хандымаа Чульдум on 03.08.2023.
//

import UIKit

class RecipeInstructionsView: UIView {
    
    private lazy var instructionsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = R.color.primaryDark()
        label.text = "Instructions".localized
        label.numberOfLines = 0
        return label
    }()
    
    private let instructionsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        stackView.axis = .vertical
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(recipe: WebRecipe) {
        guard let instructions = recipe.methods else {
            return
        }
        
        setupInstructions(instructions: instructions)
    }
    
    func setupInstructions(instructions: [String]) {
        instructionsStack.removeAllArrangedSubviews()
        
        for (index, instruction) in instructions.enumerated() {
            let view = InstructionView()
            view.setStepNumber(num: index + 1)
            view.setInstruction(instruction: instruction)
            instructionsStack.addArrangedSubview(view)
            view.layoutIfNeeded()
            view.setContentHuggingPriority(.init(1000), for: .vertical)
            view.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        }
    }
    
    func updateViewsConstraints() {
        instructionsLabel.textColor = R.color.darkGray()
        
        instructionsLabel.snp.removeConstraints()
        instructionsStack.snp.removeConstraints()
        
        instructionsLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(40)
        }
        
        instructionsStack.snp.makeConstraints {
            $0.top.equalTo(instructionsLabel.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([instructionsLabel, instructionsStack])
        
        instructionsLabel.snp.makeConstraints {
            $0.horizontalEdges.top.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        instructionsStack.setContentHuggingPriority(.init(1000), for: .vertical)
        instructionsStack.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        instructionsStack.snp.makeConstraints {
            $0.top.equalTo(instructionsLabel.snp.bottom).offset(8)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }

}
