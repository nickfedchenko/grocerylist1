//
//  PantryCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 23.05.2023.
//

import UIKit

protocol PantryCellDelegate: AnyObject {
    func tapMoveButton(gesture: UILongPressGestureRecognizer)
    func tapContextMenu(point: CGPoint, cell: PantryCell)
    func tapSharing(cell: PantryCell)
}

final class PantryCell: UICollectionViewCell {
    
    struct CellModel {
        let theme: Theme
        let name: String
        let icon: UIImage?
        let sharingState: SharingView.SharingState
        let sharingUser: [String?]
        let stockCount: String
        let outOfStockCount: String
    }
    
    weak var delegate: PantryCellDelegate?
    
    private let mainContainer = UIView()
    private let mainContainerShadowOneView = UIView()
    private let mainContainerShadowTwoView = UIView()
    
    private let topContainer = UIView()
    private let topColorView = UIView()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.SFPro.semibold(size: 20).font
        label.numberOfLines = 2
        return label
    }()
    private let capitalLetterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.SFProRounded.heavy(size: 22).font
        label.textAlignment = .center
        return label
    }()
    private let iconImageView = UIImageView()
    private let sharingView = SharingView()
    
    private let bottomColorContainer = UIView()
    private let bottomWhiteView = UIView()
    private let outOfStockView = OutOfStockView()
    private lazy var moveImageView = UIImageView()
    private lazy var contextMenuButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedContextMenuButton), for: .touchUpInside)
        return button
    }()
    
    private let moveImage = R.image.pantry_move()
    private let menuImage = R.image.pantry_context_menu()
    
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
        topColorView.backgroundColor = cellModel.theme.medium
        if let icon = cellModel.icon {
            iconImageView.image = icon.withTintColor(.white)
            capitalLetterLabel.isHidden = true
        } else {
            iconImageView.isHidden = true
            capitalLetterLabel.text = cellModel.name.first?.uppercased()
        }
        
        nameLabel.text = cellModel.name
        sharingView.configure(state: cellModel.sharingState, viewState: .pantry,
                              color: cellModel.theme.medium, images: cellModel.sharingUser)
        
        bottomColorContainer.backgroundColor = cellModel.theme.medium
        moveImageView.image = moveImage?.withTintColor(cellModel.theme.medium)
        contextMenuButton.setImage(menuImage?.withTintColor(cellModel.theme.dark), for: .normal)
        outOfStockView.configure(color: cellModel.theme.dark,
                                 total: cellModel.stockCount, outOfStock: cellModel.outOfStockCount)
    }
    
    func addDragAndDropShadow() {
        mainContainerShadowOneView.addShadow(color: UIColor(hex: "858585"), opacity: 0.3,
                                                   radius: 6, offset: CGSize(width: 0, height: 8))
        mainContainerShadowTwoView.addShadow(color: UIColor(hex: "484848"), opacity: 0.55,
                                                   radius: 2, offset: CGSize(width: 0, height: 2))
    }
    
    func removeDragAndDropShadow() {
        DispatchQueue.main.async {
            self.mainContainerShadowOneView.addShadow(color: UIColor(hex: "858585"), opacity: 0.1,
                                                       radius: 6, offset: CGSize(width: 0, height: 4))
            self.mainContainerShadowTwoView.addShadow(color: UIColor(hex: "484848"), opacity: 0.15,
                                                       radius: 1, offset: CGSize(width: 0, height: 0.5))
        }
    }
    
    private func setupCell() {
        [mainContainerShadowOneView, mainContainerShadowTwoView, mainContainer].forEach {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 8
            $0.layer.cornerCurve = .continuous
        }
        mainContainer.clipsToBounds = true
        mainContainerShadowOneView.addShadow(color: UIColor(hex: "858585"), opacity: 0.1,
                                                   radius: 6, offset: CGSize(width: 0, height: 4))
        mainContainerShadowTwoView.addShadow(color: UIColor(hex: "484848"), opacity: 0.15,
                                                   radius: 1, offset: CGSize(width: 0, height: 0.5))
        
        topContainer.backgroundColor = .white
        topColorView.layer.cornerRadius = 8
        topColorView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
        bottomWhiteView.backgroundColor = .white
        bottomWhiteView.layer.cornerRadius = 8
        bottomWhiteView.layer.maskedCorners = [.layerMinXMinYCorner]
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnMoveButton))
        moveImageView.isUserInteractionEnabled = true
        moveImageView.addGestureRecognizer(longPressGesture)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnSharingView))
        sharingView.addGestureRecognizer(tapRecognizer)
    }
    
    private func clearCell() {
        iconImageView.image = nil
        iconImageView.isHidden = false
        capitalLetterLabel.isHidden = false
        
        moveImageView.image = nil
        contextMenuButton.setImage(menuImage, for: .normal)
        outOfStockView.clearView()
        sharingView.clearView()
        self.layoutIfNeeded()
    }
    
    @objc
    private func longPressOnMoveButton(_ gesture: UILongPressGestureRecognizer) {        
        delegate?.tapMoveButton(gesture: gesture)
    }
    
    @objc
    private func tappedContextMenuButton() {
        delegate?.tapContextMenu(point: contextMenuButton.center, cell: self)
    }
    
    @objc
    private func tapOnSharingView() {
        delegate?.tapSharing(cell: self)
    }
    
    private func makeConstraints() {
        contentView.addSubviews([mainContainerShadowOneView, mainContainerShadowTwoView, mainContainer])
        mainContainer.addSubviews([topContainer, bottomColorContainer])
        topContainer.addSubviews([topColorView, capitalLetterLabel, iconImageView, nameLabel, sharingView])
        bottomColorContainer.addSubviews([bottomWhiteView, outOfStockView, moveImageView, contextMenuButton])
        
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
        
        topContainer.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        bottomColorContainer.snp.makeConstraints {
            $0.top.equalTo(topContainer.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        makeTopContainerConstraints()
        makeBottomContainerConstraints()
    }
    
    private func makeTopContainerConstraints() {
        topColorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.top.equalToSuperview().offset(12)
            $0.height.width.equalTo(32)
        }
        
        capitalLetterLabel.snp.makeConstraints {
            $0.edges.equalTo(iconImageView)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
            $0.trailing.equalTo(sharingView.snp.leading).offset(16)
            $0.centerY.equalTo(iconImageView)
        }
        
        sharingView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(32)
        }
    }
    
    private func makeBottomContainerConstraints() {
        bottomWhiteView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        outOfStockView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(4)
            $0.trailing.lessThanOrEqualTo(moveImageView.snp.leading).offset(-4)
            $0.bottom.equalToSuperview().offset(-4)
        }
        
        moveImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(32)
        }
        
        contextMenuButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.width.equalTo(32)
        }
    }
}

final class OutOfStockView: UIView {
    
    private let outColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let outLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.SFProRounded.semibold(size: 14).font
        return label
    }()
    
    private let slashLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 14).font
        label.text = "/"
        return label
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 14).font
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(color: UIColor, total: String, outOfStock: String) {
        totalLabel.text = total
        totalLabel.textColor = color
        guard !outOfStock.isEmpty else {
            outColorView.isHidden = true
            slashLabel.isHidden = true
            totalLabel.snp.remakeConstraints {
                $0.leading.equalToSuperview().offset(8)
                $0.trailing.centerY.equalToSuperview()
            }
            return
        }
        
        outColorView.backgroundColor = color
        slashLabel.textColor = color
        
        outLabel.text = R.string.localizable.out() + outOfStock
    }
    
    func clearView() {
        outColorView.backgroundColor = .white
        slashLabel.textColor = .white
        totalLabel.textColor = .white
        
        outColorView.isHidden = false
        slashLabel.isHidden = false
        
        totalLabel.snp.remakeConstraints {
            $0.leading.equalTo(slashLabel.snp.trailing).offset(9)
            $0.trailing.centerY.equalToSuperview()
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([outColorView, slashLabel, totalLabel])
        outColorView.addSubview(outLabel)
        
        outColorView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        
        outLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
        }
        
        slashLabel.snp.makeConstraints {
            $0.leading.equalTo(outColorView.snp.trailing).offset(9)
            $0.centerY.equalToSuperview()
        }
        
        totalLabel.snp.makeConstraints {
            $0.leading.equalTo(slashLabel.snp.trailing).offset(9)
            $0.trailing.centerY.equalToSuperview()
        }
    }
}
