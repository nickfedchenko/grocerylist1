//
//  CollectionsViewController.swift
//  ActionExtension
//
//  Created by Хандымаа Чульдум on 03.08.2023.
//

import UIKit

class CollectionsViewController: UIViewController {
    
    struct SharedCollectionModel {
        let collection: CollectionModel
        var isSelected: Bool = false
    }
    
    private let navView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E5F5F3").withAlphaComponent(0.9)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.heavy(size: 32).font
        label.textColor = R.color.primaryDark()
        label.numberOfLines = 0
        label.text = R.string.localizable.collections()
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFCompactDisplay.semibold(size: 16).font
        label.textColor = R.color.darkGray()
        label.numberOfLines = 0
        label.text = R.string.localizable.selectOneOrMoreCollections()
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "045C5C")
        button.setTitle("Done".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.heavy(size: 17).font
        button.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        button.contentEdgeInsets.left = 20
        button.contentEdgeInsets.right = 20
        button.layer.cornerRadius = 20
        button.layer.cornerCurve = .continuous
        button.layer.maskedCorners = [.layerMinXMaxYCorner]
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private var collections: [SharedCollectionModel] = []
    
    private let recipe: WebRecipe
    private let url: String?
    
    init(recipe: WebRecipe, url: String?) {
        self.recipe = recipe
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        updateCollection()
    }
    
    private func setup() {
        self.view.backgroundColor = UIColor(hex: "#E5F5F3")
        
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        swipeDownRecognizer.direction = .down
        swipeDownRecognizer.delegate = self
        self.view.addGestureRecognizer(swipeDownRecognizer)
        
        setupTableView()
        makeConstraints()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 66
        tableView.register(classCell: ShowCollectionCell.self)
    }
    
    private func updateCollection() {
        var collections: [CollectionModel] = []
        guard var dbCollections = CoreDataManager.shared.getCollectionForSharedSheet() else {
            return
        }
        dbCollections.removeAll { $0.isDelete == true }
        collections = dbCollections.compactMap { CollectionModel(from: $0) }
        
        collections.sort { $0.index < $1.index }
        self.collections = collections.map({ SharedCollectionModel(collection: $0) })

        // папки will cook и inbox еще не реализованы, пока что их удаляем из списка коллекций
        self.collections.removeAll {
            $0.collection.id == EatingTime.inbox.rawValue ||
            $0.collection.id == EatingTime.willCook.rawValue
        }
        
        tableView.reloadData()
    }

    @objc
    private func swipeDownAction(_ recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .down: hideContentView()
        default: break
        }
    }
    
    @objc
    private func doneButtonAction() {
        hideContentView()
        doneButton.isUserInteractionEnabled = false
    }
    
    private func hideContentView() {
        AmplitudeManager.shared.logEvent(.recipeImportSave)
        let selectedCollection = collections.filter { $0.isSelected }
                                            .map { $0.collection }
        CoreDataManager.shared.saveWebRecipe(webRecipe: recipe, url: url,
                                             collections: selectedCollection)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: [])
        }
    }
    
    private func isTechnicalCollection(by index: Int) -> Bool {
        var isTechnicalCollection = false
        if let collectionId = collections[safe: index]?.collection.id,
           let defaultCollection = EatingTime(rawValue: collectionId) {
            isTechnicalCollection = defaultCollection.isTechnicalCollection
        }
        return isTechnicalCollection
    }
    
    private func goToCreateNewCollection(compl: @escaping (CollectionModel) -> Void) {
        let viewController = CreateNewCollectionViewController()
        let viewModel = CreateNewCollectionViewModel(currentCollection: nil)
        viewModel.updateUICallBack = compl
        viewController.viewModel = viewModel
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        self.present(viewController, animated: true)
    }

    private func makeConstraints() {
        self.view.addSubviews([tableView, navView])
        navView.addSubviews([titleLabel, descriptionLabel, doneButton])

        tableView.snp.makeConstraints {
            $0.top.equalTo(navView.snp.bottom).offset(-20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        navView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(doneButton.snp.leading).offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.top.equalToSuperview().offset(57)
            $0.bottom.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.greaterThanOrEqualTo(120)
        }
        doneButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        doneButton.setContentHuggingPriority(.init(1000), for: .horizontal)
    }
}

extension CollectionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(classCell: ShowCollectionCell.self, indexPath: indexPath)

        guard indexPath.row != 0 else {
            cell.configureCreateCollection()
            return cell
        }
        
        let index = indexPath.row - 1
        cell.configure(title: collections[index].collection.title,
                       count: collections[index].collection.dishes?.count ?? 0)
        cell.configure(isSelect: collections[index].isSelected)
        cell.configure(isTechnical: isTechnicalCollection(by: index))
        return cell
    }
}

extension CollectionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            goToCreateNewCollection { [weak self] newCollection in
                self?.updateCollection()
            }
            
            return
        }

        if  isTechnicalCollection(by: indexPath.row - 1) {
            return
        }
        
        collections[indexPath.row - 1].isSelected.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension CollectionsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.tableView) ?? false)
    }
}
