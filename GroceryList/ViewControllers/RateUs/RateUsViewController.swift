//
//  RateUsViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 26.12.2023.
//

import Foundation
import SnapKit
import UIKit

final class RateUsViewController: UIViewController {
    
    var viewModel: RateUsViewModel?
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(R.image.paywalWithTimerCloseButton(), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<RateUsSection, RateUsModel>?
    private let collectionViewLayoutManager = RateUsLayoutManager()
    
    private lazy var collectionView: UICollectionView = {
        let layout = collectionViewLayoutManager.makeCollectionLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.isScrollEnabled = false
        collectionView.register(classCell: RateUsTopCell.self)
        collectionView.register(classCell: RateUsBottomCell.self)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setupConstraints()
        configureCallbacks()
        configureCollectionViewDataSource()
        viewModel?.viewDidLoad()
    }
    
    private func configureCallbacks() {
        viewModel?.applyShapshot = { [weak self] snapshot in
            self?.collectionViewDataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    // MARK: - Actions
    @objc
    private func closeButtonTapped() {
        viewModel?.closeButtonTapped()
    }
}

extension RateUsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - CollectionView Data Source
    private func configureCollectionViewDataSource() {
        collectionViewDataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] _, indexPath, model in
                switch model {
                case .topCell(let model):
                    let cell = self?.collectionView.reusableCell(classCell: RateUsTopCell.self, indexPath: indexPath)
              
                    return cell
                case .bottomCell(let model):
                    let cell = self?.collectionView.reusableCell(classCell: RateUsBottomCell.self, indexPath: indexPath)

                    return cell
                }
            }
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard collectionView.cellForItem(at: indexPath) is QuestionnaireCell else {
//            return
//        }
//        viewModel?.cellSelected(at: indexPath)
    }
    
}

// MARK: - UI
extension RateUsViewController {
    
    private func addSubViews() {
        view.backgroundColor = .white
        view.addSubviews([
            collectionView,
            closeButton
        ])
    }
    
    private func setupConstraints() {
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(12)
            make.width.height.equalTo(40)
        }

    }
}
