//
//  AddIngredientsToListViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 29.09.2023.
//

import SnapKit
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 16).font
        label.textColor = R.color.darkGray()
        label.text = R.string.localizable.addToShoppingList()
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        let color = R.color.primaryDark() ?? UIColor(hex: "045C5C")
        button.backgroundColor = .clear
        button.setImage(R.image.recipe_menu(), for: .normal)
        button.addTarget(self, action: #selector(tappedMenuButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "045C5C")
        button.setTitle(R.string.localizable.done(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.heavy(size: 17).font
        button.addTarget(self, action: #selector(tappedDoneButton), for: .touchUpInside)
        button.contentEdgeInsets.left = 20
        button.contentEdgeInsets.right = 20
        button.setCornerRadius(20)
        button.layer.maskedCorners = [.layerMinXMaxYCorner]
        return button
    }()
    
    private lazy var datesButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(R.color.primaryDark(), for: .normal)
        button.layer.borderColor = R.color.primaryDark()?.cgColor
        button.layer.borderWidth = 1
        button.contentEdgeInsets.left = 8
        button.contentEdgeInsets.right = 8
        button.setCornerRadius(8)
        button.addTarget(self, action: #selector(tappedDatesButton), for: .touchUpInside)
        button.setTitle(viewModel.dates(), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.medium(size: 16).font
        return button
    }()
    
    private let menuView = AddIngredientsToListMenuView(type: .recipe)
    private let calendarView = AddIngredientsToListCalendarView()
    private let destinationListView = AddIngredientsToDestinationListView()
    
    private lazy var collectionView: UICollectionView = {
        let layout = compositionalLayout
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.selectionFollowsFocus = false
        collectionView.contentInset.bottom = 120
        collectionView.contentInset.top = 84
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.register(classCell: AddIngredientsToListCell.self)
        collectionView.registerHeader(classHeader: AddIngredientsToListHeaderCell.self)
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
    
    private var dataSource: UICollectionViewDiffableDataSource<AddIngredientsToListHeaderModel, IngredientForMealPlan>?
    private var dateButtonTopConstraint: Constraint?
    private var dateButtonBottomConstraint: Constraint?
    
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
        
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.datesButton.setTitle(self?.viewModel.dates(), for: .normal)
                self?.destinationListView.configure(list: self?.viewModel.getDestinationListTitle() ?? "")
                self?.reloadDataSource()
            }
        }
        viewModel.updateDestinationList = { [weak self] in
            self?.destinationListView.configure(list: self?.viewModel.getDestinationListTitle() ?? "")
        }
        viewModel.getImageData = { [weak self] model in
            guard let index = self?.dataSource?.indexPath(for: model),
                  let cell = self?.collectionView.cellForItem(at: index) as? AddIngredientsToListCell else {
                      return nil
                  }
            return cell.info
        }
        
        createDataSource()
        reloadDataSource()
        setupCalendar()
        setupDestinationList()
        setupMenu()
        
        makeConstraints()
    }
    
    private func setupCalendar() {
        calendarView.fadeOut()
        calendarView.configure(dates: viewModel.getSelectedDates())
        
        calendarView.labelColors = { [weak self] date in
            self?.viewModel.getLabelColors(by: date) ?? []
        }
        
        calendarView.selectDates = { [weak self] selectedDates in
            self?.viewModel.updateSelectedDates(dates: selectedDates)
        }
        
        calendarView.fadeOutView = { [weak self] in
            self?.calendarView.fadeOut()
        }
    }
    
    private func setupDestinationList() {
        destinationListView.configure(list: viewModel.getDestinationListTitle())
        
        destinationListView.selectList = { [weak self] in
            self?.viewModel.showDestinationLabel()
        }
    }
    
    private func setupMenu() {
        menuView.fadeOut()
        menuView.configure(type: viewModel.addIngredientsType)
        
        menuView.selectState = { [weak self] state in
            guard let self else {
                return
            }
            menuView.configure(type: self.viewModel.addIngredientsType)
            switch state {
            case .sortByRecipe:
                viewModel.setSortType(type: .recipe)
            case .sortByCategory:
                viewModel.setSortType(type: .category)
            case .addAllToList:
                viewModel.addAllToList()
            }
        }
        
        menuView.fadeOutView = { [weak self] in
            self?.menuView.fadeOut()
        }
    }

    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                        cellProvider: { [weak self] _, indexPath, model in
            guard let self else {
                return UICollectionViewCell()
            }
            let cell = self.collectionView.reusableCell(classCell: AddIngredientsToListCell.self, indexPath: indexPath)
            var quantity = model.ingredient.quantity
            var unitTitle = model.ingredient.unit?.shortTitle ?? ""
            if let unit = self.viewModel.unit(unitID: model.ingredient.unit?.id) {
                quantity *= self.viewModel.convertValue(unitID: model.ingredient.unit?.id)
                unitTitle = unit.title
            }
            let serving = quantity == 0 ? R.string.localizable.byTaste() : quantity.asString + " " + unitTitle
            cell.configure(ingredient: model.ingredient, serving: serving, state: model.state)
            cell.configureInStock(isVisible: model.state == .inStock, color: viewModel.getPantryColor(ingredient: model))
            cell.tapInStockCross = { [weak self] in
                self?.viewModel.removeInStockInfo(ingredient: model)
            }
            return cell
        })
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, _, indexPath in
            guard let self else {
                return UICollectionViewCell()
            }
            let sectionHeader = collectionView.reusableHeader(classHeader: AddIngredientsToListHeaderCell.self, indexPath: indexPath)
            guard let model = self.dataSource?.itemIdentifier(for: indexPath),
                  let section = self.dataSource?.snapshot().sectionIdentifier(containingItem: model) else {
                return sectionHeader ?? UICollectionReusableView()
            }
            sectionHeader?.configure(model: section)
            return sectionHeader
        }
    }
    
    private func reloadDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<AddIngredientsToListHeaderModel, IngredientForMealPlan>()
        let sections = viewModel.getSections()
        for section in sections {
            snapshot.appendSections([section])
            snapshot.appendItems(section.products, toSection: section)
        }
        
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    @objc
    private func tappedMenuButton() {
        menuView.configure(type: viewModel.addIngredientsType)
        menuView.fadeIn()
    }
    
    @objc
    private func tappedDoneButton() {
        viewModel.save()
    }
    
    @objc
    private func tappedDatesButton() {
        calendarView.fadeIn()
    }
    
    private func makeConstraints() {
        self.view.addSubviews([collectionView, grabberView,
                               menuButton, doneButton, destinationListView, titleLabel,
                               calendarView, menuView])
        collectionView.addSubviews([grabberBackgroundView, datesButton])
        navigationMakeConstraints()
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(datesButton.snp.top).offset(-8)
            $0.trailing.equalTo(doneButton.snp.leading)
            $0.centerX.equalToSuperview()
        }
        
        datesButton.snp.makeConstraints {
            dateButtonTopConstraint = $0.top.greaterThanOrEqualTo(self.view.snp.top).offset(16).constraint
            dateButtonBottomConstraint = $0.bottom.equalTo(collectionView.snp.top).offset(8).priority(1000).constraint
            $0.centerX.equalToSuperview()
            $0.height.equalTo(32)
        }
        datesButton.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        datesButton.setContentHuggingPriority(.init(1000), for: .vertical)
        
        destinationListView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(68)
        }
        
        calendarView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        menuView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func navigationMakeConstraints() {
        grabberBackgroundView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(self.view)
            $0.bottom.equalTo(menuButton.snp.bottom).offset(8)
        }
        
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(5)
            $0.width.equalTo(36)
        }
        
        menuButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(40)
        }
        
        doneButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.greaterThanOrEqualTo(86)
        }
        doneButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        doneButton.setContentHuggingPriority(.init(1000), for: .horizontal)
    }
}

extension AddIngredientsToListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.updateState(indexPath: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentInset: CGFloat = 84
        let yOffset = -(scrollView.contentOffset.y + contentInset) + 10
        
        titleLabel.alpha = yOffset / 10 < 0 ? 0 : yOffset / 10
        
        dateButtonBottomConstraint?.isActive = yOffset / 10 > 0
        dateButtonTopConstraint?.isActive = yOffset / 10 < 0
    }
}
