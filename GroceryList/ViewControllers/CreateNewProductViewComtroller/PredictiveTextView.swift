//
//  PredictiveTextView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.03.2023.
//

import UIKit

protocol PredictiveTextViewDelegate: AnyObject {
    func selectTitle(_ title: String)
}

final class PredictiveTextView: UIView {
    
    weak var delegate: PredictiveTextViewDelegate?
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(classCell: PredictiveTextCell.self)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
        let estimatedHeight: CGFloat = 29
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(1),
                                              heightDimension: .absolute(estimatedHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0),
                                                         top: .fixed(12),
                                                         trailing: .fixed(8),
                                                         bottom: .fixed(0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(estimatedHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 8,
                                                      leading: 20,
                                                      bottom: 0,
                                                      trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    private var texts: [String] = [] {
        didSet { collectionView.reloadData() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(texts: [String]) {
        self.texts = texts
    }
    
    private func setup() {
        self.backgroundColor = UIColor(hex: "#D1D5DB")
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension PredictiveTextView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        texts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: PredictiveTextCell.self, indexPath: indexPath)
        cell.configure(title: texts[indexPath.row])
        cell.selectTitle = { [weak self] title in
            self?.delegate?.selectTitle(title)
        }
        return cell
    }
}

final private class PredictiveTextCell: UICollectionViewCell {
    
    var selectTitle: ((String) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 17).font
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private(set) var sectionIndex: Int = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    private func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        self.addGestureRecognizer(tap)
        
        contentView.backgroundColor = UIColor(hex: "#F1F1F1")
        layer.cornerRadius = 4
        layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = 4
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
        
        makeConstraints()
    }
    
    @objc
    private func tappedOnView() {
        selectTitle?(titleLabel.text ?? "")
    }
    
    private func makeConstraints() {
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(6)
            $0.height.equalTo(17)
            $0.center.equalToSuperview()
        }
    }
}
