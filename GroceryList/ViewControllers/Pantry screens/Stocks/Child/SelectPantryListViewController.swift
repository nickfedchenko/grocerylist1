//
//  SelectPantryListViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 06.06.2023.
//

import UIKit

class SelectPantryListViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    enum Section: Hashable {
        case main
    }
    weak var delegate: EditSelectListDelegate?
    
    private var viewModel: SelectPantryListViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Section, PantryModel>?
    private var contentViewHeigh: Double = 0
    
    private let contentView: UIView = {
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
    
    private lazy var createListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = viewModel.state.title
        label.textAlignment = .center
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setTitle(R.string.localizable.cancel(), for: .normal)
        button.setTitleColor(R.color.edit(), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.semibold(size: 16).font
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let topSafeArea = UIView.safeAreaTop
        let layout = PantryCollectionViewLayout().createCompositionalLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset.bottom = 60
        collectionView.contentInset.top = 16
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.register(classCell: PantryCell.self)
        return collectionView
    }()
    
    private let bottomCreateListView = AddListView()
    
    init(viewModel: SelectPantryListViewModel, contentViewHeigh: Double) {
        self.viewModel = viewModel
        self.contentViewHeigh = contentViewHeigh
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        createDataSource()
        reloadData()
        addRecognizer()
        setupConstraints()
        
        viewModel.reloadData = { [weak self] in
            self?.reloadData()
        }
    }
    
    deinit {
        print("select pantry list deinit")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateConstr(with: 0, compl: nil)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.backgroundColor = R.color.background()
        collectionView.register(classCell: PantryCell.self)
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                                      cellProvider: { _, indexPath, model in
            let cell = self.collectionView.reusableCell(classCell: PantryCell.self, indexPath: indexPath)
            let cellModel = self.viewModel.getCellModel(by: indexPath, and: model)
            cell.configure(cellModel)
            return cell
        })
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PantryModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.pantries)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func addRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(panRecognizer)
        
        let dismissRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissAction(_:)))
        dismissRecognizerView.addGestureRecognizer(dismissRecognizer)
        
        let createListRecognizer = UITapGestureRecognizer(target: self, action: #selector(createListAction))
        bottomCreateListView.addGestureRecognizer(createListRecognizer)
    }
    
    private func hidePanel() {
        self.view.backgroundColor = .clear
        updateConstr(with: -contentViewHeigh) {
            self.dismiss(animated: true)
        }
    }
    
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
    
    @objc
    private func closeButtonAction() {
        hidePanel()
    }
    
    @objc
    private func createListAction() {
        viewModel.createNewListWithEditModeTapped(controller: self)
    }
    
    private func setupConstraints() {
        view.backgroundColor = .clear
        view.addSubviews([contentView, dismissRecognizerView, bottomCreateListView])
        contentView.addSubviews([topView, collectionView])
        topView.addSubviews([createListLabel, closeButton])
        
        dismissRecognizerView.snp.makeConstraints {
            $0.top.right.left.equalToSuperview()
            $0.bottom.equalTo(contentView.snp.top)
        }
        
        contentView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(-contentViewHeigh)
            $0.height.equalTo(contentViewHeigh)
        }
        
        topView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        createListLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(20)
            $0.center.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(22)
            $0.centerY.equalTo(createListLabel)
            $0.height.equalTo(40)
        }
        
        bottomCreateListView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
            $0.height.equalTo(82)
            $0.width.equalTo(self.view.frame.width / 2)
        }
    }
}

extension SelectPantryListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = dataSource?.itemIdentifier(for: indexPath) else { return }
        viewModel.saveCopiedStock(to: model, controller: self)
        if viewModel.state == .move {
            delegate?.productsSuccessfullyMoved()
        } else {
            delegate?.productsSuccessfullyCopied()
        }
        dismiss(animated: true)
    }
}

extension SelectPantryListViewController: SelectListViewModelDelegate {
    func dismissController() {
        hidePanel()
    }
    
    func presentSelectedVC(controller: UIViewController) {
        self.present(controller, animated: true)
    }
}
