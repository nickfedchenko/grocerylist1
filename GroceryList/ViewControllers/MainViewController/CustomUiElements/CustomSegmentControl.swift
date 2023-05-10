//
//  CustomSegmentControl.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import UIKit

protocol CustomSegmentedControlViewDelegate: AnyObject {
    func segmentChanged(_ selectedSegmentIndex: Int)
}

final class CustomSegmentedControlView: UIView {
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#CDE8E4")
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    private var buttonViews: [ViewWithButton] = []
    
    weak var delegate: CustomSegmentedControlViewDelegate?
    var selectedSegmentIndex: Int = 0 {
        didSet {
            buttonViews.forEach { view in
                view.configureState(state: view.button.tag == selectedSegmentIndex ? .select : .unselect)
            }
        }
    }
    
    init(items: [String]) {
        super.init(frame: .zero)
        setupButtons(titles: items)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButtons(titles: [String]) {
        buttonViews.removeAll()
        
        titles.enumerated().forEach { index, title in
            let view = ViewWithButton()
            view.button.tag = index
            view.button.setTitle(title, for: .normal)
            view.button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            buttonViews.append(view)
        }
    }
    
    private func setup() {
        buttonViews.forEach {
            stackView.addArrangedSubview($0)
        }
        selectedSegmentIndex = 0
        makeConstraints()
    }
    
    @objc
    private func buttonAction(_ sender: UIButton) {
        delegate?.segmentChanged(sender.tag)
    }
    
    private func makeConstraints() {
        self.addSubview(backgroundView)
        backgroundView.addSubview(stackView)
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(2)
            $0.center.equalToSuperview()
        }
    }
}

private class ViewWithButton: UIView {
    
    enum ViewWithButtonState {
        case select
        case unselect
        
        var titleColor: UIColor {
            switch self {
            case .select: return UIColor(hex: "#1A645A")
            case .unselect: return UIColor(hex: "#617774")
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .select: return .white
            case .unselect: return .clear
            }
        }
    }
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.layer.cornerCurve = .continuous
        view.addCustomShadow(opacity: 0.04, radius: 1, offset: CGSize(width: 0, height: 3))
        return view
    }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.cornerCurve = .continuous
        view.addCustomShadow(radius: 4, offset: CGSize(width: 0, height: 3))
        return view
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.titleLabel?.font = R.font.sfProRoundedBold(size: 17)
        return button
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureState(state: ViewWithButtonState) {
        button.setTitleColor(state.titleColor, for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.backgroundColor = state.backgroundColor
        }
        shadowView.backgroundColor = state.backgroundColor
    }
    
    private func makeConstraints() {
        self.addSubviews([shadowView, backgroundView])
        backgroundView.addSubview(button)
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        shadowView.snp.makeConstraints {
            $0.edges.equalTo(backgroundView)
        }
        
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
