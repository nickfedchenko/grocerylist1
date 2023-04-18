//
//  ProductsViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import SnapKit
import UIKit

// swiftlint:disable file_length
// swiftlint:disable type_body_length
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
    
    private let nameOfListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 22).font
        return label
    }()
    
    private lazy var editCellButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(editCellButtonPressed), for: .touchUpInside)
        button.setImage(R.image.editCell(), for: .normal)
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
        button.setTitleColor(UIColor(hex: "#7E19FF"), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.semibold(size: 16).font
        button.isHidden = true
        return button
    }()
    
    private let addItemView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 32
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner]
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        view.layer.borderWidth = 2
        view.addCustomShadow(color: UIColor(hex: "#484848"), offset: CGSize(width: 0, height: 0.5))
        return view
    }()
    
    private let plusView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    private let plusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.sharing_plus()
        return imageView
    }()
    
    private let addItemLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = .white
        label.numberOfLines = 2
        label.text = "AddItem".localized
        return label
    }()
    
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
    
    private func setupController() {
        let colorForForeground = viewModel?.getColorForForeground() ?? .black
        let colorForBackground = viewModel?.getColorForBackground()
        nameOfListLabel.text = viewModel?.getNameOfList()
        view.backgroundColor = colorForBackground
        navigationView.backgroundColor = colorForBackground
        
        addItemView.backgroundColor = colorForForeground
        plusImage.image = R.image.sharing_plus()?.withTintColor(colorForForeground)
        editCellButton.setImage(R.image.editCell()?.withTintColor(colorForForeground), for: .normal)
        arrowBackButton.setImage(R.image.greenArrowBack()?.withTintColor(colorForForeground), for: .normal)
        contextMenuButton.setImage(R.image.contextMenu()?.withTintColor(colorForForeground), for: .normal)
        nameOfListLabel.textColor = colorForForeground
        
        collectionView.reloadData()
        editTabBarView.delegate = self
        
        setupSharingView()
    }
    
    private func setupInfoMessage() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.setupInfoMessage()
            }
            return
        }
        messageView.isHidden = UserDefaultsManager.countInfoMessage >= 4 || (viewModel?.arrayWithSections.isEmpty ?? true)
        messageView.updateView()
        messageView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(collectionView.contentSize.height + 4)
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
    
    deinit {
        print("ProductView deinited")
    }
    
    // MARK: - buttonPressed
    
    @objc
    private func arrowBackButtonPressed() {
        viewModel?.goBackButtonPressed()
    }
    
    @objc
    private func contextMenuButtonPressed() {
        let snapshot = makeSnapshot()
        viewModel?.settingsTapped(with: snapshot)
    }
    
    @objc
    private func editCellButtonPressed() {
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
                self?.editCellButton.alpha = 0
                self?.arrowBackButton.alpha = 0
                self?.contextMenuButton.alpha = 0
                self?.sharingView.alpha = 0
                self?.cancelEditButton.alpha = 1
                self?.cancelEditButton.transform = CGAffineTransformInvert(expandTransform)
                self?.view.layoutIfNeeded()
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
            self?.editCellButton.alpha = 1
            self?.arrowBackButton.alpha = 1
            self?.contextMenuButton.alpha = 1
            self?.sharingView.alpha = 1
            self?.view.layoutIfNeeded()
        }
        editTabBarView.setCountSelectedItems(0)
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
            viewModel?.addNewProductTapped(product)
        }
    }
    
    @objc
    private func tapPressAction() {
        guard !messageView.isHidden else {
            return
        }
        
        UserDefaultsManager.countInfoMessage += 1
        messageView.fadeOut()
        taprecognizer.isEnabled = false
    }
    
    @objc
    private func sharingViewPressed() {
        viewModel?.sharingTapped()
    }
    
    // MARK: - CollectionView
    // swiftlint: disable function_body_length
    func setupCollectionView() {
        collectionView.contentInset.bottom = 120
        
        // MARK: Configure collection view
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        // MARK: Cell registration
        let headerCellRegistration = UICollectionView.CellRegistration<HeaderListCell, Category> { [weak self] (cell, _, parent) in
            
            let color = self?.viewModel?.getColorForForeground()
            let bcgColor = self?.viewModel?.getColorForBackground()
            cell.setupCell(text: parent.name, color: color, bcgColor: bcgColor,
                           isExpand: parent.isExpanded, typeOfCell: parent.typeOFCell)
            if parent.typeOFCell == .sortedByUser {
                cell.setupUserImage(image: self?.viewModel?.getUserImage(by: parent.name), color: color)
            }
        }
    
        let childCellRegistration = UICollectionView.CellRegistration<ProductListCell, Product> { [weak self] (cell, _, child) in
            
            let bcgColor = self?.viewModel?.getColorForBackground()
            let textColor = self?.viewModel?.getColorForForeground()
            let image = child.imageData
            let description = child.description
            let isVisibleImageBySettings = self?.viewModel?.isVisibleImage ?? UserDefaultsManager.isShowImage
            let isUserImage = (child.isUserImage ?? false) ? true : isVisibleImageBySettings
            let isEditCell = self?.viewModel?.editProducts.contains(where: { $0.id == child.id }) ?? false
            
            cell.setState(state: self?.cellState ?? .normal)
            cell.setupCell(bcgColor: bcgColor, textColor: textColor, text: child.name,
                           isPurchased: child.isPurchased, description: description,
                           isRecipe: child.fromRecipeTitle != nil)
            cell.setupImage(isVisible: isUserImage, image: image)
            cell.setupUserImage(image: self?.viewModel?.getUserImage(by: child.userToken, isPurchased: child.isPurchased))
            cell.updateEditCheckmark(isSelect: isEditCell)
            // картинка
            if image != nil {
                cell.tapImageAction = { [weak self] in
                    self?.productImageView.configuration(product: child, textColor: textColor)
                    self?.viewModel?.selectedProduct = child
                    self?.productImageView.updateContentViewFrame(.init(x: cell.frame.maxX,
                                                                        y: cell.frame.minY))
                    self?.productImageView.setVisibilityView(hidden: false)
                }
            }
            
            // свайпы
            cell.swipeToPinchAction = { [weak self] in
                AmplitudeManager.shared.logEvent(.itemDelete)
                idsOfChangedProducts.insert(child.id)
                idsOfChangedLists.insert(child.listId)
                self?.viewModel?.delete(product: child)
            }
            
            guard !child.isPurchased else { return }
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
    
    // MARK: - Constraints
    private func setupConstraints() {
        view.addSubviews([collectionView, navigationView, addItemView, productImageView, editView, editTabBarView])
        navigationView.addSubviews([arrowBackButton, nameOfListLabel, contextMenuButton, sharingView, editCellButton])
        editView.addSubviews([cancelEditButton])
        addItemView.addSubviews([plusView, plusImage, addItemLabel])
        collectionView.addSubview(messageView)
        
        setupNavigationViewConstraints()
        setupEditViewConstraints()
        setupAddItemConstraints()
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        messageView.snp.makeConstraints { make in
            make.width.equalTo(264)
            make.centerX.equalTo(self.view)
            make.top.equalToSuperview().offset(collectionView.contentSize.height + 4)
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
        
        nameOfListLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.top.equalTo(arrowBackButton.snp.bottom).offset(12)
            make.height.equalTo(24)
        }
        
        contextMenuButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.height.width.equalTo(40)
        }
        
        editCellButton.snp.makeConstraints { make in
            make.trailing.equalTo(contextMenuButton.snp.leading).inset(-4)
            make.centerY.equalTo(contextMenuButton)
            make.height.width.equalTo(40)
        }
        
        sharingView.snp.makeConstraints { make in
            make.trailing.equalTo(editCellButton.snp.leading).offset(-4)
            make.top.equalTo(contextMenuButton)
            make.height.equalTo(44)
        }
    }
    
    private func setupAddItemConstraints() {
        addItemView.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().offset(4)
            make.height.equalTo(84)
            make.width.equalTo(self.view.frame.width / 2 + 2)
        }
        
        plusView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
        }
        
        plusImage.snp.makeConstraints { make in
            make.center.equalTo(plusView)
            make.width.height.equalTo(32)
        }
        
        addItemLabel.snp.makeConstraints { make in
            make.left.equalTo(plusImage.snp.right).inset(-16)
            make.centerY.equalTo(plusImage)
            make.right.equalToSuperview().inset(5)
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
        
        editTabBarView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0)
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
        
        // проверка на тип сортировки для отключения возможности схлопывания ячеек при сортировке по алфавиту
        switch item {
        case .parent(let parent):
            guard parent.typeOFCell != .sortedByAlphabet else {
                return false
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
        return !hasChildren
    }
    
    private func switchModelAndSetupParametr(item: DataItem, isExpanded: Bool, indexPath: IndexPath) {
        switch item {
        case .parent(let category):
            guard let ind = self.viewModel?.getCellIndex(with: category) else { return }
            self.viewModel?.arrayWithSections[ind].isExpanded = isExpanded
            let cellTypeIsPurchased = category.typeOFCell == .purchased
            self.shouldExpandCell(isExpanded: isExpanded, ind: indexPath,
                                  color: viewModel?.getColorForForeground(), isPurchased: cellTypeIsPurchased)
        case .child:
            print("")
        }
    }
    
    private func shouldExpandCell(isExpanded: Bool, ind: IndexPath, color: UIColor?, isPurchased: Bool) {
        let cell = collectionView.cellForItem(at: ind) as? HeaderListCell
        
        if isExpanded {
            cell?.expanding(color: color, isPurchased: isPurchased)
        } else {
            cell?.collapsing(color: color, isPurchased: isPurchased)
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
}

extension ProductsViewController {
    private func addRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(addItemViewTapped))
        addItemView.addGestureRecognizer(tapRecognizer)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
        let tapSharingRecognizer = UITapGestureRecognizer(target: self, action: #selector(sharingViewPressed))
        sharingView.addGestureRecognizer(tapSharingRecognizer)
        
        if UserDefaultsManager.countInfoMessage < 4 {
            taprecognizer = UITapGestureRecognizer(target: self, action: #selector(tapPressAction))
            self.view.addGestureRecognizer(taprecognizer)
        }
    }
    
    @objc
    private func addItemViewTapped () {
        AmplitudeManager.shared.logEvent(.itemAdd)
        tapPressAction()
        viewModel?.addNewProductTapped()
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
        cancelEditButtonPressed()
    }
    
    func tappedClearAll() {
        viewModel?.resetEditProducts()
        collectionView.reloadData()
    }
    
}

extension ProductsViewController: EditSelectListDelegate {
    func productsSuccessfullyMoved() {
        viewModel?.moveProducts()
        cancelEditButtonPressed()
    }
    
    func productsSuccessfullyCopied() {
        cancelEditButtonPressed()
    }
}
