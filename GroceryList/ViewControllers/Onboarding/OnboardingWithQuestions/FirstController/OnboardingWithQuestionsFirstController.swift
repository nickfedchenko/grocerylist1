//
//  OnboardingWithQuestions.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.12.2023.
//

import UIKit

final class QuestionnaireFirstController: UIViewController {

    weak var router: RootRouter?
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.onboardingWithQuestionsBackground()
        return view
    }()
    
    private let bottomContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.onboardingWithQuestionsIcon()
        return view
    }()
    
    private let welcomeContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E8FEFE")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private var welcomeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#00B59B")
        label.font = R.font.sfProTextSemibold(size: 16)
        label.text = R.string.localizable.onboardingWithQuestionsWelcome()
        return label
    }()
    
    private var groceryListLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#0C5151")
        label.font = R.font.sfProTextBold(size: 34)
        label.text = R.string.localizable.onboardingWithQuestionsGroceryList()
        label.textAlignment = .center
        return label
    }()
    
    private var saveMoneyLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#0C5151")
        label.font = R.font.sfProTextSemibold(size: 17)
        label.text = R.string.localizable.onboardingWithQuestionsSaveMoney()
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(string: "Next".localized.uppercased(), attributes: [
            .font: UIFont.SFPro.semibold(size: 20).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#FFFFFF")
        ])
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(hex: "#1A645A")
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.addShadowForView()
        button.setImage(UIImage(named: "nextArrow"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = .white
        button.imageEdgeInsets.left = 8
        return button
    }()
    
    // MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
        makeConstraints()
    }
    
    // MARK: - actions
    @objc
    private func nextButtonPressed() {
        router?.openQuestionnaireSecondController()
    }
}

extension QuestionnaireFirstController {
    private func makeConstraints() {
        self.view.addSubviews([imageView, bottomContentView])
        
        bottomContentView.addSubviews([
            iconImageView,
            welcomeContainerView,
            groceryListLabel,
            saveMoneyLabel,
            nextButton
        ])
        
        welcomeContainerView.addSubview(welcomeLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(72)
        }
        
        welcomeContainerView.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).inset(-24)
            make.centerX.equalToSuperview()
        }
        
        welcomeLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(8)
        }
        
        groceryListLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomeContainerView.snp.bottom).inset(-12)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        saveMoneyLabel.snp.makeConstraints { make in
            make.top.equalTo(groceryListLabel.snp.bottom).inset(-8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        bottomContentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(30)
            make.height.equalTo(340)
        }
        
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(64)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}
