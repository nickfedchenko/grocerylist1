//
//  AddIngredientsToListViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 29.09.2023.
//

import UIKit

class AddIngredientsToListViewController: UIViewController {

    private let viewModel: AddIngredientsToListViewModel
    
    private let grabberBackgroundView = UIView()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "3C3C43", alpha: 0.3)
        view.setCornerRadius(2.5)
        return view
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(R.image.greenArrowBack()?.withTintColor(UIColor(hex: "045C5C")), for: .normal)
        button.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "045C5C")
        button.setTitle("Done".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.heavy(size: 17).font
        button.addTarget(self, action: #selector(tappedDoneButton), for: .touchUpInside)
        button.contentEdgeInsets.left = 20
        button.contentEdgeInsets.right = 20
        button.layer.cornerRadius = 20
        button.layer.cornerCurve = .continuous
        button.layer.maskedCorners = [.layerMinXMaxYCorner]
        return button
    }()
    
    private lazy var calendarView: CalendarView = {
        let view = CalendarView()
        view.delegate = self
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = compositionalLayout
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset.bottom = 110
        collectionView.contentInset.top = 16
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.register(classCell: MealPlanCell.self)
        collectionView.registerHeader(classHeader: MealPlanHeaderCell.self)
        return collectionView
    }()
    
    private lazy var compositionalLayout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .estimated(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .estimated(1))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            let header = self.createSectionHeader
            section.boundarySupplementaryItems = [header]
            return section
        }
        return layout
    }()
    
    private lazy var createSectionHeader: NSCollectionLayoutBoundarySupplementaryItem = {
        let layoutHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .estimated(1))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return layoutSectionHeader
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<MealPlanSection, MealPlanCellModel>?
    
    init(viewModel: AddIngredientsToListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = R.color.background()
        grabberBackgroundView.backgroundColor = R.color.background()?.withAlphaComponent(0.95)
        
        makeConstraints()
    }

    @objc
    private func tappedBackButton() {
        
    }
    
    @objc
    private func tappedDoneButton() {
        
    }
    
    private func makeConstraints() {
        self.view.addSubviews([collectionView, grabberBackgroundView, grabberView, menuButton, doneButton])
        
        grabberBackgroundView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(menuButton.snp.bottom).offset(8)
        }
        
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(5)
            $0.width.equalTo(36)
        }
        
        menuButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalToSuperview().offset(4)
            $0.height.equalTo(40)
            $0.width.greaterThanOrEqualTo(96)
        }
        
        doneButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.greaterThanOrEqualTo(120)
        }
        doneButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        doneButton.setContentHuggingPriority(.init(1000), for: .horizontal)
    }

}

extension AddIngredientsToListViewController: UICollectionViewDelegate {
    
}

extension AddIngredientsToListViewController: CalendarViewDelegate {
    func selectedDate(_ date: Date) {
        
    }
    
    func getLabelColors(by date: Date) -> [UIColor] {
        []
    }
    
    func pageDidChange() {
        
    }
}
