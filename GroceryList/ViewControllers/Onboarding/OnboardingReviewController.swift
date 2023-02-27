//
//  OnboardingReviewController.swift
//  GroceryList
//
//  Created by Admin on 18.01.2023.
//

import StoreKit
import UIKit

final class OnboardingReviewController: UIViewController {
    private var selectedIndex: CGFloat = 0
    private weak var router: RootRouter?
    
    private let mainTitle: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedBold(size: 32)
        label.textColor = UIColor(hex: "0C695E")
        label.textAlignment = .center
        label.text = R.string.localizable.reviewMainTitle()
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitle: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProDisplayBold(size: 17)
        label.textColor = UIColor(hex: "1A645A")
        label.textAlignment = .center
        label.text = R.string.localizable.reviewSubtitle()
        label.numberOfLines = 0
        return label
    }()
    
    private let reviews: [UIImage?] = [
        R.image.review_3(),
        R.image.review_1(),
        R.image.review_2(),
        R.image.review_3(),
        R.image.review_1()
    ]
    private lazy var reviewsCollection: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(ReviewCell.self, forCellWithReuseIdentifier: ReviewCell.identifier)
        collection.dataSource = self
        collection.delegate = self
//        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
//        collection.isUserInteractionEnabled = false
//        collection.contentInset.left = 30
        return collection
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(string: "Next".localized, attributes: [
            .font: UIFont.SFPro.semibold(size: 20).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#FFFFFF")
        ])
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(hex: "#31635A")
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.masksToBounds = true
        button.addShadowForView()
        button.isHidden = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.alpha = 0
        return pageControl
    }()
    
    private let generator = UIImpactFeedbackGenerator(style: .medium)
    
    init(router: RootRouter) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        generator.prepare()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showRequest()
    }
    
    override func viewDidLayoutSubviews() {
        reviewsCollection.setContentOffset(CGPoint(x: view.bounds.width - 120, y: 0), animated: false)
    }
    
    private func showRequest() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
    
    @objc
    private func nextTapped() {
            generator.impactOccurred(intensity: 1)
            router?.popToRootFromOnboarding()
            router?.showPaywallVC()
    }
    
    private func setupSubviews() {
        view.backgroundColor = UIColor(hex: "#E5F5F3")
        view.addSubviews([mainTitle, subtitle])
        view.addSubview(reviewsCollection)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        
        mainTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(122.fitH)
            make.leading.trailing.equalToSuperview().inset(68.fitW)
        }
        
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(mainTitle.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(65)
        }
        
        reviewsCollection.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(subtitle.snp.bottom).offset(UIScreen.main.isSmallSize ? 8 : 54)
            make.height.equalTo(282)
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(reviewsCollection.snp.bottom).offset(UIScreen.main.isSmallSize ? 4 : 24)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(64)
            make.bottom.equalToSuperview().inset(64)
        }
    }
}

extension OnboardingReviewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCell.identifier, for: indexPath) as? ReviewCell else { return UICollectionViewCell() }
        let image = reviews[indexPath.item]
        cell.configure(with: image)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard (1...3).contains(selectedIndex) else { return }
        pageControl.currentPage = Int(selectedIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.bounds.width - 80, height: 282)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}
