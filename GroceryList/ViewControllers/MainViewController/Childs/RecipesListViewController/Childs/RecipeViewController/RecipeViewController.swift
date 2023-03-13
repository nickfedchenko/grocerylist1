//
//  RecipeViewController.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 11.12.2022.
//

import UIKit

final class RecipeViewController: UIViewController {
    let viewModel: RecipeScreenViewModelProtocol
    var backButtonTitle: String
    private var isFavorite: Bool {
        UserDefaultsManager.favoritesRecipeIds.contains(viewModel.recipe.id)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    private lazy var header: RecipeScreenHeader = {
       let header = RecipeScreenHeader()
        header.setTitle(title: viewModel.getRecipeTitle())
        header.setBackButtonTitle(title: backButtonTitle)
        header.setCollectionButton(!viewModel.haveCollections())
        header.delegate = self
        return header
    }()
    
    let containerView = UIView()
    
    lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset.top = 136
        scrollView.contentInset.bottom = view.safeAreaInsets.bottom
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private lazy var mainImageView: RecipeMainImageView = {
        let view = RecipeMainImageView()
        view.delegate = self
        return view
    }()
    
    private let ingredientsLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedBold(size: 18)
        label.textColor = UIColor(hex: "0C695E")
        label.text = R.string.localizable.ingredients()
        return label
    }()
    
    private lazy var servingSelector: RecipeServingSelector = {
       let selector = RecipeServingSelector()
        selector.delegate = self
        return selector
    }()
    
    private let addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.addToCartFilled(), for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = UIColor(hex: "1A645A")
        return button
    }()
    
    private let vectorArrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.vectorArrow()
        return imageView
    }()
    
    lazy var ingredientViews: [IngredientView] = {
        var views: [IngredientView] = []
        for ingredient in viewModel.recipe.ingredients {
            let title = ingredient.product.title.firstCharacterUpperCase()
            var quantity = ingredient.quantity
            var unitTitle = ingredient.unit?.shortTitle ?? ""
            if let unit = viewModel.unit(unitID: ingredient.unit?.id) {
                quantity *= viewModel.convertValue()
                unitTitle = unit.rawValue.localized
            }
            let unitCount = quantity
            let unitName = unitTitle
            let view = IngredientView()
            view.setTitle(title: title)
            if unitCount == 0 {
                view.setServing(serving: R.string.localizable.byTaste())
                views.append(view)
                continue
            }
            view.setServing(serving: String(format: "%.\(unitCount.truncatingRemainder(dividingBy: 1) > 0 ? 1 : 0)f", unitCount) + " " + unitName)
            views.append(view)
        }
        return views
    }()
    
    let ingredientsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        stackView.axis = .vertical
        return stackView
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedBold(size: 18)
        label.textColor = UIColor(hex: "0C695E")
        label.text = R.string.localizable.instructions()
        return label
    }()
    
    private lazy var instructionsViews: [InstructionView] = {
        var views: [InstructionView] = []
        guard let instructions = viewModel.recipe.instructions else {
            print("failed to get instructions")
            return []
            
        }
        
        for (index, instruction) in instructions.enumerated() {
            let view = InstructionView()
            view.setStepNumber(num: index + 1)
            view.setInstruction(instruction: instruction)
            views.append(view)
        }
        return views
    }()
    
    let instructionsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var promptingView = UIView()
    private lazy var headerOverlayView = UIView()
    private lazy var overlayView = UIView()
    
    init(with viewModel: RecipeScreenViewModelProtocol, backButtonTitle: String) {
        self.viewModel = viewModel
        self.backButtonTitle = backButtonTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        print("Inset top is \(view.safeAreaInsets.top)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupSubviews()
        configureContent()
        setupActions()
        setupPromptingView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentScrollView.contentInset.top = header.bounds.height
        contentScrollView.contentInset.bottom = view.safeAreaInsets.bottom
        contentScrollView.setContentOffset(CGPoint(x: 0, y: -contentScrollView.contentInset.top), animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        header.releaseBlurAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func addToCartTapped() {
        let recipeTitle = viewModel.recipe.title
        let products: [Product] = viewModel.recipe.ingredients.enumerated().map { index, ingredient in
            let netProduct = ingredient.product
//            let step = ingredient.product.marketUnit?.step?.defaultQuantityStep ?? 1
//            let description = String(format: "%.0f", ingredient.product.marketUnit?.step?.defaultQuantityStep ?? 1) + " " + String(ingredient.product.marketUnit?.shortTitle ?? "г")
            let description = ingredientViews[safe: index]?.servingText ?? ""
            let product = Product(
                name: netProduct.title,
                isPurchased: false,
                dateOfCreation: Date(),
                category: netProduct.marketCategory?.title ?? "",
                isFavorite: false,
                description: description,
                fromRecipeTitle: recipeTitle
            )
            return product
        }
        
        let addProductsVC = AddProductsSelectionListController(with:products)
        addProductsVC.contentViewHeigh = 500
        addProductsVC.modalPresentationStyle = .overCurrentContext
        let dataSource = SelectListDataManager()
        let viewModel = SelectListViewModel(dataSource: dataSource)
        addProductsVC.viewModel = viewModel
        present(addProductsVC, animated: false)
    }
    
    private func setupAppearance() {
        view.backgroundColor = UIColor(hex: "E5F5F3")
        mainImageView.setIsFavorite(shouldSetFavorite: isFavorite)
    }
    
    private func setupActions() {
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
    }
    
    private func configureContent() {
        mainImageView.setupFor(recipe: viewModel.recipe)
        servingSelector.setCountInitially(to: viewModel.recipe.totalServings)
    }
    
    private func setupPromptingView() {
        promptingView.isHidden = true
        if !UserDefaultsManager.isShowRecipePrompting {
            overlayView.backgroundColor = .black.withAlphaComponent(0.2)
            let tapOnView = UITapGestureRecognizer(target: self, action: #selector(promptingTapped))
            promptingView.addGestureRecognizer(tapOnView)
            
            headerOverlayView.backgroundColor = .black.withAlphaComponent(0.2)
            header.addSubview(headerOverlayView)
            headerOverlayView.snp.makeConstraints { $0.edges.equalToSuperview() }
            
            mainImageView.showPromptingView()
            showPromptingView()
        }
    }
    
    private func showPromptingView() {
        let servingLabel = UILabel()
        let servingImage = UIImageView(image: R.image.promptingServings())
        servingLabel.textColor = UIColor(hex: "#2E2E2E")
        servingLabel.font = UIFont.SFPro.semibold(size: 16).font
        servingLabel.numberOfLines = 2
        servingLabel.adjustsFontSizeToFitWidth = true
        servingLabel.minimumScaleFactor = 0.5
        servingLabel.text = R.string.localizable.adjustNumberOfServings()

        promptingView.isHidden = false
        promptingView.addSubview(servingImage)
        servingImage.addSubview(servingLabel)
        
        servingImage.snp.makeConstraints {
            $0.top.equalTo(servingSelector.snp.bottom).offset(4)
            $0.leading.equalTo(servingSelector).offset(-3)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(90)
        }
        
        servingLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.bottom.equalToSuperview().offset(-12)
            $0.height.equalTo(44)
        }
    }
    
    @objc
    private func promptingTapped() {
        headerOverlayView.fadeOut()
        overlayView.fadeOut()
        mainImageView.promptingView.fadeOut()
        promptingView.fadeOut()
        UserDefaultsManager.isShowRecipePrompting = true
    }
    
    // swiftlint:disable:next function_body_length
    private func setupSubviews() {
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(containerView)
        containerView.addSubview(ingredientsLabel)
        containerView.addSubview(vectorArrowImage)
        containerView.addSubview(ingredientsStack)
        containerView.addSubview(instructionsLabel)
        containerView.addSubview(instructionsStack)
        containerView.addSubview(overlayView)
        containerView.addSubview(mainImageView)
        containerView.addSubview(servingSelector)
        containerView.addSubview(addToCartButton)
        
        view.addSubview(header)
        view.addSubview(promptingView)
        
        header.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        
        contentScrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            make.bottom.equalToSuperview()
        }
        
        mainImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(244)
        }
        
        ingredientsLabel.snp.makeConstraints { make in
            make.leading.equalTo(mainImageView)
            make.top.equalTo(mainImageView.snp.bottom).offset(24)
        }
        
        servingSelector.snp.makeConstraints { make in
            make.leading.equalTo(ingredientsLabel)
            make.top.equalTo(ingredientsLabel.snp.bottom).offset(8)
            make.height.equalTo(40)
            make.width.equalTo(200)
        }
        
        addToCartButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.trailing.equalTo(mainImageView)
            make.centerY.equalTo(servingSelector)
        }
        
        vectorArrowImage.snp.makeConstraints { make in
            make.centerY.equalTo(servingSelector)
            make.leading.equalTo(servingSelector.snp.trailing).offset(9)
            make.trailing.equalTo(addToCartButton.snp.leading).offset(-9)
        }
        
        ingredientsStack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(mainImageView)
            make.top.equalTo(servingSelector.snp.bottom).offset(16)
//            make.height.equalTo((ingredientViews.count * 48) + (8 * (ingredientViews.count - 1)))
//            make.bottom.equalToSuperview().inset(40)
        }
        
        instructionsLabel.snp.makeConstraints { make in
            make.leading.equalTo(ingredientsStack)
            make.top.equalTo(ingredientsStack.snp.bottom).offset(24)
        }
        
        instructionsStack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(mainImageView)
            make.top.equalTo(instructionsLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
        
        ingredientViews.forEach {
            ingredientsStack.addArrangedSubview($0)
            $0.layoutIfNeeded()
        }
        
        instructionsViews.forEach {
            instructionsStack.addArrangedSubview($0)
        }
        
        overlayView.snp.makeConstraints { $0.edges.equalTo(self.view) }
        promptingView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

extension RecipeViewController: RecipeServingSelectorDelegate {
    func servingChangedTo(count: Double) {
        let servings = viewModel.getIngredientsSizeAccordingToServings(servings: count)
        updateIngredientsCount(by: servings)
    }
    
    func updateIngredientsCount(by servings: [String]) {
        for (index, title) in servings.enumerated() {
            ingredientViews[index].setServing(serving: title)
        }
    }
    
}

extension RecipeViewController: RecipeScreenHeaderDelegate {
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func collectionButtonTapped() {
        viewModel.showCollection()
    }
}

extension RecipeViewController: RecipeMainImageViewDelegate {
    func shareButtonTapped() {
        
        let screenshot = containerView.snapshotNewView(with: view.backgroundColor)
        DispatchQueue.main.async {
            let activityVC = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
            self.present(activityVC, animated: true)
        }
    }
    
    func addToFavoritesTapped() {
        if isFavorite {
            UserDefaultsManager.favoritesRecipeIds.removeAll(where: { $0 == viewModel.recipe.id })
        } else {
            UserDefaultsManager.favoritesRecipeIds.append(viewModel.recipe.id)
        }
    }
}
