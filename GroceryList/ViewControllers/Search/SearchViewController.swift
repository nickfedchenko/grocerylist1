//
//  SearchViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.03.2023.
//

import UIKit

class SearchViewController: UIViewController {

    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.SFPro.medium(size: 16).font
        textField.tintColor = R.color.primaryDark()
        textField.backgroundColor = .clear
        textField.textColor = .black
        return textField
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset.top = 142
        collectionView.contentInset.bottom = 250
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    
    lazy var searchView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .white
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle(R.string.localizable.cancel(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.bold(size: 15).font
        button.setTitleColor(R.color.primaryDark(), for: .normal)
        button.addTarget(self, action: #selector(tappedCancelButton), for: .touchUpInside)
        button.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        return button
    }()
    
    lazy var crossCleanerButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.xMarkInput(), for: .normal)
        button.addTarget(self, action: #selector(tappedCleanerButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: NSCollectionLayoutDimension.estimated(64)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8

        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(0)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: "SectionHeaderElementKind",
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    let navigationView = UIView()
    let topSafeAreaView = UIView()
    let iconImageView = UIImageView(image: R.image.searchButtonImage())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    func animationAppear() {
        searchView.alpha = 0
        searchTextField.alpha = 0
        cancelButton.alpha = 0
        
        searchView.transform = CGAffineTransform(scaleX: 0, y: 1)
            .translatedBy(x: self.view.bounds.width - 100,
                          y: navigationView.bounds.midY)
        iconImageView.transform = CGAffineTransform(translationX: self.view.bounds.width - 96,
                                                    y: navigationView.bounds.midY - 4)
        
        UIView.animate(withDuration: 0.4) {
            self.searchView.alpha = 1.0
            self.searchView.transform = .identity
            self.iconImageView.transform = .identity
        } completion: { _ in
            self.searchTextField.alpha = 1
            self.cancelButton.alpha = 1
        }
    }
    
    func setSearchPlaceholder(_ placeholder: String) {
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: " " + placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: R.color.mediumGray() ?? UIColor(hex: "#7A948F")]
        )
    }
    
    func setup() {
        self.view.backgroundColor = UIColor(hex: "#E5F5F3")
        searchTextField.becomeFirstResponder()
        navigationView.backgroundColor = UIColor(hex: "#E5F5F3").withAlphaComponent(0.9)
        topSafeAreaView.backgroundColor = UIColor(hex: "#E5F5F3").withAlphaComponent(0.9)
        
        setupCollectionView()
        makeConstraints()
    }
    
    func setupCollectionView() { }
    
    @objc
    func tappedCancelButton() { }
    
    @objc
    func tappedCleanerButton() {
        Vibration.rigid.vibrate()
        searchTextField.text = ""
    }
    
    func setCleanerButton(isVisible: Bool) {
        crossCleanerButton.isHidden = !isVisible
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc
    func dismissKeyboard() {
        guard let gestureRecognizers = self.view.gestureRecognizers else {
            return
        }
        gestureRecognizers.forEach { $0.isEnabled = false }
        self.view.endEditing(true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([collectionView, topSafeAreaView, navigationView])
        navigationView.addSubviews([searchView, iconImageView, searchTextField, crossCleanerButton, cancelButton])
        
        topSafeAreaView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        navigationView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        searchView.snp.makeConstraints {
            $0.top.equalTo(navigationView)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        iconImageView.snp.makeConstraints {
            $0.leading.centerY.equalTo(searchView)
            $0.width.height.equalTo(40)
        }
        
        searchTextField.snp.makeConstraints {
            $0.centerY.equalTo(searchView)
            $0.leading.equalTo(iconImageView.snp.trailing)
            $0.trailing.equalTo(crossCleanerButton.snp.leading).offset(-7)
            $0.height.equalTo(28)
        }
        
        crossCleanerButton.snp.makeConstraints {
            $0.centerY.equalTo(searchView)
            $0.trailing.equalTo(cancelButton.snp.leading).offset(-12)
            $0.height.width.equalTo(24)
        }
        
        cancelButton.snp.makeConstraints {
            $0.centerY.equalTo(searchView)
            $0.trailing.equalTo(searchView).offset(-12)
            $0.height.equalTo(24)
        }
    }
}
