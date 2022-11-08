//
//  MainScreenViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import SnapKit
import UIKit

class MainScreenViewController: UIViewController {
    
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<SectionModel, GroseryListsModel>?
    var viewModel: MainScreenViewModel?
    weak var router: RootRouter?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupCollectionView()
        addRecognizer()
        createTableViewDataSource()
        reloadData()
        viewModel?.reloadDataCallBack = { [weak self] in
            self?.reloadData()
        }
    }
    
    @objc
    private func searchButtonAction() {
        
    }
    
    private func createAttributedString(title: String, color: UIColor = .white) -> NSAttributedString {
        NSAttributedString(string: title, attributes: [
            .font: UIFont.SFPro.bold(size: 18).font ?? UIFont(),
            .foregroundColor: color
        ])
    }
    // MARK: - UI
    
    private lazy var collectionView = IntrinsicCollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "profileImage")
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "Unnamed"
        return label
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        button.setImage(UIImage(named: "searchButtonImage"), for: .normal)
        return button
    }()
    
    private let segmentControl: UISegmentedControl = {
        let control = CustomSegmentedControl(items: ["Grocery Lists".localized, "Recipes".localized])
        control.setTitleFont(UIFont.SFPro.bold(size: 18).font)
        control.setTitleColor(UIColor(hex: "#657674"))
        control.setTitleColor(UIColor(hex: "#31635A"), state: .selected)
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor(hex: "#D2E7E4")
        control.selectedSegmentTintColor = .white
        return control
    }()
    
    private let groceryListsView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let bottomCreateListView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.9)
        return view
    }()
    
    private let plusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "#plusImage")
        return imageView
    }()
    
    private let createListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "CreateList".localized
        return label
    }()
    
    private let foodImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "foodImage")
        return imageView
    }()
    
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        view.addSubviews([scrollView, bottomCreateListView])
        scrollView.addSubview(contentView)
        contentView.addSubviews([avatarImage, userNameLabel, searchButton, groceryListsView, segmentControl])
        groceryListsView.addSubviews([collectionView])
        bottomCreateListView.addSubviews([plusImage, createListLabel])
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(5)
            make.right.left.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width)
            make.left.right.top.bottom.equalToSuperview()
        }
        
        avatarImage.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.left.equalTo(22)
            make.top.equalToSuperview()
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImage.snp.right).inset(-10)
            make.centerY.equalTo(avatarImage)
        }
        
        searchButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(22)
            make.centerY.equalTo(avatarImage)
            make.width.height.equalTo(40)
        }
        
        segmentControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(22)
            make.top.equalTo(avatarImage.snp.bottom).inset(-16)
            make.height.equalTo(48)
        }
        
        groceryListsView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom)
            make.bottom.right.left.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(88)
        }
        
        bottomCreateListView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(86)
        }
        
        plusImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(38)
            make.top.equalToSuperview().inset(24)
            make.height.width.equalTo(24)
        }
        
        createListLabel.snp.makeConstraints { make in
            make.left.equalTo(plusImage.snp.right).inset(-8)
            make.centerY.equalTo(plusImage)
        }
        
    }
}

// MARK: - CollectionView
extension MainScreenViewController {
    
    private func setupCollectionView() {
        collectionView.backgroundColor = UIColor(hex: "#E8F5F3")
        collectionView.register(GroceryListsCollectionViewCell.self,
                                forCellWithReuseIdentifier: "GroceryListsCollectionViewCell")
        collectionView.register(EmptyColoredCell.self,
                                forCellWithReuseIdentifier: "EmptyColoredCell")
        collectionView.register(InstructionCell.self,
                                forCellWithReuseIdentifier: "InstructionCell")
        collectionView.register(GroceryCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "GroceryCollectionViewHeader")
    }
    
    private func createTableViewDataSource() {
        collectionViewDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                                      cellProvider: { collectionView, indexPath, model in
            switch self.viewModel?.model[indexPath.section].cellType {
            case .empty:
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyColoredCell", for: indexPath)
                as? EmptyColoredCell
                guard let viewModel = self.viewModel else { return UICollectionViewCell() }
                let isTopRouned = viewModel.isTopRounded(at: indexPath)
                let isBottomRounded = viewModel.isBottomRounded(at: indexPath)
                cell?.setupCell(bckgColor: model.color, isTopRounded: isTopRouned, isBottomRounded: isBottomRounded)
                return cell
            case .instruction:
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "InstructionCell", for: indexPath)
                as? InstructionCell
                return cell
            default:
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "GroceryListsCollectionViewCell",
                                                                         for: indexPath) as? GroceryListsCollectionViewCell
                guard let viewModel = self.viewModel else { return UICollectionViewCell() }
                let name = viewModel.getNameOfList(at: indexPath)
                let isTopRouned = viewModel.isTopRounded(at: indexPath)
                let isBottomRounded = viewModel.isBottomRounded(at: indexPath)
                let numberOfItems = viewModel.getnumberOfSupplaysInside(at: indexPath)
                
                cell?.setupCell(nameOfList: name, bckgColor: model.color, isTopRounded: isTopRouned,
                                isBottomRounded: isBottomRounded, numberOfItemsInside: numberOfItems, isFavorite: model.isFavorite)
                cell?.swipeDeleteAction = {
                    viewModel.deleteCell(with: model)
                }
                
                cell?.swipeToAddOrDeleteFromFavorite = {
                    viewModel.addOrDeleteFromFavorite(with: model)
                }
                return cell
            }
        })
        addHeaderToCollectionView()
    }
    
    private func addHeaderToCollectionView() {
        collectionViewDataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                      withReuseIdentifier: "GroceryCollectionViewHeader",
                                                                                      for: indexPath) as? GroceryCollectionViewHeader else { return nil }
            
            guard let model = self.collectionViewDataSource?.itemIdentifier(for: indexPath) else { return nil }
            guard let section = self.collectionViewDataSource?.snapshot().sectionIdentifier(containingItem: model) else { return nil }
            sectionHeader.setupHeader(sectionType: section.sectionType)
            return sectionHeader
        }
    }
    
    // ReloadData
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, GroseryListsModel>()
        guard let viewModel = viewModel else { return }
        snapshot.appendSections(viewModel.model)
        for section in viewModel.model {
            snapshot.appendItems(section.lists, toSection: section)
        }
        collectionViewDataSource?.apply(snapshot)
    }
    
    // CollectionViewLayout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            return self.createLayout()
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

// MARK: - CreateListAction
extension MainScreenViewController {
    private func addRecognizer() {
        let firstRecognizer = UITapGestureRecognizer(target: self, action: #selector(createListAction))
        bottomCreateListView.addGestureRecognizer(firstRecognizer)
    }
    
    @objc
    private func createListAction() {
        print("createList")
    }
}
