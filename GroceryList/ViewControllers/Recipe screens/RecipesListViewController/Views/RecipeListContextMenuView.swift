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
//        case addToIWillCookIt
        case addToFavorites
        case addToCollection
        case edit
//        case makeCopy
//        case sendTo
//        case removeFromCollection

        var title: String {
            switch self {
            case .addToShoppingList:    return "addToShoppingList"
            case .addToFavorites:       return "addToFavorites"
            case .addToCollection:      return "addToCollection"
            case .edit:                 return "edit"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .addToShoppingList:    return nil
            case .addToFavorites:       return nil
            case .addToCollection:      return nil
            case .edit:                 return nil
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
    
    func configure(color: Theme) {
        mainColor = color
        stackView.backgroundColor = color.medium
        self.layer.borderColor = color.medium.cgColor
        
        stackView.removeAllArrangedSubviews()
        
        MainMenuState.allCases.forEach { state in
            let view = RecipeListContextMenuSubView()
            view.configure(title: state.title, image: state.image, color: color.dark)
            view.tag = state.rawValue
            stackView.addArrangedSubview(view)
            
            view.onViewAction = { [weak self] in
                self?.markAsSelected(state, activeColor: color.dark)
                self?.delegate?.selectedState(state: state)
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
    
    func markAsSelected(_ state: MainMenuState, activeColor: UIColor) {
        stackView.arrangedSubviews.forEach { view in
            let contextMenuColor = view.tag == state.rawValue ? .white : activeColor
            view.backgroundColor = view.tag == state.rawValue ? activeColor : .white
            (view as? RecipeListContextMenuSubView)?.configure(color: contextMenuColor)
        }
    }
    
    func removeSelected() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.stackView.arrangedSubviews.forEach {
                $0.backgroundColor = .white
                ($0 as? RecipeListContextMenuSubView)?.configure(color: self.mainColor?.dark ?? .black)
            }
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

private final class RecipeListContextMenuSubView: UIView {
    
    var onViewAction: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var mainColor: UIColor = .black
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(color: UIColor) {
        titleLabel.textColor = color
        imageView.image = imageView.image?.withTintColor(color)
    }
    
    func configure(title: String, image: UIImage?, color: UIColor) {
        titleLabel.text = title
        titleLabel.textColor = color
        
        imageView.image = image?.withTintColor(color)
    }
    
    private func setup() {
        self.backgroundColor = .white
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(onViewTapped))
        self.addGestureRecognizer(tapOnView)
        
        makeConstraints()
    }
    
    @objc
    private func onViewTapped() {
        onViewAction?()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, imageView])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(imageView.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(33)
        }
        
        imageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(11)
            $0.height.width.equalTo(40)
        }
    }
}
