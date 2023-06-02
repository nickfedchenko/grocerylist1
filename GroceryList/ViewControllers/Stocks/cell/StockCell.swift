//
//  StockCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.06.2023.
//

import UIKit

protocol StockCellDelegate: AnyObject {
    func tapMoveButton(gesture: UILongPressGestureRecognizer)
    func tapSelectEditState(cell: StockCell)
}

final class StockCell: UICollectionViewCell {
    
    struct CellModel {
        let theme: Theme
        let name: String
        let description: String?
        let image: UIImage?
        let isRepeat: Bool
        let isReminder: Bool
        let inStock: Bool
    }
    
    weak var delegate: StockCellDelegate?
    
    private let mainContainer = UIView()
    private let mainContainerShadowOneView = UIView()
    private let mainContainerShadowTwoView = UIView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var repeatImageView = UIImageView(image: R.image.repeat())
    private lazy var reminderImageView = UIImageView(image: R.image.reminder())
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 13).font
        return label
    }()
    
    private let stockView = UIView()
    private let stockImageView = UIImageView()
    
    private let storeView = UIView()
    
    private let editView = UIView()
    private let moveImageView = UIImageView()
    private let selectImageView = UIImageView()
    
    private let checkImage = R.image.checkmark()?.withTintColor(.white)
    private let crossImage = R.image.whiteCross()?.withTintColor(.black)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearCell()
    }
    
    func configure(_ cellModel: CellModel) {
        setupColor(theme: cellModel.theme, inStock: cellModel.inStock)
        
        nameLabel.text = cellModel.name
        imageView.image = cellModel.image
        descriptionLabel.text = cellModel.description
        stockImageView.image = cellModel.inStock ? checkImage : crossImage
        
        updateConstraints(cellModel: cellModel)
    }
    
    func addDragAndDropShadow() {
        mainContainerShadowOneView.addCustomShadow(color: UIColor(hex: "858585"), opacity: 0.3,
                                                   radius: 6, offset: CGSize(width: 0, height: 8))
        mainContainerShadowTwoView.addCustomShadow(color: UIColor(hex: "484848"), opacity: 0.55,
                                                   radius: 2, offset: CGSize(width: 0, height: 2))
    }
    
    func removeDragAndDropShadow() {
        DispatchQueue.main.async {
            self.mainContainerShadowOneView.addCustomShadow(color: UIColor(hex: "858585"), opacity: 0.1,
                                                       radius: 6, offset: CGSize(width: 0, height: 4))
            self.mainContainerShadowTwoView.addCustomShadow(color: UIColor(hex: "484848"), opacity: 0.15,
                                                       radius: 1, offset: CGSize(width: 0, height: 0.5))
        }
    }
    
    private func setupCell() {
        [mainContainerShadowOneView, mainContainerShadowTwoView, mainContainer].forEach {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 8
            $0.layer.cornerCurve = .continuous
        }
        mainContainerShadowOneView.addCustomShadow(opacity: 0.12,
                                                   radius: 3.5, offset: CGSize(width: 0, height: 2))
        mainContainerShadowTwoView.addCustomShadow(radius: 0.22, offset: CGSize(width: 0, height: 0.25))

        stockView.layer.cornerRadius = 4
        stockView.layer.cornerCurve = .continuous
        
        editView.isHidden = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnMoveButton))
        moveImageView.isUserInteractionEnabled = true
        moveImageView.addGestureRecognizer(longPressGesture)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapSelectEditState))
        selectImageView.addGestureRecognizer(tapRecognizer)
    }
    
    private func clearCell() {
        imageView.image = nil
        editView.isHidden = false
        
        repeatImageView.snp.updateConstraints { $0.width.equalTo(15) }
        reminderImageView.snp.updateConstraints { $0.width.equalTo(15) }
        
        self.layoutIfNeeded()
    }
    
    private func setupColor(theme: Theme, inStock: Bool) {
        nameLabel.textColor = theme.dark
        descriptionLabel.textColor = theme.dark
        repeatImageView.image = repeatImageView.image?.withTintColor(theme.dark)
        reminderImageView.image = reminderImageView.image?.withTintColor(theme.dark)
        
        mainContainer.backgroundColor = inStock ? theme.light : .white
        stockView.backgroundColor = inStock ? theme.medium : R.color.lightGray()
    }
    
    private func updateConstraints(cellModel: CellModel) {
        if cellModel.isReminder || cellModel.isRepeat || cellModel.description != nil {
            nameLabel.snp.updateConstraints { $0.top.equalToSuperview().offset(6) }
        }
        
        if !cellModel.isRepeat {
            repeatImageView.snp.updateConstraints { $0.width.equalTo(0) }
            reminderImageView.snp.updateConstraints { $0.leading.equalTo(repeatImageView.snp.trailing).offset(0) }
        }
            
        if !cellModel.isReminder {
            reminderImageView.snp.updateConstraints { $0.width.equalTo(0) }
            descriptionLabel.snp.updateConstraints { $0.leading.equalTo(reminderImageView.snp.trailing).offset(0) }
        }
        
        if cellModel.image == nil {
            imageView.snp.updateConstraints { $0.width.equalTo(0) }
        }
    }
    
    @objc
    private func longPressOnMoveButton(_ gesture: UILongPressGestureRecognizer) {
        delegate?.tapMoveButton(gesture: gesture)
    }
    
    @objc
    private func tapSelectEditState() {
        delegate?.tapSelectEditState(cell: self)
    }
    
    private func makeConstraints() {
        contentView.addSubviews([mainContainerShadowOneView, mainContainerShadowTwoView, mainContainer])
        mainContainer.addSubviews([imageView, nameLabel, descriptionLabel,
                                   repeatImageView, reminderImageView, stockView, editView])
        stockView.addSubview(stockImageView)
        editView.addSubviews([moveImageView, selectImageView])
        
        mainContainer.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        mainContainerShadowOneView.snp.makeConstraints {
            $0.edges.equalTo(mainContainer)
        }
        
        mainContainerShadowTwoView.snp.makeConstraints {
            $0.edges.equalTo(mainContainer)
        }
        
        makeCellConstraints()
        makeEditViewConstraints()
    }
    
    private func makeCellConstraints() {
        imageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(4)
            $0.height.width.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.top.equalToSuperview().offset(13.5)
            $0.trailing.equalTo(stockView.snp.leading).offset(-15)
        }
        
        repeatImageView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.height.width.equalTo(15)
        }
        
        reminderImageView.snp.makeConstraints {
            $0.leading.equalTo(repeatImageView.snp.trailing).offset(4)
            $0.centerY.equalTo(repeatImageView)
            $0.height.width.equalTo(15)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(reminderImageView.snp.trailing).offset(4)
            $0.centerY.equalTo(repeatImageView)
            $0.trailing.equalTo(stockView.snp.leading).offset(-15)
        }
        
        stockView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-11)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(26)
        }
        
        stockImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(14)
        }
    }
    
    private func makeEditViewConstraints() {
        editView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().offset(-4)
            $0.height.equalTo(40)
            $0.width.equalTo(80)
        }
        
        moveImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.height.width.equalTo(32)
        }
        
        selectImageView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.height.width.equalTo(40)
        }
    }
}
