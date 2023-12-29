//
//  SelectListToSynchronizeViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 30.05.2023.
//

import UIKit

class SelectListToSynchronizeViewController: SelectListViewController {
    
    var selectedModelIds: Set<UUID> = []
    var updateUI: (([UUID]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        correctTitleLabel()
        correctCollectionView()
    }
    
    override func createTableViewDataSource() {
        collectionViewDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                                      cellProvider: { [weak self] _, indexPath, model in
            
            let cell = self?.collectionView.reusableCell(classCell: SelectListToSynchronizeCell.self,
                                                         indexPath: indexPath)
            guard let viewModel = self?.viewModel else { return UICollectionViewCell() }
            let name = viewModel.getNameOfList(at: indexPath)
            let isTopRouned = viewModel.isTopRounded(at: indexPath)
            let isBottomRounded = viewModel.isBottomRounded(at: indexPath)
            let numberOfItems = viewModel.getNumberOfProductsInside(at: indexPath)
            let color = viewModel.getBGColor(at: indexPath)
            cell?.setupCell(nameOfList: name, bckgColor: color, isTopRounded: isTopRouned,
                            isBottomRounded: isBottomRounded, numberOfItemsInside: numberOfItems,
                            isFavorite: model.isFavorite)
            cell?.setupColor(theme: viewModel.getTheme(at: indexPath))
            let isContains = self?.selectedModelIds.contains(model.id) ?? false
            if isContains {
                cell?.markAsSelect(isContains)
            }
            
            return cell
        })
        addHeaderToCollectionView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = collectionViewDataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as? SelectListToSynchronizeCell
        let isContains = selectedModelIds.contains(model.id)
        cell?.markAsSelect(!isContains)
        if isContains {
            selectedModelIds.remove(model.id)
        } else {
            selectedModelIds.insert(model.id)
        }
    }
    
    override func hidePanel() {
        super.hidePanel()
        updateUI?(Array(selectedModelIds))
    }

    private func correctCollectionView() {
        collectionView.register(classCell: SelectListToSynchronizeCell.self)
    }
    
    private func correctTitleLabel() {
        createListLabel.text = R.string.localizable.selectListToSynchronize()
        createListLabel.font = UIFont.SFProRounded.semibold(size: 17).font
        
        closeButton.setImage(nil, for: .normal)
        closeButton.setTitle(R.string.localizable.done(), for: .normal)
        closeButton.titleLabel?.font = UIFont.SFProRounded.bold(size: 17).font
        closeButton.setTitleColor(R.color.primaryDark(), for: .normal)
        closeButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().inset(22)
            make.centerY.equalTo(createListLabel)
            make.height.equalTo(40)
            make.width.greaterThanOrEqualTo(60)
        }
    }
    
}

class SelectListToSynchronizeCell: GroceryCollectionViewCell {
    
    private lazy var activeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 16
        imageView.alpha = 0
        return imageView
    }()
    
    private lazy var inactiveImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.inactiveSynchronize()
        return imageView
    }()
    
    private var theme: Theme?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addGestureRecognizers() { }
    
    func setupColor(theme: Theme?) {
        self.theme = theme
        activeImageView.image = R.image.activeSynchronize()?.withTintColor(theme?.dark ?? .black)
    }
    
    func markAsSelect(_ isSelected: Bool) {
        guard isSelected else {
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.inactiveImageView.alpha = 1
                self.activeImageView.alpha = 0
            }
            return
        }
        
        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4) {
                self.contentViews.backgroundColor = self.theme?.dark
                self.inactiveImageView.alpha = 0
                self.activeImageView.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.2) {
                self.contentViews.backgroundColor = self.theme?.medium.withAlphaComponent(0.9)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                self.contentViews.backgroundColor = self.theme?.medium
            }
        })
    }
    
    private func makeConstraints() {
        contentViews.addSubviews([activeImageView, inactiveImageView])
        
        [activeImageView, inactiveImageView].forEach { imageView in
            imageView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-16)
                $0.width.height.equalTo(32)
            }
        }
    }
}
