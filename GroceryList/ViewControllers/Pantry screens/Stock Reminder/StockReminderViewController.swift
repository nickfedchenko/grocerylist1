//
//  StockReminderViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 10.06.2023.
//

import UIKit

class StockReminderViewController: UIViewController {

    enum Section {
        case main
    }
    
    private let viewModel: StockReminderViewModel
    
    private let contentView = UIView()
    private let navigationView = UIView()
    private let iconImageView = UIImageView(image: R.image.reminder_stock_icon())
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.stocksAreOver()
        label.textColor = R.color.darkGray()
        label.font = UIFont.SFPro.bold(size: 22).font
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.done(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = R.color.primaryDark()
        button.titleLabel?.font = UIFont.SFPro.semibold(size: 18).font
        button.addTarget(self, action: #selector(tappedDoneButton), for: .touchUpInside)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.layer.maskedCorners = [.layerMinXMaxYCorner]
        button.contentEdgeInsets.left = 20
        button.contentEdgeInsets.right = 20
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = compositionalLayout
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset.bottom = 132
        collectionView.contentInset.top = 72
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.register(classCell: StockCell.self)
        return collectionView
    }()
    
    private lazy var addToShoppingListButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.addtoshoppinglisT().uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = R.color.darkGray()
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.addTarget(self, action: #selector(tappedAddToButton), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.addDefaultShadowForPopUp()
        return button
    }()
    
    private lazy var compositionalLayout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(56))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .estimated(1))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        return layout
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Stock>?
    
    private var contentViewHeight = 216.0
    private var addToButtonOffset = 8.0
    
    init(viewModel: StockReminderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedDoneButton))
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
        
        viewModel.reloadData = { [weak self] in
            self?.reloadDataSource()
        }
        
        setupContentView()
        createDataSource()
        reloadDataSource()
        
        calculateContentViewHeight()
        makeConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showContentView()
    }
    
    deinit {
        print("StockReminderViewController deinited")
    }
    
    private func setupContentView() {
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        swipeDownRecognizer.direction = .down
        contentView.addGestureRecognizer(swipeDownRecognizer)
        contentView.backgroundColor = R.color.background()
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        navigationView.backgroundColor = R.color.background()?.withAlphaComponent(0.9)
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                        cellProvider: { _, indexPath, model in
            let cell = self.collectionView.reusableCell(classCell: StockCell.self, indexPath: indexPath)
            let cellModel = self.viewModel.getCellModel(model: model)
            cell.configure(cellModel)
            return cell
        })
    }
    
    private func reloadDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Stock>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.stocks)
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func calculateContentViewHeight() {
        let maxHeight = self.view.frame.height - 50
        contentViewHeight += viewModel.necessaryHeight
        addToButtonOffset += viewModel.necessaryHeight
        collectionView.isScrollEnabled = contentViewHeight > maxHeight
        contentViewHeight = contentViewHeight > maxHeight ? maxHeight : contentViewHeight
    }

    private func hideContentView() {
        updateConstraints(with: contentViewHeight, alpha: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.viewModel.dismissView()
            self.dismiss(animated: false)
        }
    }
    
    private func showContentView() {
        updateConstraints(with: 0, alpha: 0.2)
    }
    
    private func updateConstraints(with offset: Double, alpha: Double) {
        contentView.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(offset)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.backgroundColor = .black.withAlphaComponent(alpha)
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func tappedDoneButton() {
        hideContentView()
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .down:
            hideContentView()
        default: break
        }
    }
    
    @objc
    private func tappedAddToButton() {
        viewModel.showSyncList(contentViewHeigh: self.view.frame.height * 0.75)
    }
    
    private func makeConstraints() {
        self.view.addSubview(contentView)
        contentView.addSubviews([collectionView, navigationView])
        collectionView.addSubview(addToShoppingListButton)
        navigationView.addSubviews([iconImageView, titleLabel, doneButton])
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(contentViewHeight)
            $0.height.equalTo(contentViewHeight)
        }
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        navigationView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(24)
            $0.height.width.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
            $0.trailing.equalTo(doneButton.snp.leading).offset(-24)
            $0.centerY.equalTo(iconImageView)
        }
        
        doneButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        addToShoppingListButton.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(addToButtonOffset)
            $0.leading.equalTo(self.view).offset(16)
            $0.trailing.equalTo(self.view).offset(-16)
            $0.height.equalTo(64)
        }
    }
}

extension StockReminderViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let stock = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        let cell = collectionView.cellForItem(at: indexPath) as? StockCell
        viewModel.updateStockStatus(stock: stock)
    }
}

extension StockReminderViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.collectionView) ?? false)
    }
}
