//
//  NewPaywallCarouselView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.07.2023.
//

import UIKit

class NewPaywallCarouselView: UIView {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.register(classCell: PaywallCarouselCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var images: [UIImage?] = []
    private var index = 0
    private var timer: Timer?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupImage()
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startCarousel() {
        guard timer == nil else {
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: 2.0,
                             target: self,
                             selector: #selector(pageSetup),
                             userInfo: nil, repeats: true)
    }
    
    func stopCarousel() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupImage() {
        var index = 0
        while index >= 0 {
            if let image = UIImage(named: "feature_newPaywall_image-\(index)") {
                images.append(image)
                index += 1
            } else {
                index = -1
            }
        }
    }
    
    @objc
    private func pageSetup(){
        if index < images.count - 1 {
            index += 1
        } else {
            index = 0
        }
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .right, animated: true)
        
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
        return CGSize(width: self.frame.width, height: self.frame.height)
    }
}

final private class PaywallCarouselCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        
        self.contentView.addSubviews([imageView])
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

