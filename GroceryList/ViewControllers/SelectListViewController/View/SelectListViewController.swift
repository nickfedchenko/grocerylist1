//
//  SelectListViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import SnapKit
import UIKit

class SelectListViewController: UIViewController {
    
    var collectionViewDataSource: UICollectionViewDiffableDataSource<SectionModel, GroceryListsModel>?
    var viewModel: SelectListViewModel?
    var contentViewHeigh: Double = 0
    var router: RootRouter? {
        viewModel?.router
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    // MARK: - UI
    private(set) lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.background()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.background()
        return view
    }()
    
    private let dismissRecognizerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let selectListTopView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.background()
        view.isHidden = true
        return view
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#ACACAC")
        view.layer.cornerRadius = 2
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    let selectListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.textColor = UIColor(hex: "#0C695E")
        label.text = "Select list".localized
        return label
    }()
    
    let createListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "PickItem".localized
        return label
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setImage(UIImage(named: "closeButtonCross"), for: .normal)
        return button
    }()
 
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupCollectionView()
        createTableViewDataSource()
        addRecognizer()
        viewModel?.reloadDataCallBack = { [weak self] in
            self?.reloadData()
        }
    }
    
    deinit {
        print("select list deinited")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard var snapshot = collectionViewDataSource?.snapshot() else { return }
        snapshot.deleteAllItems()
        collectionViewDataSource?.apply(snapshot)
        viewModel?.reloadDataFromStorage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateConstr(with: 0, compl: nil)
    }
    
    func addFoodToListMode() {
        selectListTopView.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = .black.withAlphaComponent(0.4)
        }
    }
    
    func createTableViewDataSource() {
        collectionViewDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                                      cellProvider: { [weak self] _, indexPath, model in
            
            let cell = self?.collectionView.dequeueReusableCell(withReuseIdentifier: "SelectListCollectionCell",
                                                                for: indexPath) as? SelectListCollectionCell
            guard let viewModel = self?.viewModel else { return UICollectionViewCell() }
            let name = viewModel.getNameOfList(at: indexPath)
            let isTopRouned = viewModel.isTopRounded(at: indexPath)
            let isBottomRounded = viewModel.isBottomRounded(at: indexPath)
            let numberOfItems = viewModel.getNumberOfProductsInside(at: indexPath)
            let color = viewModel.getBGColor(at: indexPath)
            cell?.setupCell(nameOfList: name, bckgColor: color, isTopRounded: isTopRouned,
                            isBottomRounded: isBottomRounded, numberOfItemsInside: numberOfItems, isFavorite: model.isFavorite)
            cell?.setupSharing(state: viewModel.getSharingState(model),
                              color: color,
                              image: viewModel.getShareImages(model))
            
            return cell
        })
        addHeaderToCollectionView()
    }
    
    func addHeaderToCollectionView() {
        collectionViewDataSource?.supplementaryViewProvider = { [weak self]  collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                      withReuseIdentifier: "GroceryCollectionViewHeader",
                                                                                      for: indexPath) as? GroceryCollectionViewHeader else { return nil }
            
            guard let model = self?.collectionViewDataSource?.itemIdentifier(for: indexPath) else { return nil }
            guard let section = self?.collectionViewDataSource?.snapshot().sectionIdentifier(containingItem: model) else { return nil }
            sectionHeader.setupHeader(sectionType: section.sectionType)
            return sectionHeader
        }
    }
    
    // MARK: - Constraints
    private func updateConstr(with inset: Double, compl: (() -> Void)?) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(inset)
            }
            self.view.layoutIfNeeded()
        } completion: { _ in
            compl?()
        }
    }
    
    func hidePanel() {
        self.view.backgroundColor = .clear
        updateConstr(with: -contentViewHeigh) {
            self.dismiss(animated: true, completion: { [weak self] in
                self?.viewModel?.controllerDissmissed()
            })
        }
    }

    // MARK: - Constraints
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        view.backgroundColor = .clear
        view.addSubviews([contentView, dismissRecognizerView])
        contentView.addSubviews([topView, collectionView, selectListTopView])
        topView.addSubviews([createListLabel, closeButton])
        selectListTopView.addSubviews([lineView, selectListLabel])
        
        dismissRecognizerView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.bottom.equalTo(contentView.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-contentViewHeigh)
            make.height.equalTo(contentViewHeigh)
        }
        
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        selectListTopView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        lineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(8)
            make.width.equalTo(65)
            make.height.equalTo(4)
        }
        
        selectListLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom).offset(14)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).inset(20)
            make.left.right.bottom.equalToSuperview()
        }
        
        createListLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(80)
        }
        
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(22)
            make.centerY.equalTo(createListLabel)
            make.width.height.equalTo(40)
        }
    }
    
    // MARK: - ButtonAction
    @objc
    private func closeButtonAction() {
        hidePanel()
    }
}

// MARK: - CollectionView
extension SelectListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = collectionViewDataSource?.itemIdentifier(for: indexPath) else { return }
        viewModel?.cellTapped(with: model, viewHeight: contentViewHeigh)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.backgroundColor = R.color.background()
        collectionView.register(SelectListCollectionCell.self,
                                forCellWithReuseIdentifier: "SelectListCollectionCell")
        collectionView.register(GroceryCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "GroceryCollectionViewHeader")
    }
    
    // ReloadData
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, GroceryListsModel>()
        guard let viewModel = viewModel else { return }
        snapshot.appendSections(viewModel.model)
        for section in viewModel.model {
            snapshot.appendItems(section.lists, toSection: section)
        }
        collectionViewDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func reloadItems(lists: Set<GroceryListsModel>) {
        guard var snapshot = collectionViewDataSource?.snapshot() else { return }
        let array = Array(lists)
        array.forEach({ if snapshot.sectionIdentifier(containingItem: $0) != nil { snapshot.reloadItems([$0]) } })
       
        collectionViewDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    // CollectionViewLayout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (_, _) -> NSCollectionLayoutSection? in
            return self?.createLayout()
        }
        return layout
    }
    
    private func createLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(72))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .estimated(44))
        let layutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutHeaderSize,
                                                                             elementKind: UICollectionView.elementKindSectionHeader,
                                                                             alignment: .top)
        return layutSectionHeader
    }
}

extension SelectListViewController {
    
    private func addRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(panRecognizer)
        
        let dismissRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissAction(_:)))
        dismissRecognizerView.addGestureRecognizer(dismissRecognizer)
    }
    
    @objc
    private func dismissAction(_ recognizer: UIPanGestureRecognizer) {
        hidePanel()
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
}

extension SelectListViewController: SelectListViewModelDelegate {
    func dismissController() {
        hidePanel()
    }
    
    func presentSelectedVC(controller: UIViewController) {
        self.present(controller, animated: true)
    }
}
