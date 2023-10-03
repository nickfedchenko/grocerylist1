//
//  AddIngredientsToListMenuView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.10.2023.
//

import UIKit

class AddIngredientsToListMenuView: UIView {

    enum MainMenuState: Int, CaseIterable {
        case sortByRecipe
        case sortByCategory
        case addAllToList

        var title: String {
            switch self {
            case .sortByRecipe:     return R.string.localizable.sortByRecipe()
            case .sortByCategory:   return R.string.localizable.sortByCategory()
            case .addAllToList:     return R.string.localizable.addAllToList() 
            }
        }
        
        var image: UIImage? {
            switch self {
            case .sortByRecipe:     return R.image.sortRecipe()
            case .sortByCategory:   return R.image.category()
            case .addAllToList:     return R.image.addAllToList()
            }
        }
    }
    
    var selectState: ((MainMenuState) -> Void)?
    var fadeOutView: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadius(8)
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.backgroundColor = R.color.lightGray()
        return stackView
    }()
    
    private let mainColor = R.color.primaryDark() ?? .black
    private var allMenuFunctions = MainMenuState.allCases
    
    private var type: AddIngredientsToListType = .recipe
    private var requiredHeight: Int {
        stackView.arrangedSubviews.count * 56
    }
    
    init(type: AddIngredientsToListType) {
        self.type = type
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(type: AddIngredientsToListType) {
        self.type = type
        let deleteState: MainMenuState = type == .category ? .sortByCategory : .sortByRecipe
        allMenuFunctions = MainMenuState.allCases
        allMenuFunctions.removeAll { $0 == deleteState }
        setupMenuStackView()
    }
    
    private func setup() {
        self.setCornerRadius(8)
        self.addDefaultShadowForPopUp()
        
        configure(type: type)
        makeConstraints()
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        tapOnView.delegate = self
        self.addGestureRecognizer(tapOnView)
    }
    
    private func setupMenuStackView() {
        stackView.removeAllArrangedSubviews()
        
        allMenuFunctions.forEach { state in
            let view = ContextMenuSubView()
            view.configure(title: state.title.firstCharacterUpperCase(),
                           image: state.image,
                           color: mainColor)
            view.tag = state.rawValue
            
            stackView.addArrangedSubview(view)
            
            view.onViewAction = { [weak self] in
                self?.markAsSelected(state)
                self?.selectState?(state)
                self?.fadeOutView?()
            }
        }
    }
    
    private func markAsSelected(_ state: MainMenuState) {
        stackView.arrangedSubviews.forEach { view in
            let contextMenuColor = view.tag == state.rawValue ? .white : mainColor
            view.backgroundColor = view.tag == state.rawValue ? mainColor : .white
            (view as? ContextMenuSubView)?.configure(color: contextMenuColor)
        }
    }
    
    @objc
    private func tappedOnView() {
        fadeOutView?()
    }
    
    private func makeConstraints() {
        self.addSubviews([containerView, contentView])
        contentView.addSubviews([stackView])
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.height.greaterThanOrEqualTo(requiredHeight)
            $0.width.equalTo(250)
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AddIngredientsToListMenuView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.contentView) ?? false)
    }
}
