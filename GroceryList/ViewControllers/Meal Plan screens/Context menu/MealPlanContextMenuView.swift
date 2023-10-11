//
//  MealPlanContextMenuView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 28.09.2023.
//

import UIKit

protocol MealPlanContextMenuViewDelegate: AnyObject {
    func selectedState(state: MealPlanContextMenuView.MainMenuState)
}

class MealPlanContextMenuView: UIView {
    
    weak var delegate: MealPlanContextMenuViewDelegate?
    
    enum MainMenuState: Int, CaseIterable {
        case addToShoppingList
        case moveCopyDelete
        case editLabels
//        case share
        case sendTo

        var title: String {
            switch self {
            case .addToShoppingList:    return R.string.localizable.addtoshoppinglisT()
            case .moveCopyDelete:       return R.string.localizable.moveCopyDelete()
            case .editLabels:           return R.string.localizable.editLabels()
//            case .share:                return R.string.localizable.share()
            case .sendTo:               return R.string.localizable.sendTo()
            }
        }
        
        var image: UIImage? {
            switch self {
            case .addToShoppingList:    return R.image.contextMenuAddToCart()
            case .moveCopyDelete:       return R.image.contextMenuEdit()
            case .editLabels:           return R.image.contextMenuMarker()
//            case .share:                return R.image.contextMenuAddUser()
            case .sendTo:               return R.image.contextMenuSend()
            }
        }
    }
    
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
    
    var requiredHeight: Int {
        stackView.arrangedSubviews.count * 56
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureSharing(state: SharingView.SharingState, color: UIColor, images: [String?]) {
        stackView.arrangedSubviews.forEach { view in
//            if view.tag == MainMenuState.share.rawValue {
//                (view as? ContextMenuSubView)?.setupSharingView(state: state, color: color, images: images)
//            }
        }
    }
    
    private func setup() {
        self.setCornerRadius(8)
        self.addDefaultShadowForPopUp()
        
        setupMenuStackView()
        makeConstraints()
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
                self?.delegate?.selectedState(state: state)
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
    
    private func makeConstraints() {
        self.addSubview(contentView)
        contentView.addSubviews([stackView])
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
