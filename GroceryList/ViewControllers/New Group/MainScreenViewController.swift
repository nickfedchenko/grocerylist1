//
//  r.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import Foundation
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
    
    var collectionView: UICollectionView!
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            return self.createLayout()
        }
        return layout
    }
    
    private func createLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(86))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 10, trailing: 1)
        
        return section
    }
    
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
    
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        collectionView = IntrinsicCollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
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

// MARK: - TableView
extension MainScreenViewController {
    
    private func setupCollectionView() {
        collectionView.backgroundColor = UIColor(hex: "#E8F5F3")
        collectionView.register(GroceryListsCollectionViewCell.self, forCellWithReuseIdentifier: "GroceryListsCollectionViewCell")
    }
    
    private func createTableViewDataSource() {
        collectionViewDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
     
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "GroceryListsCollectionViewCell", for: indexPath)
                        as? GroceryListsCollectionViewCell
                return cell
         
        })
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, GroseryListsModel>()
        guard let viewModel = viewModel else { return }
        snapshot.appendSections(viewModel.model)
        
        for section in viewModel.model {
            snapshot.appendItems(section.lists, toSection: section)
        }
        
        collectionViewDataSource?.apply(snapshot)
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
