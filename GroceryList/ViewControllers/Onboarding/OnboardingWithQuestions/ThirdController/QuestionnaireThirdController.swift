//
//  QuestionnaireThirdController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.12.2023.
//

import UIKit
class QuestionnaireThirdController: UIViewController {
    weak var router: RootRouter?
    var viewModel: QuestionnaireThirdViewModel?
    
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<QuestionnaireThirdControllerSections, QuestionnaireThirdControllerCellModel>?
    private let collectionViewLayoutManager = QuestionnaireThirdControllerLayoutManager()
    
    private let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.questionnaireThirdBackgroundImage()
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = collectionViewLayoutManager.makeCollectionLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.register(classCell: QuestionnaireCell.self)
        collectionView.register(classCell: QuestionnaireHeaderCell.self)
        return collectionView
    }()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraints()
        applyCallbacks() 
        configureCollectionViewDataSource()
        viewModel?.viewDidLoad()
    }
    
    private func applyCallbacks() {
        viewModel?.applyShapshot = { [weak self] snapshot in
            self?.collectionViewDataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    // MARK: - CollectionView Data Source
    private func configureCollectionViewDataSource() {
        collectionViewDataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] _, indexPath, model in
                switch model {
                case .topHeader:
                    let cell = self?.collectionView.reusableCell(classCell: QuestionnaireHeaderCell.self, indexPath: indexPath)
                    return cell
                case .cell:
                    let cell = self?.collectionView.reusableCell(classCell: QuestionnaireCell.self, indexPath: indexPath)
                    return cell
                }
            }
        )
    }
    
}

extension QuestionnaireThirdController {
    private func makeConstraints() {
        view.addSubviews([backgroundImageView, collectionView])
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
