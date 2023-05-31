//
//  MainScreenMenuView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 28.02.2023.
//

import UIKit

final class MainScreenMenuView: UIView {
    
    var selectedState: ((MainMenuState) -> Void)?
    
    enum MainMenuState: Int, CaseIterable {
        case createRecipe
//        case importRecipe
        case createCollection
        
        var title: String {
            switch self {
            case .createRecipe:     return R.string.localizable.createRecipe()
//            case .importRecipe:     return R.string.localizable.importRecipe()
            case .createCollection: return R.string.localizable.createCollection()
            }
        }
        
        var image: UIImage? {
            switch self {
            case .createRecipe:     return R.image.recipe()
//            case .importRecipe:     return R.image.web()
            case .createCollection: return R.image.collection()
            }
        }
    }
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#CAE2DF")
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = UIColor(hex: "#CAE2DF")
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 1
        return stackView
    }()
    
    var requiredHeight: Int {
        stackView.arrangedSubviews.count * 62
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        self.layer.cornerRadius = 12
        self.layer.cornerCurve = .continuous
        self.clipsToBounds = true
        
        MainMenuState.allCases.forEach { state in
            let view = MainScreenMenuSubView()
            view.configure(title: state.title, image: state.image)
            view.tag = state.rawValue
            stackView.addArrangedSubview(view)
            
            view.onViewAction = { [weak self] in
                self?.markAsSelected(state)
                self?.selectedState?(state)
            }
        }
        
        makeConstraints()
    }
    
    func markAsSelected(_ state: MainMenuState) {
        stackView.arrangedSubviews.forEach { view in
            view.backgroundColor = view.tag == state.rawValue ? R.color.action() : .white
        }
    }
    
    func removeSelected() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.stackView.arrangedSubviews.forEach { $0.backgroundColor = .white }
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

private final class MainScreenMenuSubView: UIView {
    
    var onViewAction: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = R.color.primaryDark()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(title: String, image: UIImage?) {
        titleLabel.text = title
        imageView.image = image
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
            $0.top.equalToSuperview().offset(19)
            $0.height.equalTo(24)
        }
        
        imageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(11)
            $0.height.width.equalTo(40)
        }
    }
}
