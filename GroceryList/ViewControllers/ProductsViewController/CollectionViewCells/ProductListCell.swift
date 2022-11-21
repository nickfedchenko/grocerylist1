//
//  ProductListCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.11.2022.
//

import SnapKit
import UIKit

class ProductListCell: UICollectionViewListCell {

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
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
         let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
         attrs.bounds.size.height = 56
         return attrs
     }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.textColor = .black
        nameLabel.attributedText = NSAttributedString(string: "")
        clearTheCell()
    }
    
    func setupCell(bcgColor: UIColor?, textColor: UIColor?, text: String?, isPurchased: Bool) {
        contentView.backgroundColor = bcgColor
        checkmarkImage.image = isPurchased ? getImageWithColor(color: textColor) : UIImage(named: "emptyCheckmark")
        guard let text = text else { return }

        nameLabel.attributedText = NSAttributedString(string: text)
        if isPurchased {
            nameLabel.textColor = textColor
        }
    }
    
    func addCheckmark(color: UIColor?, compl: @escaping (() -> Void) ) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.checkmarkImage.image = self.getImageWithColor(color: color)
            self.nameLabel.attributedText = self.nameLabel.text?.strikeThrough()
            self.layoutIfNeeded()
        } completion: { _ in
            compl()
        }
    }
    
    func removeCheckmark(compl: @escaping (() -> Void) ) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.checkmarkImage.image = UIImage(named: "emptyCheckmark")
            guard let text = self.nameLabel.text else { return }
            self.nameLabel.attributedText = NSAttributedString(string: text)
            self.nameLabel.textColor = .black
            self.layoutIfNeeded()
        } completion: { _ in
            compl()
        }
    }
    
    func getImageWithColor(color: UIColor?) -> UIImage? {
        let size = CGSize(width: 28, height: 28)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let color = color else { return nil }
        color.setFill()
        UIRectFill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = image else { return nil }
        return image.rounded(radius: 100)
    }
    
    private let contentViews: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "emptyCheckmark")
        return imageView
    }()
    
    private let whiteCheckmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "whiteCheckmark")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        return label
    }()
    
    private let swipeToDeleteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "redDeleteImage")
        return imageView
    }()
    
    private let swipeToAddOrDeleteFavorite: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "greenPinchImage")
        return imageView
    }()
    
    // MARK: - UI
    private func setupConstraints() {
        contentView.addSubviews([swipeToDeleteImageView, swipeToAddOrDeleteFavorite, contentViews])
        contentViews.addSubviews([nameLabel, checkmarkImage, whiteCheckmarkImage])
        
        contentViews.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
        }
        
        checkmarkImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(checkmarkImage.snp.right).inset(-12)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(8)
        }
        
        whiteCheckmarkImage.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(checkmarkImage)
            make.width.height.equalTo(17)
        }
        
        swipeToAddOrDeleteFavorite.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentViews)
            make.right.equalToSuperview().inset(-1)
            make.width.equalTo(68)
        }
        
        swipeToDeleteImageView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentViews)
            make.left.equalToSuperview().inset(-1)
            make.width.equalTo(68)
        }
    }
}

// MARK: - Swipe to delete
extension ProductListCell {
    private func addGestureRecognizers() {
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRightRecognizer.direction = .right
        contentViews.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeLeftRecognizer.direction = .left
        contentViews.addGestureRecognizer(swipeLeftRecognizer)
    }
    
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
            guard nameLabel.textColor == .black else { return }
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
                make.left.equalToSuperview().inset(60)
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
                make.left.right.equalToSuperview().inset(16)
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
                make.right.equalToSuperview().inset(60)
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
                make.left.right.equalToSuperview().inset(16)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .normal
        }
    }
    
    private func clearTheCell() {
        swipeToAddOrDeleteFavorite.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        swipeToDeleteImageView.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        contentViews.snp.updateConstraints { make in
            make.left.right.equalToSuperview().inset(16)
        }
        state = .normal
        self.layoutIfNeeded()
    }
}
