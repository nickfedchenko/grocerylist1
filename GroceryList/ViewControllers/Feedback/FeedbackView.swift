//
//  FeedbackView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.05.2023.
//

import UIKit

final class FeedbackView: UIView {
    
    var tappedStar: ((Int) -> Void)?
    var tappedNextButton: ((FeedbackViewModel.State, String) -> Void)?
    
    private lazy var titleGradeLabel: UILabel = {
        createLabel(text: R.string.localizable.yourExperience(), isHeavyFont: true)
    }()
    
    private lazy var titleSuggestionsLabel: UILabel = {
        createLabel(text: R.string.localizable.howCanWeImprove(), isHeavyFont: false)
    }()
    
    private lazy var descSuggestionsLabel: UILabel = {
        createLabel(text: R.string.localizable.giveSuggestions(), isHeavyFont: true)
    }()
    
    private lazy var titleWriteReviewLabel: UILabel = {
        createLabel(text: R.string.localizable.thanksForYourFeedback(), isHeavyFont: true)
    }()
    
    private lazy var descWriteReviewLabel: UILabel = {
        createLabel(text: R.string.localizable.youCanAlsoWriteAReview(), isHeavyFont: false)
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "1A645A")
        button.setTitle(R.string.localizable.send(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.semanticContentAttribute = .forceRightToLeft
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.SFProRounded.semibold(size: 17).font
        textView.backgroundColor = UIColor(hex: "E0FFFB")
        textView.tintColor = .black
        textView.textColor = .black
        textView.layer.cornerRadius = 4
        textView.layer.cornerCurve = .continuous
        return textView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 17.25
        return stackView
    }()
    
    private var starButtons: [UIButton] = []
    private var state: FeedbackViewModel.State = .grade
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        setupStackView()
        makeConstraints()
    }
    
    func updateView(by state: FeedbackViewModel.State) {
        self.state = state
        hideLabel(by: state)
        button.isHidden = state == .grade
        textView.isHidden = !(state == .suggestions)
        stackView.isHidden = state == .suggestions
        switch state {
        case .grade:
            break
        case .suggestions:
            textView.becomeFirstResponder()
            button.setTitle(R.string.localizable.send() + "  ", for: .normal)
            button.setImage(R.image.send_feedback(), for: .normal)
            button.snp.makeConstraints {
                $0.width.greaterThanOrEqualTo(110)
                $0.bottom.equalToSuperview().offset(-20)
            }
        case .writeReview:
            stackView.isUserInteractionEnabled = false
            button.setTitle(R.string.localizable.writeAReview() + "  ", for: .normal)
            button.setImage(R.image.review_feedback(), for: .normal)
            button.snp.makeConstraints {
                $0.width.greaterThanOrEqualTo(180)
                $0.bottom.equalToSuperview().offset(-32)
            }
            
            stackView.snp.updateConstraints {
                $0.top.equalToSuperview().offset(14)
            }
        }
    }
    
    private func createLabel(text: String, isHeavyFont: Bool) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor(hex: "1A645A")
        label.text = text
        label.font = isHeavyFont ? UIFont.SFProRounded.heavy(size: 19).font
                                 : UIFont.SFProRounded.semibold(size: 17).font
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private func setupStackView() {
        for index in 0...4 {
            let button = UIButton()
            button.tag = index
            button.setImage(R.image.star_inactive(), for: .normal)
            button.addTarget(self, action: #selector(tappedStarButton(sender:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            starButtons.append(button)
        }
    }
    
    private func hideLabel(by state: FeedbackViewModel.State) {
        titleGradeLabel.isHidden = !(state == .grade)
        titleSuggestionsLabel.isHidden = !(state == .suggestions)
        descSuggestionsLabel.isHidden = !(state == .suggestions)
        titleWriteReviewLabel.isHidden = !(state == .writeReview)
        descWriteReviewLabel.isHidden = !(state == .writeReview)
    }
    
    @objc
    private func tappedStarButton(sender: UIButton) {
        starButtons.forEach {
            if $0.tag <= sender.tag {
                $0.setImage(R.image.star_active(), for: .normal)
            }
        }
        tappedStar?(sender.tag)
    }
    
    @objc
    private func tappedButton() {
        tappedNextButton?(state, textView.text)
    }
    
    private func makeConstraints() {
        self.addSubviews([titleGradeLabel, titleSuggestionsLabel,
                          descSuggestionsLabel, titleWriteReviewLabel, descWriteReviewLabel])
        self.addSubviews([button, textView, stackView])
        
        makeLabelsConstraints()
        
        button.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(83)
            $0.leading.equalToSuperview().offset(17)
            $0.trailing.equalToSuperview().offset(-17)
            $0.height.equalTo(95)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(147)
            $0.leading.equalToSuperview().offset(11)
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(38)
        }
    }
    
    private func makeLabelsConstraints() {
        titleGradeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(41)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        titleSuggestionsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        descSuggestionsLabel.snp.makeConstraints {
            $0.top.equalTo(titleSuggestionsLabel.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        titleWriteReviewLabel.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(23)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        descWriteReviewLabel.snp.makeConstraints {
            $0.top.equalTo(titleWriteReviewLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview()
        }
    }
}
