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
    
    weak var delegate: CustomSegmentedControlViewDelegate?
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.primaryLight()
        view.layer.cornerRadius = 12
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    private var buttonViews: [SegmentView] = []
    
    var selectedSegmentIndex: Int = 0 {
        didSet {
            buttonViews.forEach { view in
                view.configureState(state: view.segmentButton.tag == selectedSegmentIndex ? .select : .unselect)
            }
        }
    }
    
    var segmentedBackgroundColor: UIColor? = R.color.primaryLight() {
        didSet { backgroundView.backgroundColor = segmentedBackgroundColor }
    }
    
    var segmentedCornerRadius: CGFloat = 12 {
        didSet { backgroundView.layer.cornerRadius = segmentedCornerRadius }
    }
    
    init(items: [String], select: SegmentView.Configuration, unselect: SegmentView.Configuration) {
        super.init(frame: .zero)
        setupButtons(titles: items, select: select, unselect: unselect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButtons(titles: [String], select: SegmentView.Configuration, unselect: SegmentView.Configuration) {
        buttonViews.removeAll()
        
        titles.enumerated().forEach { index, title in
            let view = SegmentView(select: select, unselect: unselect)
            view.segmentButton.tag = index
            view.segmentButton.setTitle(title, for: .normal)
            view.segmentButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
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
            $0.leading.top.equalToSuperview().offset(4)
            $0.center.equalToSuperview()
        }
    }
}

class SegmentView: UIView {
    
    struct Configuration {
        let titleColor: UIColor?
        let font: UIFont
        let borderColor: CGColor
        let borderWidth: CGFloat
        let backgroundColor: UIColor?
    }
    
    enum State {
        case select
        case unselect
    }
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        view.addCustomShadow(color: UIColor(hex: "858585"), opacity: 0.1, radius: 6, offset: CGSize(width: 0, height: 4))
        return view
    }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        view.addCustomShadow(color: UIColor(hex: "484848"), opacity: 0.15, radius: 1, offset: CGSize(width: 0, height: 0.5))
        return view
    }()
    
    lazy var segmentButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.SFPro.bold(size: 18).font
        return button
    }()
    
    private let select: Configuration
    private let unselect: Configuration
    
    init(select: Configuration, unselect: Configuration) {
        self.select = select
        self.unselect = unselect
        super.init(frame: .zero)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureState(state: State) {
        segmentButton.setTitleColor(state == .select ? select.titleColor : unselect.titleColor, for: .normal)
        segmentButton.titleLabel?.font = state == .select ? select.font : unselect.font
        backgroundView.layer.borderWidth = state == .select ? select.borderWidth : unselect.borderWidth
        shadowView.backgroundColor = state == .select ? select.backgroundColor : unselect.backgroundColor
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.backgroundColor = state == .select ? self.select.backgroundColor
                                                                   : self.unselect.backgroundColor
            self.backgroundView.layer.borderColor = state == .select ? self.select.borderColor
                                                                     : self.unselect.borderColor
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([shadowView, backgroundView])
        backgroundView.addSubview(segmentButton)
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        shadowView.snp.makeConstraints {
            $0.edges.equalTo(backgroundView)
        }
        
        segmentButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
