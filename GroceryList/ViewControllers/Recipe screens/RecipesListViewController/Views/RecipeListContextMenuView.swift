//
//  RecipeListContextMenuView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.06.2023.
//

import UIKit

protocol RecipeListContextMenuViewDelegate: AnyObject {
    func selectedState(state: RecipeListContextMenuView.MainMenuState)
}

class RecipeListContextMenuView: UIView {
    
    weak var delegate: RecipeListContextMenuViewDelegate?
    
    enum MainMenuState: Int, CaseIterable {
        case addToShoppingList
        case addToMealPlan
        case addToFavorites
        case addToCollection
        case edit
//        case makeCopy
//        case sendTo
//        case removeFromCollection
        case delete

        var title: String {
            switch self {
            case .addToShoppingList:    return R.string.localizable.addtoshoppinglisT().firstCharacterUpperCase()
            case .addToMealPlan:        return R.string.localizable.addToMealPlan()
            case .addToFavorites:       return R.string.localizable.addToFavorites()
            case .addToCollection:      return R.string.localizable.addToCollection()
            case .edit:                 return R.string.localizable.edit()
            case .delete:               return R.string.localizable.delete()
            }
        }
        
        var image: UIImage? {
            switch self {
            case .addToShoppingList:    return R.image.contextMenuAddToCart()
            case .addToMealPlan:        return R.image.contextMenuAddToMealPlan()
            case .addToFavorites:       return R.image.contextMenuFavorite()
            case .addToCollection:      return R.image.contextMenuCollection()
            case .edit:                 return R.image.contextMenuEdit()
            case .delete:               return R.image.trash_red()
            }
        }
        
        var message: String {
            switch self {
            case .addToFavorites:       return R.string.localizable.favorites()
            default:                    return ""
            }
        }
    }
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 1
        return stackView
    }()
    
    private var mainColor: Theme?
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
    
    func setupMenuFunctions(isDefaultRecipe: Bool, isFavorite: Bool) {
        guard isDefaultRecipe else {
            setupMenuStackView(isFavorite: isFavorite)
            return
        }
        
        allMenuFunctions.removeAll { $0 == .edit }
        setupMenuStackView(isFavorite: isFavorite)
    }
    
    func removeDeleteButton() {
        allMenuFunctions.removeAll { $0 == .delete }
        stackView.arrangedSubviews.forEach {
            if $0.tag == MainMenuState.delete.rawValue {
                stackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        }
    }
    
    func configure(color: Theme) {
        mainColor = color
        stackView.backgroundColor = color.medium
        self.layer.borderColor = color.medium.cgColor
        
        setupMenuStackView(isFavorite: false)
    }
    
    func removeSelected() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.stackView.arrangedSubviews.forEach {
                $0.backgroundColor = .white
                ($0 as? ContextMenuSubView)?.configure(color: self.mainColor?.dark ?? .black)
            }
        }
    }
    
    private func setup() {
        self.layer.cornerRadius = 8
        self.layer.cornerCurve = .continuous
        self.clipsToBounds = true
        self.layer.borderWidth = 2
        
        makeConstraints()
    }
    
    func setupMenuStackView(isFavorite: Bool) {
        stackView.removeAllArrangedSubviews()
        
        allMenuFunctions.forEach { state in
            let view = ContextMenuSubView()
            let color = (state == .delete ? R.color.attention() : mainColor?.dark) ?? .black
            if isFavorite && state == .addToFavorites {
                view.configure(title: R.string.localizable.deleteFromFavorites(), image: state.image, color: color)
            } else {
                view.configure(title: state.title, image: state.image, color: color)
            }
            
            view.tag = state.rawValue
            stackView.addArrangedSubview(view)
            
            view.onViewAction = { [weak self] in
                self?.markAsSelected(state, activeColor: self?.mainColor?.dark ?? .black)
                self?.analytics(state: state)
                self?.delegate?.selectedState(state: state)
            }
        }
    }
    
    private func markAsSelected(_ state: MainMenuState, activeColor: UIColor) {
        stackView.arrangedSubviews.forEach { view in
            let contextMenuColor = view.tag == state.rawValue ? .white : activeColor
            view.backgroundColor = view.tag == state.rawValue ? activeColor : .white
            (view as? ContextMenuSubView)?.configure(color: contextMenuColor)
        }
    }
    
    private func analytics(state: MainMenuState) {
        switch state {
        case .addToShoppingList:
            AmplitudeManager.shared.logEvent(.recipeMenuAddToShoppingList)
        case .addToMealPlan:
            break
        case .addToFavorites:
            AmplitudeManager.shared.logEvent(.recipeMenuAddToFav)
        case .addToCollection:
            AmplitudeManager.shared.logEvent(.recipeMenuAddToCollection)
        case .edit:
            AmplitudeManager.shared.logEvent(.recipeMenuEditRecipe)
        case .delete:
            break
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
