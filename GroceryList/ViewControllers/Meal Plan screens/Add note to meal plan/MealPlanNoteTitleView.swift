//
//  MealPlanNoteTitleView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 25.09.2023.
//

import UIKit

protocol MealPlanNoteTitleViewDelegate: AnyObject {
    func titleInput()
}

class MealPlanNoteTitleView: UIView {
    
    weak var delegate: MealPlanNoteTitleViewDelegate?
    
    var title: String {
        titleView.text
    }
    
    var details: String {
        detailsView.text
    }
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadius(8)
        view.addShadow(color: .init(hex: "858585"), opacity: 0.1,
                       radius: 6, offset: .init(width: 0, height: 4))
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = R.color.primaryLight()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        stackView.spacing = 1
        
        stackView.setCornerRadius(8)
        stackView.clipsToBounds = true
        return stackView
    }()

    private let titleView = NoteTitleView(state: .title)
    private let detailsView = NoteTitleView(state: .details)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
        
        stackView.addArrangedSubview(titleView)
        stackView.addArrangedSubview(detailsView)
        
        titleView.textView.becomeFirstResponder()
        titleView.textViewReturnPressed = { [weak self] in
            self?.detailsView.textView.becomeFirstResponder()
        }
        titleView.textInput = { [weak self] in
            self?.delegate?.titleInput()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, details: String?) {
        titleView.configure(title)
        if let details {
            detailsView.configure(details)
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([shadowView])
        shadowView.addSubview(stackView)

        shadowView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

private class NoteTitleView: UIView {

    enum State {
        case title
        case details
        
        var placeholder: String {
            switch self {
            case .title:    return "Title"
            case .details:  return "Details"
            }
        }
        
        var font: UIFont {
            switch self {
            case .title:    return UIFont.SFPro.semibold(size: 16).font
            case .details:  return UIFont.SFPro.regular(size: 16).font
            }
        }
    }
    
    var textViewReturnPressed: (() -> Void)?
    var textInput: (() -> Void)?
    
    var text: String {
        textView.text
    }
    
    lazy var textView: TextViewWithPlaceholder = {
        let textView = TextViewWithPlaceholder()
        textView.delegate = self
        textView.setPlaceholder(placeholder: state.placeholder,
                                textColor: R.color.lightGray(),
                                font: .SFPro.medium(size: 16).font,
                                frame: CGPoint(x: 5, y: (textView.font?.pointSize ?? 16) / 2))
        textView.font = state.font
        textView.textColor = .black
        textView.tintColor = R.color.primaryDark()
        textView.isScrollEnabled = false
        return textView
    }()

    private let state: State
    
    init(state: State) {
        self.state = state
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        
        if state == .title {
            textView.returnKeyType = .next
        }
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ text: String) {
        textView.text = text
        textView.checkPlaceholder()
    }
    
    private func makeConstraints() {
        self.addSubviews([textView])
        
        self.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(40)
        }
        
        textView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(2)
            $0.trailing.equalToSuperview().offset(-8)
            $0.leading.equalToSuperview().offset(16)
        }
    }
}

extension NoteTitleView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textInput?()
        self.textView.checkPlaceholder()
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            textViewReturnPressed?()
            return state == .details
        }
        return true
    }
}
