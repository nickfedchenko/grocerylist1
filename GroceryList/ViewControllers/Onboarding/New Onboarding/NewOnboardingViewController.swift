//
//  NewOnboardingViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 08.08.2023.
//

import UIKit

class NewOnboardingViewController: UIViewController {

    weak var router: RootRouter?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(classCell: NewOnboardingCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = R.color.primaryDark()
        pageControl.pageIndicatorTintColor = R.color.action()
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(string: "Next".localized.uppercased(), attributes: [
            .font: UIFont.SFPro.semibold(size: 20).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#FFFFFF")
        ])
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(hex: "#1A645A")
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.addShadowForView()
        button.setImage(UIImage(named: "nextArrow"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = .white
        button.imageEdgeInsets.left = 8
        return button
    }()
    
    private var currentPage = 0 {
        didSet { pageControl.currentPage = currentPage }
    }
    
    private let screenNames = ["IMG for export (PNG or JPEG) 1",
                               "IMG for export (PNG or JPEG) 2",
                               "IMG for export (PNG or JPEG) 3",
                               "IMG for export (PNG or JPEG) 4",
                               "IMG for export (PNG or JPEG) 5",
                               "IMG for export (PNG or JPEG) 6",
                               "IMG for export (PNG or JPEG) 7",
                               "IMG for export (PNG or JPEG) 8",
                               "IMG for export (PNG or JPEG) 9",
                               "IMG for export (PNG or JPEG) 10",
                               "IMG for export (PNG or JPEG) 11"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        currentPage = 0
        pageControl.numberOfPages = screenNames.count

        makeConstraints()
    }

    @objc
    private func nextButtonPressed() {
        if currentPage < screenNames.count - 1 {
            currentPage += 1
            let indexPath = IndexPath.init(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            router?.popToRootFromOnboarding()
            router?.showPaywallVC()
        }
    }
    
    private func makeConstraints() {
        self.view.addSubviews([collectionView, pageControl, nextButton])

        collectionView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalToSuperview().offset(
                UIDevice.screenType == .iPhones678SE2 ? 44 :
                    UIDevice.screenType == .iPhonesXXS11Pro ? 45 :
                    UIDevice.screenType == .iPhones678SE2 ? 61 : 105
            )
            $0.bottom.equalTo(nextButton.snp.top).offset(
                UIDevice.screenType == .iPhones678SE2 ? -32 :
                    UIDevice.screenType == .iPhonesXXS11Pro ? 0 :
                    UIDevice.screenType == .iPhones678SE2 ? -14 : -58
            )
        }
        
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-8)
            $0.height.equalTo(22)
        }
        
        nextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
            $0.width.equalTo(350)
            $0.bottom.equalToSuperview().offset(
                UIDevice.screenType == .iPhones678SE2 ? -16 : -64
            )
        }
    }
}

extension NewOnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        screenNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: NewOnboardingCell.self,
                                                          indexPath: indexPath)
        cell.imageView.image = UIImage(named: screenNames[indexPath.row]) 
        return cell
    }
}

extension NewOnboardingViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        currentPage = page
    }
}
