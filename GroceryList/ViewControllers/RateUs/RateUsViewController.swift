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
        collectionView.isScrollEnabled = false
        collectionView.register(classCell: RateUsTopCell.self)
        collectionView.register(classCell: RateUsBottomCell.self)
        return collectionView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(string: R.string.localizable.continue().uppercased(), attributes: [
            .font: UIFont.SFPro.semibold(size: 20).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#FFFFFF")
        ])
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(hex: "#1A645A")
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.addShadowForView()
        button.alpha = 0
        return button
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
        
        viewModel?.scrollToPage = { [weak self] page in
            guard let self = self else { return }
            let offset = CGPoint(
                x: collectionView.frame.size.width * CGFloat(page),
                y: .zero
            )
            self.collectionView.setContentOffset(offset, animated: true)
            self.nextButton.fadeIn()
        }
    }
    
    // MARK: - Actions
    @objc
    private func closeButtonTapped() {
        viewModel?.closeButtonTapped()
    }
    
    @objc
    private func nextButtonPressed() {
        viewModel?.nextButtonTapped()
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
                    cell?.configure(model: model)
                    return cell
                case .bottomCell(let model):
                    let cell = self?.collectionView.reusableCell(classCell: RateUsBottomCell.self, indexPath: indexPath)
                    cell?.configure(model: model)
                    return cell
                }
            }
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) is RateUsBottomCell else { return }
            viewModel?.cellSelected(at: indexPath)
    }
    
}

// MARK: - UI
extension RateUsViewController {
    
    private func addSubViews() {
        view.backgroundColor = .white
        view.addSubviews([
            collectionView,
            closeButton,
            nextButton
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
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(40)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(64)
        }

    }
}
