//
//  ShowCollectionCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 08.03.2023.
//

import UIKit

final class ShowCollectionCell: UITableViewCell {
    
    var deleteTapped: (() -> Void)?
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#62D3B4")
        view.layer.cornerRadius = 1
        return view
    }()
    
    private lazy var selectView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#85F3D5")
        return view
    }()
    
    private lazy var collectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = UIColor(hex: "#1A645A")
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = UIColor(hex: "#7A948F")
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var minusButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.deleteCollection(), for: .normal)
        button.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var trashButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.swipeToDelete(), for: .normal)
        button.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var isShowTrashButton = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.autoresizingMask = .flexibleHeight
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        minusButton.isHidden = true
        trashButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        iconImageView.snp.updateConstraints { $0.leading.equalToSuperview().offset(20) }
        countLabel.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-31) }
        bgView.snp.updateConstraints { $0.leading.trailing.equalToSuperview().offset(0) }
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if !subview.description.contains("Reorder") {
            return
        }
        (subview.subviews.first as? UIImageView)?.removeFromSuperview()

        let imageView = UIImageView()
        imageView.image = R.image.rearrange()
        subview.addSubview(imageView)
            
        imageView.snp.makeConstraints {
            $0.height.width.equalTo(40)
            $0.leading.centerY.equalToSuperview()
        }
    }
    
    func configureCreateCollection() {
        setSeparator(false)
        collectionLabel.text = R.string.localizable.createCollection()
        countLabel.text = ""
        iconImageView.image = R.image.recipePlus()
        selectView.isHidden = true
    }
    
    func configure(title: String?, count: Int?) {
        collectionLabel.text = title
        countLabel.text = "\(count ?? 0)"
        setSeparator(true)
    }
    
    func configure(isSelect: Bool) {
        iconImageView.image = isSelect ? R.image.menuFolder() : R.image.collection()
        selectView.isHidden = !isSelect
    }
    
    func updateConstraintsForEditState() {
        iconImageView.snp.updateConstraints { $0.leading.equalToSuperview().offset(68) }
        countLabel.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-68) }
        minusButton.isHidden = false
        minusButton.snp.makeConstraints {
            $0.height.width.equalTo(40)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
    }

    private func setup() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        trashButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        
        makeConstraints()
    }
    
    private func setSeparator(_ isVisible: Bool) {
        separatorView.isHidden = !isVisible
    }
    
    @objc
    private func minusButtonTapped() {
        isShowTrashButton.toggle()
        guard isShowTrashButton else {
            hideTrash()
            return
        }
        showTrash()
    }
    
    @objc
    private func trashButtonTapped() {
        isShowTrashButton = false
        hideTrash { self.deleteTapped?() }
    }
    
    private func showTrash() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.trashButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.bgView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(65)
            }
            self.layoutIfNeeded()
        }
    }
    
    private func hideTrash(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.trashButton.transform = CGAffineTransform(scaleX: 0, y: 1)
            self.bgView.snp.updateConstraints {
                $0.leading.trailing.equalToSuperview().offset(0)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([separatorView, trashButton, bgView])
        bgView.addSubviews([selectView, iconImageView, collectionLabel, countLabel,
                            minusButton])
        
        bgView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().offset(0)
            $0.top.equalToSuperview()
            $0.height.equalTo(66)
        }
        
        trashButton.snp.makeConstraints {
            $0.height.equalTo(bgView)
            $0.leading.equalToSuperview().offset(-1)
            $0.width.equalTo(72)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        selectView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(2)
        }
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(separatorView.snp.bottom).offset(12)
            $0.height.width.equalTo(40)
        }
        
        collectionLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(17)
            $0.centerY.equalTo(iconImageView)
            $0.height.equalTo(24)
        }
        
        countLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-31)
            $0.centerY.equalTo(iconImageView)
        }
    }

}
