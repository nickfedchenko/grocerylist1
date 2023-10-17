//
//  MealPlanViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.08.2023.
//

import SnapKit
import UIKit

class MealPlanViewController: UIViewController {

    let viewModel: MealPlanViewModel
    
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
        button.setImage(R.image.recipe_menu(), for: .normal)
        button.addTarget(self, action: #selector(tappedMenuButton), for: .touchUpInside)
        button.setTitleColor(R.color.edit(), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.semibold(size: 16).font
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
        collectionView.contentInset.bottom = UIDevice.isSE2 ? 20 : 60
        collectionView.contentInset.top = 16
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.register(classCell: MealPlanCell.self)
        collectionView.register(classCell: MealPlanNoteCell.self)
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
    
    private let editTabBarView = EditTabBarView()
    
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
    private var menuWidthConstraint: Constraint?

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
        editTabBarView.delegate = self
        
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.reloadDataSource()
                self?.calendarView.reloadData()
            }
        }
        
        viewModel.updateEditMode = { [weak self] in
            self?.isVisibleEditMode(isVisible: self?.viewModel.isEditMode ?? false)
        }
        
        viewModel.updateEditTabBar = { [weak self] in
            self?.editTabBarView.setCountSelectedItems(self?.viewModel.editMealPlansCount() ?? 0)
        }
        
        viewModel.reloadCalendar = { [weak self] date in
            if self?.UDMSelectedMonthOrWeek == 0 {
                return
            }
            DispatchQueue.main.async {
                self?.calendarView.setDate(date)
                self?.reloadDataSource()
            }
        }
        
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
                return self.setupMealPlanCell(by: indexPath, cellModel: model)
            case .note:
                return self.setupNoteCell(by: indexPath, type: model.type)
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
        
        dataSource?.reorderingHandlers.canReorderItem = { item in
            return item.type == .note || item.type == .plan
        }

        dataSource?.reorderingHandlers.didReorder = { [weak self] transaction in
            let backingStore = transaction.finalSnapshot.itemIdentifiers
            self?.viewModel.updateIndexAfterMove(cellModels: backingStore)
        }
    }
    
    private func setupMealPlanCell(by indexPath: IndexPath, cellModel: MealPlanCellModel) -> MealPlanCell {
        let cell = self.collectionView.reusableCell(classCell: MealPlanCell.self, indexPath: indexPath)
        guard let recipe = self.viewModel.getRecipe(by: self.calendarView.selectedDate, for: indexPath) else {
            cell.configureWithoutRecipe()
            return cell
        }
        cell.configure(with: recipe)
        cell.configureColor(theme: self.viewModel.theme)
        cell.selectedIndex = indexPath.item
        let label = viewModel.getLabel(by: self.calendarView.selectedDate, for: indexPath, type: cellModel.type)
        cell.configureMealPlanLabel(text: label.text, color: label.color)
        cell.mealPlanDelegate = self
        cell.configureEditMode(isEdit: cellModel.isEdit,
                               isSelect: cellModel.isSelectedEditMode)
        return cell
    }
    
    private func setupNoteCell(by indexPath: IndexPath, type: MealPlanCellType) -> MealPlanNoteCell {
        let cell = self.collectionView.reusableCell(classCell: MealPlanNoteCell.self, indexPath: indexPath)
        guard let note = self.viewModel.getNote(by: self.calendarView.selectedDate, for: indexPath) else {
            return cell
        }
        cell.configure(title: note.title, details: note.details)
        let label = viewModel.getLabel(by: self.calendarView.selectedDate, for: indexPath, type: type)
        cell.configureMealPlanLabel(text: label.text, color: label.color)
        cell.mealPlanDelegate = self
        cell.layoutSubviews()
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
        let date = calendarView.selectedDate
        let sections = viewModel.getMealPlanSections(by: date)
        
        for section in sections {
            snapshot.appendSections([section])
            snapshot.appendItems(section.mealPlans, toSection: section)
        }
        
        DispatchQueue.main.async {
            if self.UDMSelectedMonthOrWeek == 0 {
                let isNoEntires = self.viewModel.isEmptySection(by: date)
                if !isNoEntires {
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
    
    private func isVisibleEditMode(isVisible: Bool) {
        if isVisible {
            let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
            let bottomPadding = safeAreaBottom == 0 ? 12 : safeAreaBottom
            let editTabBarHeight = 72 + bottomPadding
            editTabBarView.snp.updateConstraints { $0.height.equalTo(editTabBarHeight) }
        } else {
            editTabBarView.snp.updateConstraints { $0.height.equalTo(0) }
            editTabBarView.setCountSelectedItems(0)
        }

        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.menuButton.alpha = 0
            self?.view.layoutIfNeeded()
            (self?.tabBarController as? MainTabBarController)?.customTabBar.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.menuButton.alpha = 1
            self?.updatedMenuButton(isEditMode: isVisible)
        }
    }

    private func updatedMenuButton(isEditMode: Bool) {
        menuWidthConstraint?.isActive = !isEditMode
        menuButton.setImage(isEditMode ? nil : R.image.recipe_menu(), for: .normal)
        menuButton.setTitle(isEditMode ? R.string.localizable.done() : nil, for: .normal)
    }
    
    @objc
    private func tappedTodayButton() {
        Vibration.medium.vibrate()
        calendarView.setToday()
        updatedTodayButton()
        
        DispatchQueue.main.async {
            self.reloadDataSource()
        }
    }
    
    @objc
    private func tappedMenuButton() {
        Vibration.medium.vibrate()
        guard viewModel.isEditMode else {
            viewModel.showContextMenu(date: calendarView.selectedDate)
            return
        }
        viewModel.editMode(isEdit: false)
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
        (self.tabBarController as? MainTabBarController)?.customTabBar.addSubview(editTabBarView)
        
        makeConstraintsForNavigationView()
        
        todayButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(78)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(36)
            $0.width.equalTo(72)
        }

        menuButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
            menuWidthConstraint = $0.width.equalTo(40).constraint
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(UIDevice.isSE2 ? 300 : 364)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        noEntiresLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-36)
            $0.centerX.equalToSuperview()
        }
        
        editTabBarView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0)
        }
    }
    
    private func makeConstraintsForNavigationView() {
        navigationView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(Int(UIView.safeAreaTop) + 127 + calendarMonthHeight)
            $0.horizontalEdges.equalToSuperview()
        }

        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(164)
        }
    }
}

extension MealPlanViewController: CalendarViewDelegate {
    func selectedDate(_ date: Date) {
        updatedTodayButton(isActive: calendarView.selectedDate.onlyDate != Date().onlyDate)
        reloadDataSource()
        collectionView.scrollToItem(at: .init(row: 0, section: 0), at: .bottom, animated: true)
    }
    
    func pageDidChange() {
        updatedTodayButton(isActive: true)
        reloadDataSource()
    }
    
    func getLabelColors(by date: Date) -> [UIColor] {
        return viewModel.getLabelColors(by: date)
    }
    
    func movedToDate(date: Date) {
        viewModel.moveToCalendar(date: date)
    }
    
    func selectedDates() { }
}

extension MealPlanViewController: CustomSegmentedControlViewDelegate {
    func segmentChanged(_ selectedSegmentIndex: Int) {
        Vibration.medium.vibrate()
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
        viewModel.showSelectRecipeToMealPlan(selectedDate: calendarView.selectedDate)
    }
}

extension MealPlanViewController: MealPlanCellDelegate {
    func moveCell(gesture: UILongPressGestureRecognizer) {
        let gestureLocation = gesture.location(in: collectionView)
        if viewModel.isEditMode {
            calendarView.moveRecipe(gesture: gesture)
        }
        
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView.indexPathForItem(at: gestureLocation) else {
                collectionView.cancelInteractiveMovement()
                return
            }
            collectionView.beginInteractiveMovementForItem(at: targetIndexPath)
            
            if viewModel.isEditMode,
               let recipe = self.viewModel.getRecipe(by: self.calendarView.selectedDate,
                                                     for: targetIndexPath) {
                calendarView.setRecipeImage(recipe: recipe)
            }
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gestureLocation)
        case .ended:
            guard let endIndexPath = collectionView.indexPathForItem(at: gestureLocation),
                  let model = dataSource?.itemIdentifier(for: endIndexPath),
                  let section = dataSource?.snapshot().sectionIdentifier(containingItem: model),
                  let type = section.mealPlans[safe: endIndexPath.row]?.type else {
                collectionView.cancelInteractiveMovement()
                return
            }
            switch type {
            case .plan, .note:
                collectionView.endInteractiveMovement()
            default:
                collectionView.cancelInteractiveMovement()
            }
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
}

extension MealPlanViewController: MealPlanHeaderCellDelegate {
    func addNote(_ cell: MealPlanHeaderCell) {
        Vibration.medium.vibrate()
        var date = calendarView.selectedDate
        if let dateFromCell = cell.date {
            date = dateFromCell
        }
        viewModel.showAddNoteToMealPlan(by: date)
    }
    
    func addRecipe(_ cell: MealPlanHeaderCell) {
        Vibration.medium.vibrate()
        var date = calendarView.selectedDate
        if let dateFromCell = cell.date {
            date = dateFromCell
        }
        viewModel.showSelectRecipeToMealPlan(selectedDate: date)
    }
}

extension MealPlanViewController: MealPlanEmptyCellDelegate {
    func tapAdd(state: MealPlanCellType) {
        switch state {
        case .plan, .note:
            break
        case .planEmpty:
            viewModel.showSelectRecipeToMealPlan(selectedDate: calendarView.selectedDate)
        case .noteEmpty, .noteFilled:
            viewModel.showAddNoteToMealPlan(by: calendarView.selectedDate)
        }
    }
}

extension MealPlanViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = dataSource?.itemIdentifier(for: indexPath),
              let section = dataSource?.snapshot().sectionIdentifier(containingItem: model),
              let type = section.mealPlans[safe: indexPath.row]?.type else {
            return
        }
        
        guard !viewModel.isEditMode else {
            viewModel.updateEditMealPlan(model)
            reloadDataSource()
            return
        }
        switch type {
        case .plan:
            viewModel.showAddRecipeToMealPlan(by: indexPath)
        case .note:
            viewModel.showAddNoteToMealPlan(by: calendarView.selectedDate, for: indexPath)
        default:
            return
        }
    }
}

extension MealPlanViewController: EditTabBarViewDelegate {
    func tappedSelectAll() {
        viewModel.addAllMealPlansToEdit()
    }
    
    func tappedMove() {
        viewModel.showCalendar(currentDate: calendarView.selectedDate, isCopy: false)
    }
    
    func tappedCopy() {
        viewModel.showCalendar(currentDate: calendarView.selectedDate, isCopy: true)
    }
    
    func tappedDelete() {
        viewModel.deleteEditMealPlans()
    }
    
    func tappedClearAll() {
        viewModel.resetEditProducts()
    }
}
