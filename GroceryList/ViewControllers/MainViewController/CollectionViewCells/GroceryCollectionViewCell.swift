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
    private var state: CellState = .normal
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        swipeToAddOrDeleteFavorite.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        swipeToDeleteImageView.transform = CGAffineTransform(scaleX: 0.0, y: 1)
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
        swipeToAddOrDeleteFavorite.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        swipeToDeleteImageView.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        contentViews.snp.updateConstraints { make in
            make.left.right.equalToSuperview().inset(20)
        }
        state = .normal
        contentViews.layer.cornerRadius = 0
        self.layoutIfNeeded()
    }
    
    func addGestureRecognizers() {
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRightRecognizer.direction = .right
        contentViews.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeLeftRecognizer.direction = .left
        contentViews.addGestureRecognizer(swipeLeftRecognizer)
        
                let tapPinchRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteAction))
                swipeToAddOrDeleteFavorite.addGestureRecognizer(tapPinchRecognizer)
        
                let tapDeleteRecognizer = UITapGestureRecognizer(target: self, action: #selector(pinchAction))
                swipeToDeleteImageView.addGestureRecognizer(tapDeleteRecognizer)
    }
    
    func setupCell(nameOfList: String, bckgColor: UIColor, isTopRounded: Bool,
                   isBottomRounded: Bool, numberOfItemsInside: String, isFavorite: Bool) {
        countLabel.text = numberOfItemsInside
        contentViews.backgroundColor = bckgColor
        nameLabel.text = nameOfList
        
        swipeToAddOrDeleteFavorite.image = isFavorite ? UIImage(named: "swipeTeDeleteFromFavorite") : UIImage(named: "swipeToAddToFavorite")
        
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
    
    private let contentViews: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        return label
    }()
    
    private let swipeToDeleteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "swipeToDelete")
         // imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let swipeToAddOrDeleteFavorite: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "swipeToAddToFavorite")
        // imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // MARK: - UI
    private func setupConstraints() {
        backgroundColor = UIColor(hex: "#E8F5F3")
        contentView.addSubviews([contentViews, swipeToDeleteImageView, swipeToAddOrDeleteFavorite])
        contentViews.addSubviews([nameLabel, countLabel])
        
        contentViews.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
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
        
        swipeToDeleteImageView.snp.makeConstraints { make in
            make.height.equalTo(contentViews)
            make.left.equalToSuperview()
            make.width.equalTo(72)
        }
        
        swipeToAddOrDeleteFavorite.snp.makeConstraints { make in
            make.height.equalTo(contentViews)
            make.right.equalToSuperview().inset(-1)
            make.width.equalTo(72)
        }
    }
}

// MARK: - Swipe to delete
extension GroceryCollectionViewCell {
    
    @objc
    private func deleteAction() {
        swipeDeleteAction?()
    }
    
    @objc
    private func pinchAction() {
        swipeToAddOrDeleteFromFavorite?()
    }
    
    @objc
    private func swipeAction(_ recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .right:
            if state == .readyToDelete {
                DispatchQueue.main.async {
                    self.clearTheCell()
                }
                swipeDeleteAction?()
            }
            if state == .normal { showDelete() }
            if state == .readyToPinch { hidePinch() }
            
        case .left:
            if state == .readyToPinch {
         
                DispatchQueue.main.async {
                    self.clearTheCell()
                }
                swipeToAddOrDeleteFromFavorite?()
            }
            if state == .normal { showPinch() }
            if state == .readyToDelete { hideDelete() }
        default:
            print("")
        }
    }
    
    private func showDelete() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.swipeToDeleteImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.contentViews.snp.updateConstraints { make in
                make.left.equalToSuperview().inset(65)
                make.right.equalToSuperview().inset(-56)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .readyToDelete
        }
    }
    
    private func hideDelete() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.swipeToDeleteImageView.transform = CGAffineTransform(scaleX: 0, y: 1)
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
            self.swipeToAddOrDeleteFavorite.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.contentViews.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(65)
                make.left.equalToSuperview().inset(-7)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .readyToPinch
        }
    }
    
    private func hidePinch() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.swipeToAddOrDeleteFavorite.transform = CGAffineTransform(scaleX: 0, y: 1)
            self.contentViews.snp.updateConstraints { make in
                make.left.right.equalToSuperview().inset(20)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .normal
        }
    }
}
