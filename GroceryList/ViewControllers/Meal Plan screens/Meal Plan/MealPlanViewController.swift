//
//  MealPlanViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.08.2023.
//

import UIKit

class MealPlanViewController: UIViewController {

    private let viewModel: MealPlanViewModel
    
    private var navigationView = UIView()
    
    private lazy var todayButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.today(), for: .normal)
        button.setTitleColor(R.color.mediumGray(), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.semibold(size: 16).font
        button.addTarget(self, action: #selector(tappedTodayButton), for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.layer.borderWidth = 1
        return button
    }()
    
    private lazy var segmentedControl: CustomSegmentedControlView = {
        let selectConfiguration = SegmentView.Configuration(
            titleColor: R.color.primaryDark(),
            font: UIFont.SFPro.semibold(size: 16).font,
            borderColor: UIColor(hex: "537979").cgColor,
            borderWidth: 1,
            backgroundColor: .clear
        )
        
        let unselectConfiguration = SegmentView.Configuration(
            titleColor: R.color.darkGray(),
            font: UIFont.SFPro.semibold(size: 16).font,
            borderColor: UIColor.clear.cgColor,
            borderWidth: 0,
            backgroundColor: .clear
        )
        let segmentedControl = CustomSegmentedControlView(items: [R.string.localizable.mealPlanMonth(),
                                                                  R.string.localizable.mealPlanWeek()],
                                                          select: selectConfiguration,
                                                          unselect: unselectConfiguration)
        segmentedControl.delegate = self
        segmentedControl.selectedSegmentIndex = UDMSelectedMonthOrWeek
        segmentedControl.segmentedBackgroundColor = UIColor(hex: "EBFEFE")
        segmentedControl.segmentedCornerRadius = 10
        return segmentedControl
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        let color = R.color.primaryDark() ?? UIColor(hex: "045C5C")
        button.setImage(R.image.pantry_move()?.withTintColor(color), for: .normal)
        button.addTarget(self, action: #selector(tappedMenuButton), for: .touchUpInside)
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
        collectionView.register(classCell: MealPlanEmptyCell.self)
        collectionView.registerHeader(classHeader: MealPlanHeaderCell.self)
        return collectionView
    }()
    
    private let noEntiresLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = R.color.lightGray()
        label.text = R.string.localizable.noEntires().uppercased()
        label.textAlignment = .center
        return label
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
    
    private var UDMSelectedMonthOrWeek: Int {
        get { UserDefaultsManager.shared.selectedMonthOrWeek }
        set { UserDefaultsManager.shared.selectedMonthOrWeek = newValue }
    }
    
    private var calendarMonthHeight: Int {
        let isMonth = segmentedControl.selectedSegmentIndex == 0
        guard isMonth else {
            return 112
        }
        if UIDevice.isSEorXor12mini {
            return 300
        }
        return 364
    }
    
    init(viewModel: MealPlanViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.backgroundColor = .white
        self.view.backgroundColor = R.color.background()
        (self.tabBarController as? MainTabBarController)?.mealDelegate = self

        createDataSource()
        reloadDataSource()
        
        updatedTodayButton()
        makeConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fixCalendarViewConstraints()
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                        cellProvider: { [weak self] _, indexPath, model in
            guard let self else {
                return UICollectionViewCell()
            }
            
            switch model.type {
            case .plan:
                return self.setupMealPlanCell(by: indexPath)
            case .note:
                return UICollectionViewCell()
            case .planEmpty, .noteEmpty, .noteFilled:
                return self.setupEmptyCell(by: indexPath, type: model.type)
            }
        })
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, _, indexPath in
            guard let self else {
                return UICollectionViewCell()
            }
            let sectionHeader = collectionView.reusableHeader(classHeader: MealPlanHeaderCell.self, indexPath: indexPath)
            guard let model = self.dataSource?.itemIdentifier(for: indexPath),
                  let section = self.dataSource?.snapshot().sectionIdentifier(containingItem: model) else {
                return sectionHeader ?? UICollectionReusableView()
            }
            sectionHeader?.setupHeader(section: section)
            sectionHeader?.configure(labelColors: self.viewModel.getLabelColors(by: section.date))
            sectionHeader?.delegate = self
            return sectionHeader
        }
        
//        dataSource?.reorderingHandlers.canReorderItem = { [weak self] _ in
//            return self?.viewModel.stateCellModel == .edit
//        }
//
//        dataSource?.reorderingHandlers.didReorder = { [weak self] transaction in
//            let backingStore = transaction.finalSnapshot.itemIdentifiers
//            self?.viewModel.updateStocksAfterMove(stocks: backingStore)
//        }
    }
    
    private func setupMealPlanCell(by indexPath: IndexPath) -> MealPlanCell {
        let cell = self.collectionView.reusableCell(classCell: MealPlanCell.self, indexPath: indexPath)
        guard let model = self.viewModel.getRecipe(by: self.calendarView.selectedDate, for: indexPath) else {
            cell.configureWithoutRecipe()
            return cell
        }
        cell.configure(with: model)
        cell.configureColor(theme: self.viewModel.theme)
        cell.selectedIndex = indexPath.item
        let label = viewModel.getLabel(by: self.calendarView.selectedDate, for: indexPath)
        cell.configureMealPlanLabel(text: label.text, color: label.color)
        cell.mealPlanDelegate = self
        return cell
    }
    
    private func setupEmptyCell(by indexPath: IndexPath, type: MealPlanCellType) -> MealPlanEmptyCell {
        let cell = self.collectionView.reusableCell(classCell: MealPlanEmptyCell.self, indexPath: indexPath)
        cell.configure(state: type)
        cell.delegate = self
        return cell
    }
    
    private func reloadDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<MealPlanSection, MealPlanCellModel>()
        let sections = viewModel.getMealPlanSections(by: calendarView.selectedDate)
        
        for section in sections {
            snapshot.appendSections([section])
            snapshot.appendItems(section.mealPlans, toSection: section)
        }
        
        DispatchQueue.main.async {
            if self.UDMSelectedMonthOrWeek == 0 {
                if let cellModel = sections.first?.mealPlans.first {
                    let isNoEntires = cellModel.note == nil && cellModel.mealPlan == nil
                    self.collectionView.contentInset.top = isNoEntires ? 52 : 16
                        self.noEntiresLabel.isHidden = !isNoEntires
                } else {
                    self.collectionView.contentInset.top = 52
                    self.noEntiresLabel.isHidden = false
                }
            } else {
                self.collectionView.contentInset.top = 16
                self.noEntiresLabel.isHidden = true
            }
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func updatedTodayButton(isActive: Bool = false) {
        guard todayButton.isUserInteractionEnabled != isActive else {
            return
        }
        let borderColor = isActive ? R.color.primaryDark() : UIColor.clear
        let titleColor = isActive ? R.color.primaryDark() : R.color.mediumGray()
        todayButton.layer.borderColor = borderColor?.cgColor
        todayButton.setTitleColor(titleColor, for: .normal)
        todayButton.isUserInteractionEnabled = isActive
    }
    
    @objc
    private func tappedTodayButton() {
        calendarView.setToday()
        updatedTodayButton()
        
        DispatchQueue.main.async {
            self.reloadDataSource()
        }
    }
    
    @objc
    private func tappedMenuButton() {
        
    }
    
    private func updateCalendarView(animated: Bool = true) {
        calendarView.snp.updateConstraints { $0.height.equalTo(calendarMonthHeight) }
        UIView.animate(withDuration: animated ? 0.2 : 0) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    private func fixCalendarViewConstraints() {
        navigationView.snp.removeConstraints()
        navigationView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        calendarView.snp.removeConstraints()
        calendarView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(calendarMonthHeight)
            $0.bottom.equalTo(navigationView)
        }
        updateCalendarView(animated: false)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([navigationView, calendarView, collectionView])
        navigationView.addSubviews([todayButton, segmentedControl, menuButton])
        collectionView.addSubview(noEntiresLabel)
        
        navigationView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(Int(UIView.safeAreaTop) + 127 + calendarMonthHeight)
            $0.horizontalEdges.equalToSuperview()
        }
        
        todayButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(78)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(36)
            $0.width.equalTo(72)
        }
        
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(164)
        }
        
        menuButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.width.equalTo(40)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(364)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        noEntiresLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-36)
            $0.centerX.equalToSuperview()
        }
    }
}

extension MealPlanViewController: CalendarViewDelegate {
    func selectedDate(_ date: Date) {
        updatedTodayButton(isActive: calendarView.selectedDate.onlyDate != Date().onlyDate)
        reloadDataSource()
    }
    
    func pageDidChange() {
        updatedTodayButton(isActive: true)
    }
    
    func getLabelColors(by date: Date) -> [UIColor] {
        return viewModel.getLabelColors(by: date)
    }
}

extension MealPlanViewController: CustomSegmentedControlViewDelegate {
    func segmentChanged(_ selectedSegmentIndex: Int) {
        segmentedControl.selectedSegmentIndex = selectedSegmentIndex
        UDMSelectedMonthOrWeek = selectedSegmentIndex
        calendarView.setScope()
        updateCalendarView()
        
        DispatchQueue.main.async {
            self.reloadDataSource()
        }
    }
}

extension MealPlanViewController: MainTabBarControllerMealPlanDelegate {
    func tappedAddRecipeToMealPlan() {
        viewModel.showSelectRecipeToMealPlan()
    }
}

extension MealPlanViewController: MealPlanCellDelegate {
    func moveCell(gesture: UILongPressGestureRecognizer) {
        
    }
}

extension MealPlanViewController: MealPlanHeaderCellDelegate {
    func addNote() {
        
    }
    
    func addRecipe() {
        viewModel.showSelectRecipeToMealPlan()
    }
}

extension MealPlanViewController: MealPlanEmptyCellDelegate {
    func tapAdd(state: MealPlanCellType) {
        switch state {
        case .plan, .note:
            break
        case .planEmpty:
            viewModel.showSelectRecipeToMealPlan()
        case .noteEmpty, .noteFilled:
            break
        }
    }
}

extension MealPlanViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
