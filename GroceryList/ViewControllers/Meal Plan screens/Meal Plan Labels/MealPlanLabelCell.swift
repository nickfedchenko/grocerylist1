//
//  MealPlanLabelCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 20.09.2023.
//

import UIKit

final class MealPlanLabelCell: UITableViewCell {
    
    enum CellState {
        case normal
        case showTrash
    }
    
    var tapOnTitle: (() -> Void)?
    var tapDelete: (() -> Void)?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.lightGray()
        view.setCornerRadius(1)
        return view
    }()
    
    private lazy var bottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.lightGray()
        view.setCornerRadius(1)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = R.color.primaryDark()
        label.numberOfLines = 3
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var plusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.image = R.image.recipePlus()
        return imageView
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.image = R.image.autorepeat_checkmark()?.withTintColor(R.color.primaryDark() ?? .black)
        return imageView
    }()
    
    private lazy var trashButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.swipeToDelete(), for: .normal)
        button.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rearrangeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.rearrange()?.withTintColor(R.color.lightGray() ?? .lightGray)
        return imageView
    }()
    
    private var state: CellState = .normal
    
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
        plusImageView.isHidden = false
        checkmarkImageView.isHidden = false
        titleLabel.textColor = R.color.primaryDark()
        trashButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        containerView.snp.updateConstraints { $0.leading.equalToSuperview().offset(0) }
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if !subview.description.contains("Reorder") {
            return
        }
        (subview.subviews.first as? UIImageView)?.removeFromSuperview()
        subview.addSubview(rearrangeImageView)

        rearrangeImageView.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(12)
            $0.left.equalTo(containerView).offset(20)
            $0.height.width.equalTo(40)
        }
    }
    
    func configureCreateCollection() {
        titleLabel.text = R.string.localizable.createCollection()
        checkmarkImageView.isHidden = true
    }
    
    func configure(title: String?, color: UIColor) {
        titleLabel.text = title
        titleLabel.textColor = color
        plusImageView.isHidden = true
        
        let tapOnLabel = UITapGestureRecognizer(target: self, action: #selector(tappedOnTitleLabel))
        titleLabel.addGestureRecognizer(tapOnLabel)
    }
    
    func configure(isSelect: Bool) {
        checkmarkImageView.isHidden = !isSelect
    }
    
    func canDeleteCell(_ canDelete: Bool) {
        guard canDelete else {
            return
        }
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRightRecognizer.direction = .right
        containerView.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeLeftRecognizer.direction = .left
        containerView.addGestureRecognizer(swipeLeftRecognizer)
    }

    private func setup() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        trashButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        
        makeConstraints()
    }
    
    @objc
    private func tappedOnTitleLabel() {
        tapOnTitle?()
    }
    
    @objc
    private func trashButtonTapped() {
        hideTrash { [weak self] in
            self?.tapDelete?()
        }
    }
    
    @objc
    private func swipeAction(_ recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .right:
            if state == .showTrash {
                hideTrash()
            }
        case .left:
            if state == .normal {
                showTrash()
            }
        default: break
        }
    }
    
    private func showTrash() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.trashButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.containerView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(64)
            }
            self.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.state = .showTrash
        }
    }
    
    private func hideTrash(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.trashButton.transform = CGAffineTransform(scaleX: 0, y: 1)
            self.containerView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(0)
            }
            self.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.state = .normal
            completion?()
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([containerView, trashButton])
        containerView.addSubviews([topSeparatorView, bottomSeparatorView,
                                   plusImageView, titleLabel, checkmarkImageView])
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(0)
            $0.top.bottom.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(66)
        }
        
        makeConstraintsSeparatorView()
        
        trashButton.snp.makeConstraints {
            $0.height.equalTo(containerView)
            $0.leading.equalToSuperview().offset(-1)
            $0.width.equalTo(64)
        }
        
        plusImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(topSeparatorView.snp.bottom).offset(12)
            $0.height.width.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(68)
            $0.top.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.greaterThanOrEqualTo(24)
            $0.trailing.lessThanOrEqualTo(checkmarkImageView.snp.leading).offset(-8)
        }
        
        checkmarkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(topSeparatorView.snp.bottom).offset(12)
            $0.height.width.equalTo(40)
        }
    }
    
    private func makeConstraintsSeparatorView() {
        topSeparatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        bottomSeparatorView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(2)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(2)
        }
    }
}
