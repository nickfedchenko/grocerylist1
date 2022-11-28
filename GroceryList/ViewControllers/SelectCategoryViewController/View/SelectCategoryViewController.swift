//
//  SelectCategoryViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.11.2022.
//

import SnapKit
import UIKit

class SelectCategoryViewController: UIViewController {
    
    var viewModel: SelectCategoryViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupController()
        setupCollectionView()
    }
    
    deinit {
        print("select category deinited ")
    }
    
    private func setupController() {
        view.backgroundColor = viewModel?.getBackgroundColor()
        titleCenterLabel.textColor = viewModel?.getForegroundColor()
    }
    
    @objc
    private func arrowBackButtonPressed() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    private func addButtonPressed() {
        viewModel?.addNewCategoryTapped()
    }
    
    // MARK: - UI
    
    private let navigationView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var arrowBackButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(arrowBackButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "greenArrowBack"), for: .normal)
        return button
    }()
    
    private let titleCenterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.text = "SelectCategory".localized
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "greenPlus"), for: .normal)
        return button
    }()
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .vertical
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        view.addSubviews([navigationView, collectionView])
        navigationView.addSubviews([arrowBackButton, titleCenterLabel, addButton])
        
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.right.left.equalToSuperview()
            make.height.equalTo(66)
        }
        
        arrowBackButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.centerY.equalToSuperview()
            make.width.equalTo(17)
            make.height.equalTo(24)
        }
        
        titleCenterLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(26)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom)
        }
    }
}

// MARK: - CollcetionView
extension SelectCategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(SelectCategoryCell.self, forCellWithReuseIdentifier: "SelectCategoryCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.getNumberOfCells() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectCategoryCell",
            for: indexPath) as? SelectCategoryCell, let viewModel = viewModel else { return UICollectionViewCell() }
        let backgroundColor = viewModel.getBackgroundColor()
        let foregroundColor = viewModel.getForegroundColor()
        let title = viewModel.getTitleText(at: indexPath.row)
        let isSelected = viewModel.isCellSelected(at: indexPath.row)
        cell.setupCell(title: title, isSelected: isSelected, foregroundColor: foregroundColor, lineColor: backgroundColor)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.selectCell(at: indexPath.row)
    }
}

// MARK: - Delegate
extension SelectCategoryViewController: SelectCategoryViewModelDelegate {
    func presentController(controller: UIViewController?) {
        guard let controller else { return }
        self.present(controller, animated: true)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}
