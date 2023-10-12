//
//  SelectIconView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 29.05.2023.
//

import SFSafeSymbols
import UIKit

protocol SelectIconViewDelegate: AnyObject {
    func selectIcon(_ icon: UIImage?)
    func tappedCross()
}

final class SelectIconView: UIView {
    
    weak var delegate: SelectIconViewDelegate?
    var selectedIcon: UIImage?
    
    private lazy var crossButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.whiteCross(), for: .normal)
        button.addTarget(self, action: #selector(tappedCrossButton), for: .touchUpInside)
        return button
    }()

    private lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.chevronRight()?.withTintColor(.white), for: .normal)
        button.setTitle(R.string.localizable.more(), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.addTarget(self, action: #selector(tappedMoreButton), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.SFPro.bold(size: 18).font
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.text = R.string.localizable.selectIcon()
        return label
    }()
    
    private lazy var defaultCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(classCell: IconCollectionViewCell.self)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var moreCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alpha = 0
        collectionView.register(classCell: IconCollectionViewCell.self)
        return collectionView
    }()
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(32),
            heightDimension: .absolute(32))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(32))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)
        group.interItemSpacing = .fixed(19)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 10, trailing: 0)
        section.interGroupSpacing = 10

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    private var allSymbols: [UIImage?] = []
    private var defaultSymbols: [UIImage?] = []
    private var theme: Theme?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(theme: Theme) {
        self.theme = theme
        self.backgroundColor = theme.medium
    }
    
    private func setup() {
        setupSFSymbols()
        
        self.layer.cornerRadius = 24
        self.layer.cornerCurve = .continuous
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.addShadow(radius: 11, offset: CGSize(width: 0, height: -12))
        
        makeConstraints()
    }
    
    private func setupSFSymbols() {
        let allSFSymbols = Array(SFSymbol.allSymbols).sorted { $0.rawValue < $1.rawValue }
        allSFSymbols.forEach {
            allSymbols.append(UIImage(systemSymbol: $0))
        }
        
        let fileManager = FileManager.default
        let bundle = "defaults_icon.bundle"
        let listImageNames = fileManager.getListFileNameInBundle(bundlePath: bundle).sorted()
        for imageName in listImageNames {
            let image = fileManager.getImageInBundle(bundlePath: "\(bundle)/\(imageName)")
            defaultSymbols.append(image?.withTintColor(.white))
        }
    }
    
    @objc
    private func tappedCrossButton() {
        delegate?.tappedCross()
    }
    
    @objc
    private func tappedMoreButton() {
        defaultCollectionView.snp.updateConstraints {
            $0.leading.equalToSuperview().offset(-self.bounds.width)
        }
        
        UIView.animate(withDuration: 0.6, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.6, options: [.curveEaseInOut]) {
            self.defaultCollectionView.alpha = 0
            self.moreCollectionView.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([crossButton, moreButton, titleLabel, defaultCollectionView, moreCollectionView])

        crossButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(8)
            $0.height.width.equalTo(40)
        }
        
        moreButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-22)
            $0.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
            $0.height.equalTo(40)
        }
        
        defaultCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(43)
            $0.width.equalToSuperview().multipliedBy(0.78)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        moreCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(defaultCollectionView.snp.trailing).offset(129)
            $0.width.equalToSuperview().multipliedBy(0.78)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}

extension SelectIconView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return collectionView == defaultCollectionView ? defaultSymbols.count
                                                       : allSymbols.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: IconCollectionViewCell.self, indexPath: indexPath)
        let icon = collectionView == defaultCollectionView ? defaultSymbols[indexPath.row]
                                                           : allSymbols[indexPath.row]
        cell.configure(icon: icon)
        if icon?.pngData() == selectedIcon?.pngData() {
            cell.selectCell(color: theme?.dark)
        }
        return cell
    }
}

extension SelectIconView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.reloadData()
        let icon = collectionView == defaultCollectionView ? defaultSymbols[indexPath.row]
                                                           : allSymbols[indexPath.row]
        selectedIcon = icon
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.delegate?.selectIcon(icon)
        }
    }
}

extension FileManager {
    func getListFileNameInBundle(bundlePath: String) -> [String] {
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let assetURL = bundleURL.appendingPathComponent(bundlePath)
        do {
            let contents = try fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
            return contents.map { $0.lastPathComponent }
        } catch {
            return []
        }
    }

    func getImageInBundle(bundlePath: String) -> UIImage? {
        let bundleURL = Bundle.main.bundleURL
        let assetURL = bundleURL.appendingPathComponent(bundlePath)
        return UIImage(contentsOfFile: assetURL.relativePath)
    }
}
