//
//  PhotoFromRecipesViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.06.2023.
//

import UIKit

final class PhotoFromRecipesViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    private var viewModel: PhotoFromRecipesViewModel
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.95)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Photo from recipes"
        label.font = UIFont.SFPro.semibold(size: 22).font
        label.textColor = R.color.primaryDark()
        return label
    }()
    
    private lazy var photoButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.mediaLibrary(), for: .normal)
        button.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(classCell: PhotoFromRecipesCell.self)
        collectionView.contentInset.top = 86
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private var imagePicker = UIImagePickerController()
    
    init(viewModel: PhotoFromRecipesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePanel))
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(panRecognizer)
        
        makeConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateConstraint(isShow: true)
    }
    
    @objc
    private func photoButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .pageSheet
            present(imagePicker, animated: true, completion: nil)
        }
    }

    @objc
    private func hidePanel() {
        updateConstraint(isShow: false)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false)
        }
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
    
    private func updateConstraint(isShow: Bool) {
        contentView.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(isShow ? 0 : 650)
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.backgroundColor = .black.withAlphaComponent(isShow ? 0.2 : 0)
            self?.view.layoutIfNeeded()
        }
    }
    
    private func makeConstraints() {
        self.view.addSubviews([contentView])
        contentView.addSubviews([collectionView, headerView])
        headerView.addSubviews([titleLabel, photoButton])
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(650)
            $0.height.equalTo(650)
        }
        
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(86)
        }
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        photoButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(40)
        }
    }
}

extension PhotoFromRecipesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.photosCount
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: PhotoFromRecipesCell.self, indexPath: indexPath)
        cell.configure(image: viewModel.getPhoto(by: indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (view.bounds.width - 4) / 3
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let image = viewModel.getPhoto(by: indexPath)
        viewModel.savePhoto(image: image)
        hidePanel()
    }
}

extension PhotoFromRecipesViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        viewModel.savePhoto(image: image)
        hidePanel()
    }
}

extension PhotoFromRecipesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.contentView) ?? false)
    }
}
