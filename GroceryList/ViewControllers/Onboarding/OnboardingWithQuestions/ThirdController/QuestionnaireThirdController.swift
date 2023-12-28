//
//  QuestionnaireThirdController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.12.2023.
//

import UIKit
class QuestionnaireThirdController: UIViewController {
    var viewModel: QuestionnaireThirdViewModel?
    
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<QuestionnaireThirdControllerSections, QuestionnaireThirdControllerCellModel>?
    private let collectionViewLayoutManager = QuestionnaireThirdControllerLayoutManager()
    
    private let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.questionnaireThirdBackgroundImage()
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = collectionViewLayoutManager.makeCollectionLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.isScrollEnabled = false
        collectionView.register(classCell: QuestionnaireCell.self)
        collectionView.register(classCell: QuestionnaireHeaderCell.self)
        return collectionView
    }()
    
    private lazy var viewWithNextButtonAndPageControl: BottomViewWithNextButton = {
        let view = BottomViewWithNextButton()
        view.nextButtonPressedCallback = { [weak self] in
            self?.viewModel?.nextButtonTapped()
        }
        return view
    }()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraints()
        applyCallbacks() 
        configureCollectionViewDataSource()
        viewModel?.viewDidLoad()
    }
    
    private func applyCallbacks() {
        viewModel?.applyShapshot = { [weak self] snapshot in
            self?.collectionViewDataSource?.apply(snapshot, animatingDifferences: true)
            self?.viewWithNextButtonAndPageControl.configure(numberOfPages: snapshot.numberOfSections)
        }
        
        viewModel?.scrollToPage = { [weak self] page in
            guard let self = self else { return }
            let offset = CGPoint(
                x: collectionView.frame.size.width * CGFloat(page),
                y: .zero
            )
            self.collectionView.setContentOffset(offset, animated: true)
        }
        
        viewModel?.isMultiselectionEnabled = { [weak self] isEnabled in
            self?.collectionView.allowsMultipleSelection = isEnabled
        }
        
        viewModel?.isNextButtonEnabled = { [weak self] isEnabled in
            self?.viewWithNextButtonAndPageControl.activateButton(isActive: isEnabled)
        }
    }
}

extension QuestionnaireThirdController {
    private func makeConstraints() {
        view.addSubviews([backgroundImageView, collectionView, viewWithNextButtonAndPageControl])
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.bottom.equalTo(viewWithNextButtonAndPageControl.snp.top)
        }
        
        viewWithNextButtonAndPageControl.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
        }
    
    }
}

extension QuestionnaireThirdController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - CollectionView Data Source
    private func configureCollectionViewDataSource() {
        collectionViewDataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] _, indexPath, model in
                switch model {
                case .topHeader(let model):
                    let cell = self?.collectionView.reusableCell(classCell: QuestionnaireHeaderCell.self, indexPath: indexPath)
                    cell?.configure(text: model.text, questionNumber: model.questionNumber, isMultiselected: model.isMultiselected)
                    return cell
                case .cell(let model):
                    let cell = self?.collectionView.reusableCell(classCell: QuestionnaireCell.self, indexPath: indexPath)
                    cell?.configure(text: model.text)
                    return cell
                }
            }
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        viewWithNextButtonAndPageControl.selectPage(pageIndex: page)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) is QuestionnaireCell else {
            return
        }
        viewModel?.cellSelected(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) is QuestionnaireCell else {
            return
        }
        viewModel?.cellDeselected(at: indexPath)
    }
    
}
