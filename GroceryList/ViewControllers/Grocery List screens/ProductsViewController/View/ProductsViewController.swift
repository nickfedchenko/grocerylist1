//
//  ProductsViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import ApphudSDK
import SnapKit
import UIKit

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ProductsViewController: UIViewController {
    
    enum Section: Hashable {
        case main
    }
    
    enum DataItem: Hashable {
        case parent(Category)
        case child(Product)
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, DataItem>!
    var viewModel: ProductsViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    private let navigationView = UIView()
    private let editView = UIView()
    
    private lazy var arrowBackButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(arrowBackButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "greenArrowBack"), for: .normal)
        return button
    }()
    
    private lazy var nameOfListTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.SFPro.semibold(size: 22).font
        textField.tintColor = .black
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 8
        textField.layer.cornerCurve = .continuous
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.delegate = self
        return textField
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(sortButtonPressed), for: .touchUpInside)
        button.setImage(R.image.sort(), for: .normal)
        return button
    }()
    
    private lazy var contextMenuButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(contextMenuButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "contextMenu"), for: .normal)
        return button
    }()
    
    private lazy var cancelEditButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(cancelEditButtonPressed), for: .touchUpInside)
        button.setTitle(R.string.localizable.cancel(), for: .normal)
        button.setTitleColor(R.color.edit(), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.semibold(size: 16).font
        button.isHidden = true
        return button
    }()
    
    private let totalCostLabel = UILabel()
    private let messageView = InfoMessageView()
    private let productImageView = ProductImageView()
    private let sharingView = SharingView()
    private let editTabBarView = EditTabBarView()
    private var imagePicker = UIImagePickerController()
    private var taprecognizer = UITapGestureRecognizer()
    private var cellState: CellState = .normal
    
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBarController as? MainTabBarController)?.productsDelegate = self
        
        setupConstraints()
        setupCollectionView()
        setupController()
        setupInfoMessage()
        setupProductImageView()
        setupSharingView()
        addRecognizer()
        viewModel?.valueChangedCallback = { [weak self] in
            self?.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        messageView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.reloadStorageData()
        let darkColor = viewModel?.getDarkColor() ?? .black
        (self.tabBarController as? MainTabBarController)?.isHideNavView(isHide: true)
        (self.tabBarController as? MainTabBarController)?.setTextTabBar(
            text: R.string.localizable.item(), color: darkColor)
    }
    
    private func setupController() {
        let colorForForeground = viewModel?.getColorForForeground() ?? .black
        let colorForBackground = viewModel?.getColorForBackground()
        let darkColor = viewModel?.getDarkColor() ?? .black
        nameOfListTextField.text = viewModel?.getNameOfList()
        view.backgroundColor = colorForBackground
        navigationView.backgroundColor = colorForBackground?.withAlphaComponent(0.9)
        (self.tabBarController as? MainTabBarController)?.setTextTabBar(text: R.string.localizable.item(),
                                                                        color: darkColor)
        nameOfListTextField.textColor = darkColor
        
        sortButton.setImage(R.image.sort()?.withTintColor(colorForForeground), for: .normal)
        arrowBackButton.setImage(R.image.greenArrowBack()?.withTintColor(colorForForeground), for: .normal)
        contextMenuButton.setImage(R.image.contextMenu()?.withTintColor(colorForForeground), for: .normal)
        
        collectionView.reloadData()
        editTabBarView.delegate = self
        
        setupSharingView()
        let isVisibleCost = viewModel?.isVisibleCost ?? false
        updateTotalCost(isVisible: isVisibleCost)
    }
    
    private func setupInfoMessage() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.setupInfoMessage()
            }
            return
        }
        messageView.isHidden = UserDefaultsManager.shared.countInfoMessage >= 4 || (viewModel?.arrayWithSections.isEmpty ?? true)
        messageView.updateView()
        messageView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(collectionView.contentSize.height - 85)
        }
    }
    
    private func setupProductImageView() {
        productImageView.isHidden = true
        
        productImageView.galleryAction = { [weak self] in
            self?.pickImage()
        }
        
        productImageView.deleteImageAction = { [weak self] in
            self?.viewModel?.updateImage(nil)
            self?.productImageView.setVisibilityView(hidden: true)
            self?.viewModel?.selectedProduct = nil
        }
        
        productImageView.closeAction = { [weak self] in
            self?.productImageView.setVisibilityView(hidden: true)
            self?.viewModel?.selectedProduct = nil
        }
        
        productImageView.updatePurchaseStatusAction = { [weak self] status in
            guard var selectedProduct = self?.viewModel?.selectedProduct else {
                return
            }
            selectedProduct.isPurchased = !status
            self?.viewModel?.updatePurchasedStatus(product: selectedProduct)
        }
    }
    
    private func setupSharingView() {
        guard let viewModel else { return }
        sharingView.configure(state: viewModel.getSharingState(),
                              viewState: .products,
                              color: viewModel.getColorForForeground(),
                              images: viewModel.getShareImages())
    }
    
    private func updateTotalCost(isVisible: Bool) {
        guard let viewModel else { return }
        totalCostLabel.isHidden = !isVisible
        totalCostLabel.snp.updateConstraints { $0.height.equalTo(isVisible ? 19 : 0) }
        navigationView.snp.updateConstraints { $0.height.equalTo(isVisible ? 113 : 84) }
        guard isVisible else { return }
        
        totalCostLabel.textAlignment = .right
        let color = viewModel.getColorForForeground()
        let title = R.string.localizable.totalCost()
        let currency = (Locale.current.currencySymbol ?? "")
        var cost = ""
        if let totalCost = viewModel.totalCost, totalCost > 0 {
            cost = "\(totalCost)"
        } else {
            cost = "---"
        }
        
        if Locale.current.languageCode == "en" || currency == "$" {
            cost = currency + " " + cost
        } else {
            cost = cost + " " + currency
        }
        
        let titleFont = UIFont.SFPro.medium(size: 16).font ?? .systemFont(ofSize: 16)
        let costFont = UIFont.SFPro.semibold(size: 16).font ?? .systemFont(ofSize: 16)
        
        let titleAttr = NSMutableAttributedString(string: title,
                                                  attributes: [.font: titleFont,
                                                               .foregroundColor: color])
        let costAttr = NSAttributedString(string: cost,
                                          attributes: [.font: costFont,
                                                       .foregroundColor: color])
        titleAttr.append(costAttr)
        totalCostLabel.attributedText = titleAttr
    }
    
//    deinit {
//        print("ProductView deinited")
//    }
    
    // MARK: - buttonPressed
    
    @objc
    private func arrowBackButtonPressed() {
        self.navigationController?.popViewController(animated: true)
        viewModel?.goBackButtonPressed()
    }
    
    @objc
    private func contextMenuButtonPressed() {
        let snapshot = makeSnapshot()
        viewModel?.settingsTapped(with: snapshot)
    }
    
    @objc
    private func sortButtonPressed() {
        viewModel?.sortTapped(productType: .products)
    }
    
    @objc
    private func editCellButtonPressed() {
        AmplitudeManager.shared.logEvent(.editList)
        let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        let bottomPadding = safeAreaBottom == 0 ? 12 : safeAreaBottom
        let editTabBarHeight = 72 + bottomPadding
        editView.snp.updateConstraints { $0.height.equalTo(47) }
        editTabBarView.snp.updateConstraints { $0.height.equalTo(editTabBarHeight) }
        cancelEditButton.isHidden = false
        cancelEditButton.alpha = 0
        
        let expandTransform: CGAffineTransform = CGAffineTransformMakeScale(1.05, 1.05)
        UIView.transition(with: self.cancelEditButton, duration: 0.1,
                          options: .transitionCrossDissolve, animations: { [weak self] in
            self?.cancelEditButton.transform = expandTransform
        }, completion: { _ in
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 0.2, options: .curveEaseOut, animations: { [weak self] in
                self?.sortButton.alpha = 0
                self?.arrowBackButton.alpha = 0
                self?.contextMenuButton.alpha = 0
                self?.sharingView.alpha = 0
                self?.cancelEditButton.alpha = 1
                self?.cancelEditButton.transform = CGAffineTransformInvert(expandTransform)
                self?.view.layoutIfNeeded()
                (self?.tabBarController as? MainTabBarController)?.customTabBar.layoutIfNeeded()
            }, completion: nil)
        })
        cellState = .edit
        viewModel?.resetEditProducts()
        collectionView.reloadData()
    }
    
    @objc
    private func cancelEditButtonPressed() {
        cellState = .normal
        editView.snp.updateConstraints { $0.height.equalTo(0) }
        editTabBarView.snp.updateConstraints { $0.height.equalTo(0) }
        cancelEditButton.isHidden = true
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.sortButton.alpha = 1
            self?.arrowBackButton.alpha = 1
            self?.contextMenuButton.alpha = 1
            self?.sharingView.alpha = 1
            self?.view.layoutIfNeeded()
            (self?.tabBarController as? MainTabBarController)?.customTabBar.layoutIfNeeded()
        }
        editTabBarView.setCountSelectedItems(0)
        viewModel?.setEditState(isEdit: false)
        collectionView.reloadData()
    }
    
    @objc
    private func longPressAction(_ recognizer: UILongPressGestureRecognizer) {
        guard cellState == .normal,
              recognizer.state == .began else {
            return
        }
        tapPressAction()
        
        let location = recognizer.location(in: self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: location),
                  let model = dataSource?.itemIdentifier(for: indexPath) else {
                      return
                  }
        
        switch model {
        case .parent: break
        case .child(let product):
            guard !product.isOutOfStock else {
                return
            }
            viewModel?.addNewProductTapped(product)
        }
    }
    
    @objc
    private func tapPressAction() {
        guard !messageView.isHidden else {
            return
        }
        
        UserDefaultsManager.shared.countInfoMessage += 1
        messageView.fadeOut()
        taprecognizer.isEnabled = false
    }
    
    @objc
    private func sharingViewPressed() {
        AmplitudeManager.shared.logEvent(.setInvite)
        viewModel?.sharingTapped()
    }
    
    private func updateCost(isVisibleCost: Bool) {
        viewModel?.updateCostVisible(isVisibleCost)
        updateTotalCost(isVisible: isVisibleCost)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        reloadData()
    }
    
    // MARK: - CollectionView
    // swiftlint:disable:next function_body_length
    func setupCollectionView() {
        collectionView.contentInset.bottom = 120
        
        // MARK: Configure collection view
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // MARK: Cell registration
        let headerCellRegistration = UICollectionView.CellRegistration<HeaderListCell, Category> { [weak self] (cell, _, parent) in
            
            let color = self?.viewModel?.getColorForForeground()
            let bcgColor = self?.viewModel?.getColorForBackground()
            let isVisibleCost = self?.viewModel?.isVisibleCost ?? false
            cell.setupCell(text: parent.name, color: color, bcgColor: bcgColor,
                           isExpand: parent.isExpanded, typeOfCell: parent.typeOFCell)
            cell.setupTotalCost(isVisible: isVisibleCost, color: color,
                                purchasedCost: parent.cost, typeOfCell: parent.typeOFCell)
            if parent.typeOFCell == .sortedByRecipe {
                cell.setupDate(date: self?.viewModel?.getMealPlanForHeader(by: parent.products.first))
            }
            if parent.typeOFCell == .sortedByUser {
                cell.setupUserImage(image: self?.viewModel?.getUserImage(by: parent.name), color: color)
            }
            
            cell.tapSortPurchased = { [weak self] in
                self?.viewModel?.sortTapped(productType: .purchased)
            }
        }
    
        let displayCellRegistration = UICollectionView.CellRegistration<DisplayCostListCell, Category> { [weak self] (cell, _, _) in
            
            let color = self?.viewModel?.getColorForForeground()
            let isVisibleCost = self?.viewModel?.isVisibleCost ?? false
            cell.configureSwitch(isVisibleCost: isVisibleCost, tintColor: color)
            cell.changedSwitchValue = { [weak self] switchValue in
                AmplitudeManager.shared.logEvent(.shopPriceToggle, properties: [.isActive: switchValue ? .yes : .valueNo])
#if RELEASE
                guard Apphud.hasActiveSubscription() else {
                    self?.viewModel?.showPaywall()
                    cell.configureSwitch(isVisibleCost: isVisibleCost, tintColor: color)
                    return
                }
#endif
                self?.updateCost(isVisibleCost: switchValue)
            }
        }
        
        let childCellRegistration = UICollectionView.CellRegistration<ProductListCell, Product> { [weak self] (cell, _, child) in

            let isVisibleInStock = self?.viewModel?.isInStock(product: child) ?? false
            let pantryColor = self?.viewModel?.getPantryColor(product: child)
            let color = isVisibleInStock ? pantryColor?.dark : self?.viewModel?.getColorForForeground()
            let bcgColor = self?.viewModel?.getColorForBackground()
            let isVisibleCost = self?.viewModel?.isVisibleCost ?? false
            let image = child.imageData
            let description = child.description
            let isVisibleImageBySettings = self?.viewModel?.isVisibleImage ?? UserDefaultsManager.shared.isShowImage
            let isUserImage = (child.isUserImage ?? false) ? true : isVisibleImageBySettings
            let isEditCell = self?.viewModel?.editProducts.contains(where: { $0.id == child.id }) ?? false
            let storeTitle = child.store?.title ?? ""
            let newLine = (description.count + storeTitle.count) > 30 && isVisibleCost
            let productCost = self?.calculateCost(quantity: child.quantity, cost: child.cost)
            
            cell.setState(state: child.isOutOfStock ? .stock : self?.cellState ?? .normal)
            cell.setupCell(bcgColor: bcgColor, textColor: color, text: child.name,
                           isPurchased: child.isPurchased, description: description,
                           isOutOfStock: child.isOutOfStock)
            cell.setupRecipeMealPlan(
                textColor: color,
                isRecipe: self?.viewModel?.getRecipeTitle(title: child.fromRecipeTitle, isPurchased: child.isPurchased) ?? false,
                mealPlan: self?.viewModel?.getMealPlanForCell(by: child.fromMealPlan, isPurchased: child.isPurchased)
            )
            cell.setupImage(isVisible: isUserImage, image: image)
            cell.setupUserImage(image: self?.viewModel?.getUserImage(by: child.userToken, isPurchased: child.isPurchased))
            cell.updateEditCheckmark(isSelect: isEditCell)
            cell.setupCost(isVisible: isVisibleCost, isAddNewLine: newLine, color: color,
                           storeTitle: child.store?.title, costValue: productCost)
            cell.setupInStock(isVisible: isVisibleInStock, color: pantryColor?.medium)
            // картинка
            if image != nil {
                cell.tapImageAction = { [weak self] in
                    self?.productImageView.configuration(product: child, textColor: color)
                    self?.viewModel?.selectedProduct = child
                    self?.productImageView.updateContentViewFrame(.init(x: cell.frame.maxX,
                                                                        y: cell.frame.minY))
                    self?.productImageView.setVisibilityView(hidden: false)
                }
            }
            
            cell.tapInStockCross = { [weak self] in
                self?.viewModel?.removeInStockInfo(child)
            }
            
            // свайпы
            cell.swipeToPinchAction = { [weak self] in
                AmplitudeManager.shared.logEvent(.itemDelete)
                idsOfChangedProducts.insert(child.id)
                idsOfChangedLists.insert(child.listId)
                self?.viewModel?.delete(product: child)
            }
            
            cell.swipeToDeleteAction = { [weak self] in
                idsOfChangedProducts.insert(child.id)
                idsOfChangedLists.insert(child.listId)
                self?.viewModel?.updateFavoriteStatus(for: child)
            }
        }
        
        // MARK: Initialize data source
        dataSource = UICollectionViewDiffableDataSource<Section, DataItem>(collectionView: collectionView) { (collectionView, indexPath, listItem) ->
            UICollectionViewCell? in
                        
            switch listItem {
            case .parent(let parent):
                if parent.typeOFCell == .displayCostSwitch {
                    let cell = collectionView.dequeueConfiguredReusableCell(using: displayCellRegistration,
                                                                            for: indexPath,
                                                                            item: parent)
                    return cell
                }
                
                let cell = collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration,
                                                                        for: indexPath,
                                                                        item: parent)
                return cell
                
            case .child(let child):
                let cell = collectionView.dequeueConfiguredReusableCell(using: childCellRegistration,
                                                                        for: indexPath,
                                                                        item: child)
                return cell
            }
        }
        reloadData()
    }

    private func reloadData() {
        var snapshot = dataSource.snapshot()
        
        guard let viewModel = viewModel else { return }
        if snapshot.sectionIdentifiers.isEmpty {
            snapshot.appendSections([.main])
            dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<DataItem>()
        for parent in viewModel.arrayWithSections {
            
            let parentDataItem = DataItem.parent(parent)
            let childDataItemArray = parent.products.map { DataItem.child($0) }
            
            sectionSnapshot.append([parentDataItem])
            sectionSnapshot.append(childDataItemArray, to: parentDataItem)
            
            if parent.isExpanded {
                sectionSnapshot.expand([parentDataItem])
            }
        }
        self.dataSource.apply(sectionSnapshot, to: .main, animatingDifferences: true)
        
        setupInfoMessage()
        updateTotalCost(isVisible: viewModel.isVisibleCost)
    }
    
    private func makeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(collectionView.contentSize, false, 0)
        collectionView.drawHierarchy(in: collectionView.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .grouped)
        layoutConfig.headerMode = .firstItemInSection
        layoutConfig.showsSeparators = false
        layoutConfig.backgroundColor = .clear
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        layout.collectionView?.backgroundColor = .white
        return layout
    }
    
    private func calculateCost(quantity: Double?, cost: Double?) -> Double? {
        guard quantity != 0 && cost != 0 else {
            return nil
        }
        
        guard let cost else {
            return nil
        }
        
        if let quantity {
            if quantity == 0 {
                return cost
            }
            return quantity * cost
        } else {
            return cost
        }
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        view.addSubviews([collectionView, navigationView, productImageView, editView])
        navigationView.addSubviews([arrowBackButton, nameOfListTextField, contextMenuButton, sharingView, sortButton, totalCostLabel])
        editView.addSubviews([cancelEditButton])
        collectionView.addSubview(messageView)
        (self.tabBarController as? MainTabBarController)?.customTabBar.addSubview(editTabBarView)
        
        setupNavigationViewConstraints()
        setupEditViewConstraints()
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(-4)
            make.left.right.bottom.equalToSuperview()
        }
        
        messageView.snp.makeConstraints { make in
            make.width.equalTo(264)
            make.centerX.equalTo(self.view)
            make.top.equalToSuperview().offset(collectionView.contentSize.height - 85)
        }
        
        productImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupNavigationViewConstraints() {
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.right.left.equalToSuperview()
            make.height.equalTo(84)
        }
        
        arrowBackButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.height.width.equalTo(44)
        }
        
        nameOfListTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.top.equalTo(arrowBackButton.snp.bottom).offset(6)
            make.height.equalTo(36)
        }
        
        contextMenuButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.height.width.equalTo(40)
        }
        
        sharingView.snp.makeConstraints { make in
            make.trailing.equalTo(contextMenuButton.snp.leading).offset(-8)
            make.centerY.equalTo(contextMenuButton)
            make.height.equalTo(40)
        }
        
        sortButton.snp.makeConstraints { make in
            make.trailing.equalTo(sharingView.snp.leading).offset(4)
            make.centerY.equalTo(sharingView)
            make.height.equalTo(40)
        }
        
        totalCostLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(nameOfListTextField.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(19)
        }
    }
    
    private func setupEditViewConstraints() {
        editView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(navigationView)
            make.height.equalTo(0)
        }
        
        cancelEditButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        
        if self.tabBarController != nil {
            editTabBarView.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(0)
            }
        }
    }
}

// MARK: - CellTapped
extension ProductsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = dataSource?.itemIdentifier(for: indexPath) else { return }
        switch model {
        case .parent: break
        case .child(let product):
            let cell = collectionView.cellForItem(at: indexPath) as? ProductListCell
            guard cellState != .edit else {
                // редактирование ячеек
                guard let viewModel else { return }
                AmplitudeManager.shared.logEvent(.editCheckItem)
                viewModel.updateEditProduct(product)
                let isEditCell = viewModel.editProducts.contains(where: { $0.id == product.id })
                cell?.updateEditCheckmark(isSelect: isEditCell)
                editTabBarView.setCountSelectedItems(viewModel.editProducts.count)
                if viewModel.isSelectedAllProductsForEditing || viewModel.editProducts.count == 0 {
                    editTabBarView.isSelectAll(viewModel.isSelectedAllProductsForEditing)
                }
                return
            }
            
            // чекмарк о покупке
            idsOfChangedProducts.insert(product.id)
            idsOfChangedLists.insert(product.listId)
            if product.isOutOfStock {
                self.viewModel?.updateStockStatus(product: product)
                return
            }
            
            if product.isPurchased {
                cell?.removeCheckmark { [weak self] in
                    self?.viewModel?.updatePurchasedStatus(product: product)
                }
            } else {
                AmplitudeManager.shared.logEvent(.itemChecked)
                if product.fromRecipeTitle != nil {
                    AmplitudeManager.shared.logEvent(.itemCheckedFromRecipe)
                }
                let color = viewModel?.getColorForForeground()
                cell?.addCheckmark(color: color) { [weak self] in
                    self?.viewModel?.updatePurchasedStatus(product: product)
                }
            }
        }
    }
    
    // Схлопывание и расширения родительской ячейки + анимация
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        var snap = dataSource.snapshot(for: .main)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        var isPurchased = false
        var items: [ProductsViewController.DataItem] = []
        var indexPaths: [IndexPath] = []
        // проверка на тип сортировки
        switch item {
        case .parent(let parent):
            // отключения возможности схлопывания ячеек при сортировке по алфавиту и без категорий
            guard parent.typeOFCell != .sortedByAlphabet else { return false }
            guard parent.typeOFCell != .withoutCategory else { return false }
            
            items.append(item)
            indexPaths.append(indexPath)
            
            // для схлопывыания Куплено
            if parent.typeOFCell == .purchased {
                viewModel?.isExpandedPurchased.toggle()
                isPurchased = true
                let sections = viewModel?.sectionIndexPaths ?? []
                var purchasedSectionIndex = sections.firstIndex(of: indexPath.row) ?? 0
                while purchasedSectionIndex < sections.endIndex {
                    let section = sections[purchasedSectionIndex]
                    let index = IndexPath(row: section, section: 0)
                    if let item = dataSource.itemIdentifier(for: index) {
                        indexPaths.append(index)
                        items.append(item)
                    }
                    purchasedSectionIndex += 1
                }
            }
        default:
            print("")
        }
        
        let sectionSnapshot = snap.snapshot(of: item, includingParent: false)
        let hasChildren = sectionSnapshot.items.count > 0
        
        if hasChildren {
            if snap.isExpanded(item) {
                switchModelAndSetupParametr(item: item, isExpanded: false, indexPath: indexPath)
                snap.collapse([item])
            } else {
                switchModelAndSetupParametr(item: item, isExpanded: true, indexPath: indexPath)
                snap.expand([item])
            }
            self.dataSource.apply(snap, to: .main)
        }
        if isPurchased {
            items.enumerated().forEach { index, item in
                if (viewModel?.isExpandedPurchased ?? true) {
                    switchModelAndSetupParametr(item: item, isExpanded: false, indexPath: indexPaths[index])
                    snap.collapse([item])
                } else {
                    switchModelAndSetupParametr(item: item, isExpanded: true, indexPath: indexPaths[index])
                    snap.expand([item])
                }
            }
            self.dataSource.apply(snap, to: .main)
        }
        return !hasChildren
    }
    
    private func switchModelAndSetupParametr(item: DataItem, isExpanded: Bool, indexPath: IndexPath) {
        switch item {
        case .parent(let category):
            guard let ind = self.viewModel?.getCellIndex(with: category) else { return }
            self.viewModel?.arrayWithSections[ind].isExpanded = isExpanded
            self.shouldExpandCell(isExpanded: isExpanded, ind: indexPath,
                                  color: viewModel?.getColorForForeground(),
                                  typeOfCell: category.typeOFCell)
        case .child:
            print("")
        }
    }
    
    private func shouldExpandCell(isExpanded: Bool, ind: IndexPath, color: UIColor?, typeOfCell: TypeOfCell) {
        let cell = collectionView.cellForItem(at: ind) as? HeaderListCell
        
        if isExpanded {
            cell?.expanding(color: color, typeOfCell: typeOfCell)
        } else {
            cell?.collapsing(color: color, typeOfCell: typeOfCell)
        }
    }
}

// MARK: - View model delegate
extension ProductsViewController: ProductsViewModelDelegate {
    func updateController() {
        setupController()
        reloadData()
    }
    
    func editProduct() {
        editCellButtonPressed()
    }
    
    func updateUIEditTab() {
        editTabBarView.setCountSelectedItems(viewModel?.editProducts.count ?? 0)
    }
    
    func scrollToNewProduct(indexPath: IndexPath) {
        if collectionView.indexPathsForVisibleItems.contains(indexPath) {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
    }
}

extension ProductsViewController {
    private func addRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
        let tapSharingRecognizer = UITapGestureRecognizer(target: self, action: #selector(sharingViewPressed))
        sharingView.addGestureRecognizer(tapSharingRecognizer)
        
        if UserDefaultsManager.shared.countInfoMessage < 4 {
            taprecognizer = UITapGestureRecognizer(target: self, action: #selector(tapPressAction))
            self.view.addGestureRecognizer(taprecognizer)
        }
    }
}

extension ProductsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func pickImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .pageSheet
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        productImageView.updateImage(image)
        viewModel?.updateImage(image)
    }
}

extension ProductsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField == nameOfListTextField else {
            return
        }
        AmplitudeManager.shared.logEvent(.inputRename)
        updateNameList(isEdit: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateNameList(isEdit: false)
        nameOfListTextField.resignFirstResponder()
        return true
    }
    
    private func updateNameList(isEdit: Bool) {
        nameOfListTextField.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(isEdit ? 16 : 24)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
            self?.nameOfListTextField.backgroundColor = isEdit ? .white : .clear
            self?.nameOfListTextField.layer.borderColor = (isEdit ? UIColor(hex: "#D1DBDB") : .clear).cgColor
            self?.nameOfListTextField.paddingLeft(inset: isEdit ? 8 : 0)
        }
        
        if !isEdit {
            viewModel?.updateNameOfList(nameOfListTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        }
    }
}

extension ProductsViewController: EditTabBarViewDelegate {
    func tappedSelectAll() {
        viewModel?.addAllProductsToEdit()
        collectionView.reloadData()
    }
    
    func tappedMove() {
        viewModel?.showListView(contentViewHeigh: self.view.frame.height - 60, state: .move, delegate: self)
    }
    
    func tappedCopy() {
        viewModel?.showListView(contentViewHeigh: self.view.frame.height - 60, state: .copy, delegate: self)
    }
    
    func tappedDelete() {
        viewModel?.deleteProducts()
        cancelEditButton.setTitle(R.string.localizable.done(), for: .normal)
    }
    
    func tappedClearAll() {
        viewModel?.resetEditProducts()
        collectionView.reloadData()
    }
}

extension ProductsViewController: EditSelectListDelegate {
    func productsSuccessfullyMoved() {
        viewModel?.moveProducts()
        cancelEditButton.setTitle(R.string.localizable.done(), for: .normal)
    }
    
    func productsSuccessfullyCopied() {
        viewModel?.resetEditProducts()
        cancelEditButton.setTitle(R.string.localizable.done(), for: .normal)
        collectionView.reloadData()
    }
}

extension ProductsViewController: MainTabBarControllerProductsDelegate {
    func tappedAddItem() {
        AmplitudeManager.shared.logEvent(.itemAdd)
        tapPressAction()
        viewModel?.addNewProductTapped()
    }
}
