//
//  RecipeFilterViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 06.07.2023.
//

import UIKit

class RecipeFilterViewController: UIViewController {

    private let viewModel: RecipeFilterViewModel
    
    private let navigationView = UIView()
    private let topSafeAreaView = UIView()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.setImage(R.image.greenArrowBack(), for: .normal)
        button.setTitle("   Search", for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.bold(size: 16).font
        button.setTitleColor(R.color.darkGray(), for: .normal)
        button.semanticContentAttribute = .forceLeftToRight
        button.contentEdgeInsets.left = 12
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.heavy(size: 40).font
        label.text = "Filters"
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        layout.configuration.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(classCell: RecipeFilterCell.self)
        collectionView.registerHeader(classHeader: RecipeFilterCellHeader.self)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset.top = 90
        collectionView.contentInset.bottom = 40
        return collectionView
    }()
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
        let estimatedWeight: CGFloat = 12
        let height: CGFloat = 32
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(estimatedWeight),
                                              heightDimension: .absolute(height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0),
                                                         top: .fixed(8),
                                                         trailing: .fixed(8),
                                                         bottom: .fixed(0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(16),
                                                          top: .fixed(0),
                                                          trailing: .fixed(0),
                                                          bottom: .fixed(0))
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(48)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading,
            absoluteOffset: .zero
        )
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.supplementariesFollowContentInsets = true

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    init(viewModel: RecipeFilterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        let theme = viewModel.theme
        self.view.backgroundColor = theme.light
        navigationView.backgroundColor = theme.light
        topSafeAreaView.backgroundColor = theme.light
        backButton.tintColor = theme.dark
        backButton.setTitleColor(theme.dark, for: .normal)
        titleLabel.textColor = theme.dark
        
        makeConstraints()
    }
    
    @objc
    private func backButtonTapped() {
        viewModel.popController()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([collectionView, topSafeAreaView, navigationView])
        navigationView.addSubviews([backButton])
        collectionView.addSubviews([titleLabel])
        
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
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-4)
            $0.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.bottom.equalTo(collectionView.snp.top).offset(8)
        }
    }
}

extension RecipeFilterViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.allFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.allFilters[section].tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: RecipeFilterCell.self, indexPath: indexPath)
        cell.setupColor(border: viewModel.borderCellColor,
                        select: indexPath.section == 0 ? R.color.attention() : viewModel.selectCellColor)
        cell.configure(title:  viewModel.allFilters[indexPath.section].tags[indexPath.row].title)
        cell.selectTitle = { [weak self] _ in
            self?.viewModel.addFilter(by: indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.reusableHeader(classHeader: RecipeFilterCellHeader.self, indexPath: indexPath) else {
            return UICollectionReusableView()
        }
        header.configure(title: viewModel.allFilters[indexPath.section].title, color: viewModel.theme)
        return header
    }
}

extension RecipeFilterViewController: UICollectionViewDelegate {
    
}
