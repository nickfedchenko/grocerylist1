//
//  PantryEditMenuView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 30.05.2023.
//

import UIKit

protocol PantryEditMenuViewDelegate: AnyObject {
    func selectedState(state: PantryEditMenuView.MenuState)
}

final class PantryEditMenuView: UIView {
    
    weak var delegate: PantryEditMenuViewDelegate?
    
    enum MenuState: Int, CaseIterable {
        case edit
        case delete
        
        var title: String {
            switch self {
            case .edit:     return R.string.localizable.editList()
            case .delete:   return R.string.localizable.delete()
            }
        }
        
        var image: UIImage? {
            switch self {
            case .edit:     return R.image.listSettings()
            case .delete:   return R.image.trash_red()
            }
        }
    }
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = R.color.lightGray()
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.layer.cornerRadius = 8
        stackView.layer.masksToBounds = true
        stackView.clipsToBounds = true
        return stackView
    }()
    
    private var theme: Theme?
    
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
    
    func setupColor(theme: Theme) {
        self.theme = theme
        DispatchQueue.main.async {
            self.layer.borderColor = theme.medium.cgColor
            self.stackView.arrangedSubviews.forEach { view in
                if view.tag == MenuState.edit.rawValue {
                    (view as? MainScreenMenuSubView)?.configure(color: theme.dark)
                }
            }
        }
    }
    
    func markAsSelected(_ state: MenuState) {
        stackView.arrangedSubviews.forEach { view in
            view.backgroundColor = theme?.light
        }
    }
    
    func removeSelected() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.stackView.arrangedSubviews.forEach {
                $0.backgroundColor = .white
            }
        }
    }
    
    private func setup() {
        self.layer.cornerRadius = 8
        self.layer.cornerCurve = .continuous
        self.layer.borderWidth = 2
        self.addDefaultShadowForPopUp()
        
        MenuState.allCases.forEach { state in
            let view = MainScreenMenuSubView()
            view.configure(title: state.title, image: state.image)
            view.tag = state.rawValue
            if state == .delete {
                view.configure(color: R.color.attention())
            }
            stackView.addArrangedSubview(view)
            
            view.onViewAction = { [weak self] in
                self?.markAsSelected(state)
                self?.delegate?.selectedState(state: state)
            }
        }
        
        makeConstraints()
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
    
    func configure(color: UIColor?) {
        titleLabel.textColor = color
        imageView.image = imageView.image?.withTintColor(color ?? .black)
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
        
        imageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(8)
            $0.height.width.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing)
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}
