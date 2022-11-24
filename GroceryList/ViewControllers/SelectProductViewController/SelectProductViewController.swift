//
//  SelectProductViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import SnapKit
import UIKit

class SelectProductViewController: UIViewController {
    
    var viewModel: SelectProductViewModel?
    var contentViewHeigh: Double = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraint()
        setupController()
        addRecognizer()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateConstr(with: 0, compl: nil)
    }
    
    deinit {
        print("select product deinited")
    }
    
    private func setupController() {
        titleLabel.text = viewModel?.getNameOfList()
        titleLabel.textColor = viewModel?.getForegroundColor()
        contentView.backgroundColor = viewModel?.getColorForBackground()
        topView.backgroundColor = viewModel?.getColorForBackground()
    }
    
    @objc
    private func doneButtonPressed() {
        updateConstr(with: -contentViewHeigh) {
            self.dismiss(animated: true, completion: { [weak self] in
                self?.viewModel?.doneButtonPressed()
            })
        }
    }
    
    @objc
    private func arrowBackButtonPressed() {
        hidePanel()
    }

    func updateConstr(with inset: Double, compl: (() -> Void)?) {
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
    
    // MARK: - UI

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let topView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var arrowBackButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(arrowBackButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "greenArrowBack"), for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(string: "Done".localized, attributes: [
            .font: UIFont.SFPro.bold(size: 18).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#31635A")
        ])
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
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

    private func setupConstraint() {
        view.backgroundColor = .clear
        view.addSubviews([contentView])
        contentView.addSubviews([topView, collectionView])
        topView.addSubviews([arrowBackButton, titleLabel, doneButton])
       
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(contentViewHeigh)
        }
        
        topView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        arrowBackButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.centerY.equalToSuperview()
            make.width.equalTo(17)
            make.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(19)
            make.centerY.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom).inset(-20)
        }
    }
}

    // MARK: - CollcetionView
    extension SelectProductViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        private func setupCollectionView() {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(SelectProductCell.self, forCellWithReuseIdentifier: "SelectProductCell")
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return viewModel?.getNumberOfCell() ?? 0
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "SelectProductCell",
                for: indexPath) as? SelectProductCell,
                  let viewModel = viewModel else { return UICollectionViewCell() }
            
            let backgroundColor = viewModel.getColorForBackground()
            let foregroundColor = viewModel.getForegroundColor()
            let name = viewModel.getNameOfCell(at: indexPath.row)
            let isSelectAllButton = indexPath.row == 0 ? true : false
            let isProductSelected = viewModel.isProductSelected(at: indexPath.row)

                cell.setupCell(bcgColor: backgroundColor, foregroundColor: foregroundColor, text: name,
                               rightImage: nil, isSelected: isProductSelected, isSelectAllButton: isSelectAllButton)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: view.frame.width - 32, height: 48)
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 8
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            viewModel?.cellSelected(at: indexPath.row)
        }
    }

extension SelectProductViewController {
    
    private func addRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(panRecognizer)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
    
    private func hidePanel() {
        updateConstr(with: -contentViewHeigh) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension SelectProductViewController: SelectProductViewModelDelegate {
    func reloadCollection() {
        collectionView.reloadData()
    } 
}
