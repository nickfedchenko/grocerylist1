//
//  GroseryListsTableViewCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import SnapKit
import UIKit

class GroceryCollectionViewCell: UICollectionViewCell {
    
    var swipeDeleteAction: (() -> Void)?
    var swipeToAddOrDeleteFromFavorite: (() -> Void)?
    var sharingAction: (() -> Void)?
    private var state: CellState = .normal
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        rightButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        leftButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        setupConstraints()
        addGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearTheCell()
    }
    
    private func clearTheCell() {
        rightButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        leftButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        contentViews.snp.updateConstraints { make in
            make.left.right.equalToSuperview().inset(20)
        }
        state = .normal
        contentViews.layer.cornerRadius = 0
        sharingView.clearView()
        self.layoutIfNeeded()
    }
    
    func addGestureRecognizers() {
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRightRecognizer.direction = .right
        contentViews.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeLeftRecognizer.direction = .left
        contentViews.addGestureRecognizer(swipeLeftRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        sharingView.addGestureRecognizer(tapRecognizer)
    }
    
    func setupCell(nameOfList: String, bckgColor: UIColor, isTopRounded: Bool,
                   isBottomRounded: Bool, numberOfItemsInside: String, isFavorite: Bool) {
        countLabel.text = numberOfItemsInside
        contentViews.backgroundColor = bckgColor
        nameLabel.text = nameOfList
       
        if isFavorite {
            leftButton.setImage(UIImage(named: "swipeToAddToFavorite"), for: .normal)
        } else {
            leftButton.setImage(UIImage(named: "swipeTeDeleteFromFavorite"), for: .normal)
        }
        if isBottomRounded && isTopRounded {
            contentViews.layer.cornerRadius = 8
            contentViews.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            return
        }
        
        if isBottomRounded {
            contentViews.layer.cornerRadius = 8
            contentViews.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        
        if isTopRounded {
            contentViews.layer.cornerRadius = 8
            contentViews.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    func setupSharing(state: SharingView.SharingState, color: UIColor, image: [String?]) {
        sharingView.configure(state: state, viewState: .main, color: color, images: image)
    }
    
    private let contentViews: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = .white
        return label
    }()
    
    private let sharingView: SharingView = {
        let view = SharingView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = .white
        return label
    }()
    
    private lazy var leftButton: UIButton = {
        let imageView = UIButton()
        imageView.setImage(UIImage(named: "swipeToAddToFavorite"), for: .normal)
        imageView.addTarget(self, action: #selector(pinchAction), for: .touchUpInside)
        return imageView
    }()
    
    private lazy var rightButton: UIButton = {
        let imageView = UIButton()
        imageView.setImage(UIImage(named: "swipeToDelete"), for: .normal)
        imageView.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        return imageView
    }()
    
    // MARK: - UI
    private func setupConstraints() {
        backgroundColor = UIColor(hex: "#E8F5F3")
        contentView.addSubviews([leftButton, rightButton, contentViews])
        contentViews.addSubviews([nameLabel, countLabel, sharingView])
        
        contentViews.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        sharingView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(11)
        }
        
        countLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(11)
        }
        
        leftButton.snp.makeConstraints { make in
            make.height.equalTo(contentViews)
            make.left.equalToSuperview()
            make.width.equalTo(72)
        }
        
        rightButton.snp.makeConstraints { make in
            make.height.equalTo(contentViews)
            make.right.equalToSuperview().inset(-1)
            make.width.equalTo(72)
        }
    }
}

// MARK: - Sharing
extension GroceryCollectionViewCell {
    
    @objc
    private func tapAction() {
        sharingAction?()
    }
}

// MARK: - Swipe to delete
extension GroceryCollectionViewCell {
    
    @objc
    private func pinchAction() {
        swipeToAddOrDeleteFromFavorite?()
    }
    
    @objc
    private func deleteAction() {
        swipeDeleteAction?()
    }
    
    @objc
    private func swipeAction(_ recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .right:
            if state == .swipedRight {
                DispatchQueue.main.async {
                    self.clearTheCell()
                }
                pinchAction()
            }
            if state == .normal { showDelete() }
            if state == .swipedLeft { hidePinch() }
            
        case .left:
            if state == .swipedLeft {
         
                DispatchQueue.main.async {
                    self.clearTheCell()
                }
                deleteAction()
            }
            if state == .normal { showPinch() }
            if state == .swipedRight { hideDelete() }
        default:
            print("")
        }
    }
    
    private func showDelete() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.leftButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.contentViews.snp.updateConstraints { make in
                make.left.equalToSuperview().inset(65)
                make.right.equalToSuperview().inset(-56)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .swipedRight
        }
    }
    
    private func hideDelete() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.leftButton.transform = CGAffineTransform(scaleX: 0, y: 1)
            self.contentViews.snp.updateConstraints { make in
                make.left.right.equalToSuperview().inset(20)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .normal
        }
    }
    
    private func showPinch() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.rightButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.contentViews.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(65)
                make.left.equalToSuperview().inset(-7)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .swipedLeft
        }
    }
    
    private func hidePinch() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.rightButton.transform = CGAffineTransform(scaleX: 0, y: 1)
            self.contentViews.snp.updateConstraints { make in
                make.left.right.equalToSuperview().inset(20)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .normal
        }
    }
}
