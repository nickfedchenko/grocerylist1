//
//  SelectListViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import SnapKit
import UIKit

class SelectListViewController: UIViewController {
    
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<SectionModel, GroceryListsModel>?
    var viewModel: SelectListViewModel?
    var contentViewHeigh: Double = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupCollectionView()
        createTableViewDataSource()
        addRecognizer()
        viewModel?.reloadDataCallBack = { [weak self] in
            self?.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.dismiss(animated: true)
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
        updateConstr(with: 0)
    }
    
    func updateConstr(with inset: Double) {
        UIView.animate(withDuration: 0.3) { [ weak self ] in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(inset)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func closeButtonAction() {
        hidePanel()
    }
    
    // MARK: - UI
    
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        return view
    }()
    
    private let createListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "PickItem".localized
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setImage(UIImage(named: "closeButtonCross"), for: .normal)
        return button
    }()
    
    private func setupConstraints() {
        view.backgroundColor = .clear
        view.addSubviews([contentView])
        contentView.addSubviews([topView, collectionView])
        topView.addSubviews([createListLabel, closeButton])
        
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-contentViewHeigh)
            make.height.equalTo(contentViewHeigh)
        }
        
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
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
    
}

// MARK: - CollectionView
extension SelectListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = collectionViewDataSource?.itemIdentifier(for: indexPath) else { return }
        guard let section = self.collectionViewDataSource?.snapshot().sectionIdentifier(containingItem: model) else { return }
        guard section.cellType == .usual else { return }
        viewModel?.cellTapped(with: model)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(hex: "#E8F5F3")
        collectionView.register(SelectListCollectionCell.self,
                                forCellWithReuseIdentifier: "SelectListCollectionCell")
        collectionView.register(GroceryCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "GroceryCollectionViewHeader")
    }
    
    private func createTableViewDataSource() {
        collectionViewDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                                      cellProvider: { [weak self] collectionView, indexPath, model in

                let cell = self?.collectionView.dequeueReusableCell(withReuseIdentifier: "SelectListCollectionCell",
                                                                   for: indexPath) as? SelectListCollectionCell
                guard let viewModel = self?.viewModel else { return UICollectionViewCell() }
                let name = viewModel.getNameOfList(at: indexPath)
                let isTopRouned = viewModel.isTopRounded(at: indexPath)
                let isBottomRounded = viewModel.isBottomRounded(at: indexPath)
                let numberOfItems = viewModel.getnumberOfProductsInside(at: indexPath)
                let color = viewModel.getBGColor(at: indexPath)
                cell?.setupCell(nameOfList: name, bckgColor: color, isTopRounded: isTopRouned,
                                isBottomRounded: isBottomRounded, numberOfItemsInside: numberOfItems, isFavorite: model.isFavorite)
              
                return cell
        })
        addHeaderToCollectionView()
    }
    
    private func addHeaderToCollectionView() {
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
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
    
    private func hidePanel() {
        updateConstr(with: -contentViewHeigh)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
