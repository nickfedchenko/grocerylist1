//
//  FiltersView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.07.2023.
//

import UIKit

class FiltersView: UIView {

    var removeTag: ((RecipeTag) -> Void)?
    
    private lazy var collectionView: UICollectionView = {
        layout.configuration.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(classCell: FiltersViewCell.self)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
        let estimatedWeight: CGFloat = 72
        let height: CGFloat = 32
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(estimatedWeight),
                                              heightDimension: .estimated(height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0),
                                                         top: .fixed(12),
                                                         trailing: .fixed(8),
                                                         bottom: .fixed(0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(height + 12))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(20),
                                                          top: .fixed(0),
                                                          trailing: .fixed(0),
                                                          bottom: .fixed(0))
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    private var tags: [RecipeTag] = [] {
        didSet {
            updateData()
        }
    }
    
    private var color = R.color.darkGray()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(tags: [RecipeTag], color: UIColor?) {
        self.tags = tags
        self.color = color
    }
    
    private func setup() {
        self.backgroundColor = #colorLiteral(red: 0.805165112, green: 0.8200982809, blue: 0.8198366165, alpha: 1)
        makeConstraints()
    }
    
    private func updateData() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.updateData()
            }
            return
        }
        
        collectionView.snp.updateConstraints { $0.height.equalTo(1000).priority(.high) }
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()

        collectionView.reloadData()
        
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionView.snp.updateConstraints { $0.height.equalTo(height).priority(.high) }
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
    }
    
    private func makeConstraints() {
        self.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(1).priority(.high)
        }
    }
}

extension FiltersView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: FiltersViewCell.self, indexPath: indexPath)
        let isException = (tags[indexPath.row] as? ExceptionFilter) != nil
        cell.configure(isException: isException, title: tags[indexPath.row].title, color: color)
        cell.tagClearTapped = { [weak self] in
            guard let self else {
                return
            }
            self.removeTag?(self.tags[indexPath.row])
        }
        return cell
    }
}

final class FiltersViewCell: UICollectionViewCell {
    
    var tagClearTapped: (() -> Void)?
    
    private let exceptionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.filterException()
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 17).font
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let tagClearImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.filterTagClear()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        exceptionImageView.snp.updateConstraints { $0.width.equalTo(24) }
    }
    
    func configure(isException: Bool, title: String, color: UIColor?) {
        if !isException {
            exceptionImageView.snp.updateConstraints { $0.width.equalTo(0) }
        }
        contentView.backgroundColor = isException ? R.color.attention() : color
        titleLabel.text = title
    }
    
    func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedOnTagClear))
        tagClearImageView.addGestureRecognizer(tap)

        layer.cornerRadius = 4
        layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = 4
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
        
        makeConstraints()
    }
    
    @objc
    func tappedOnTagClear() {
        tagClearTapped?()
    }
    
    private func makeConstraints() {
        contentView.addSubviews([titleLabel, exceptionImageView, tagClearImageView])
        let width = UIScreen.main.bounds.width - 100
        
        exceptionImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(4)
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(exceptionImageView.snp.trailing).offset(4)
            $0.top.equalToSuperview().offset(6)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(tagClearImageView.snp.leading).offset(-8)
        }
        
        tagClearImageView.snp.makeConstraints {
            $0.width.height.equalTo(32)
            $0.top.bottom.trailing.equalToSuperview()
        }
    }

}
