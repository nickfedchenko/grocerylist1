//
//  GroseryListsTableViewCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import SnapKit
import UIKit

class GroceryListsCollectionViewCell: UICollectionViewCell {
    
    var swipeDeleteAction: (() -> Void)?
    var swipeToAddOrDeleteFromFavorite: (() -> Void)?
    
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
        swipeToAddOrDeleteFavorite.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        swipeToDeleteImageView.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        setupConstraints()
        addGestureRecognizers()
        contentViews.layer.cornerRadius = 0
    }
    
    func setupCell(nameOfList: String, bckgColor: UIColor, isTopRounded: Bool,
                   isBottomRounded: Bool, numberOfItemsInside: String, isFavorite: Bool) {
        countLabel.text = numberOfItemsInside
        contentViews.backgroundColor = bckgColor
        nameLabel.text = nameOfList
        
        swipeToAddOrDeleteFavorite.image = isFavorite ? UIImage(named: "swipeTeDeleteFromFavorite") : UIImage(named: "swipeToAddToFavorite")
        
        if isBottomRounded {
            contentViews.layer.cornerRadius = 8
            contentViews.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        
        if isTopRounded {
            contentViews.layer.cornerRadius = 8
            contentViews.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        
        if isBottomRounded && isTopRounded {
            contentViews.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    @objc
    private func swipeAction(_ recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .right:
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.swipeToDeleteImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.contentViews.snp.updateConstraints { make in
                    make.left.equalToSuperview().inset(65)
                    make.right.equalToSuperview().inset(-56)
                }
                self.layoutIfNeeded()
            } completion: { _ in
                self.swipeDeleteAction?()
            }
            
            self.layoutIfNeeded()
        case .left:
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.swipeToAddOrDeleteFavorite.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.contentViews.snp.updateConstraints { make in
                    make.right.equalToSuperview().inset(65)
                    make.left.equalToSuperview().inset(-7)
                }
                self.layoutIfNeeded()
            } completion: { _ in
                
            }
        default:
            print("")
        }
        
    }
    
    private func addGestureRecognizers() {
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRightRecognizer.direction = .right
        contentViews.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeLeftRecognizer.direction = .left
        contentViews.addGestureRecognizer(swipeLeftRecognizer)
    }
    
    private let contentViews: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nameLabel: UILabel = {
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
        return imageView
    }()
    
    private let swipeToAddOrDeleteFavorite: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "swipeToAddToFavorite")
        return imageView
    }()
    
     
    // MARK: - UI
    private func setupConstraints() {
        backgroundColor = UIColor(hex: "#E8F5F3")
        self.addSubviews([contentViews, swipeToDeleteImageView, swipeToAddOrDeleteFavorite])
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
