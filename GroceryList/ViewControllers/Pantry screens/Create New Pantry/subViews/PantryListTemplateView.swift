//
//  PantryListTemplateView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 25.05.2023.
//

import UIKit

protocol PantryListTemplateViewDelegate: AnyObject {
    func selectTemplate(_ index: Int)
}

struct PantryListTemplate {
    let icon: UIImage?
    let title: String
}

final class PantryListTemplateView: UIView {

    weak var delegate: PantryListTemplateViewDelegate?
    
    private lazy var collectionView: UICollectionView = {
        layout.configuration.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(classCell: PantryListTemplateCell.self)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset.bottom = 300
        collectionView.contentInset.top = 12
        return collectionView
    }()
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
        let estimatedWeight: CGFloat = 12
        let height: CGFloat = 48
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(estimatedWeight),
                                              heightDimension: .absolute(height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0),
                                                         top: .fixed(8),
                                                         trailing: .fixed(8),
                                                         bottom: .fixed(0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95),
                                               heightDimension: .estimated(height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(16),
                                                          top: .fixed(0),
                                                          trailing: .fixed(16),
                                                          bottom: .fixed(0))
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    private var templates: [PantryListTemplate] = [] {
        didSet {
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(templates: [PantryListTemplate]) {
        self.templates = templates
    }
    
    func configure(backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
    }
    
    private func setup() {
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension PantryListTemplateView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        templates.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: PantryListTemplateCell.self, indexPath: indexPath)
        cell.configure(template: templates[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        delegate?.selectTemplate(indexPath.row)
    }
}

final private class PantryListTemplateCell: UICollectionViewCell {
    
    private let iconImageView = UIImageView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 20).font
        label.textColor = .white.withAlphaComponent(0.6)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(template: PantryListTemplate) {
        titleLabel.text = template.title
        iconImageView.image = template.icon
    }
    
    private func setup() {
        contentView.backgroundColor = .clear
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = 8
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        contentView.layer.borderWidth = 1
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        contentView.addSubviews([titleLabel, iconImageView])
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
            $0.centerY.equalTo(iconImageView)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}
