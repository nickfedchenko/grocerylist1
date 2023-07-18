//
//  NewPaywallCarouselView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.07.2023.
//

import UIKit

class NewPaywallCarouselView: UIView {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(classCell: PaywallCarouselCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = false
        return collectionView
    }()
    
    private var images: [UIImage?] = []
    private var index = 0
    private var timer: Timer?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupImage()
        
        self.layer.cornerRadius = 24
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = true
        
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startCarousel() {
        guard timer == nil else {
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.9,
                                     target: self,
                                     selector: #selector(pageSetup),
                                     userInfo: nil, repeats: true)
    }
    
    func stopCarousel() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupImage() {
        var index = 1
        while index >= 0 {
            if let image = UIImage(named: "carousel_new_paywall_0\(index)") {
                images.append(image)
                index += 1
            } else {
                index = -1
            }
        }
        collectionView.reloadData()
    }
    
    @objc
    private func pageSetup() {
        if index < images.count - 1 {
            index += 1
        } else {
            index = 0
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.collectionView.scrollToItem(at: IndexPath(item: self.index, section: 0),
                                             at: .right, animated: true)
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([collectionView])

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension NewPaywallCarouselView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: PaywallCarouselCell.self,
                                                          indexPath: indexPath)
        cell.imageView.image = images[indexPath.row]
        return cell
    }
}

extension NewPaywallCarouselView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
