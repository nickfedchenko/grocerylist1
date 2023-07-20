//
//  RecipeViewController.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 11.12.2022.
//

import UIKit

final class RecipeViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    var viewModel: RecipeScreenViewModelProtocol
    var backButtonTitle: String
    
    private var isFavorite: Bool {
        UserDefaultsManager.favoritesRecipeIds.contains(viewModel.recipe.id)
    }

    private lazy var header: RecipeScreenHeader = {
        let header = RecipeScreenHeader(theme: viewModel.theme)
        header.setTitle(title: viewModel.getRecipeTitle())
        header.setBackButtonTitle(title: backButtonTitle)
        header.delegate = self
        return header
    }()
    
    let containerView = UIView()
    
    lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset.top = 136
        scrollView.contentInset.bottom = 120
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
    
    private lazy var ingredientsLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedBold(size: 18)
        label.textColor = viewModel.theme.dark
        label.text = R.string.localizable.ingredients()
        return label
    }()
    
    private lazy var servingSelector: RecipeServingSelector = {
       let selector = RecipeServingSelector()
        selector.setupColor(color: viewModel.theme)
        selector.delegate = self
        return selector
    }()
    
    private lazy var addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.addToCartFilled(), for: .normal)
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.clipsToBounds = true
        button.backgroundColor = viewModel.theme.dark
        return button
    }()
    
    private lazy var vectorArrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.vectorArrow()?.withTintColor(viewModel.theme.dark)
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
                unitTitle = unit.title
            }
            let unitCount = quantity
            let unitName = unitTitle
            let view = IngredientView()
            view.setTitle(title: title)
            view.setServing(serving: unitCount == 0 ? R.string.localizable.byTaste()
                                                    : unitCount.asString + " " + unitName)
            view.setDescription(ingredient.description)
            view.setImage(imageURL: ingredient.product.photo, imageData: ingredient.product.localImage)
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
    
    private lazy var descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedBold(size: 18)
        label.textColor = viewModel.theme.dark
        label.text = R.string.localizable.description()
        return label
    }()
    
    private lazy var descriptionRecipeLabel: UILabel = {
        let label = PaddingLabel(withInsets: 8, 8, 8, 8)
        label.font = UIFont.SFPro.medium(size: 15).font
        label.textColor = .black
        label.backgroundColor = .white
        label.layer.cornerRadius = 8
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var instructionsLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedBold(size: 18)
        label.textColor = viewModel.theme.dark
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
    
    private let showCostView = CreateNewRecipeShowCostView()
    
    private lazy var promptingView = UIView()
    private lazy var headerOverlayView = UIView()
    private lazy var overlayView = UIView()
    private let contextMenuBackgroundView = UIView()
    private let contextMenuView = RecipeListContextMenuView()
    
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
        setupContextMenu()
        setupSubviews()
        configureContent()
        setupActions()
        setupPromptingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as? MainTabBarController)?.isHideNavView(isHide: true)
        (self.tabBarController as? MainTabBarController)?.setTextTabBar(
            text: R.string.localizable.create().uppercased(),
            color: viewModel.theme.medium
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentScrollView.contentInset.top = header.bounds.height
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
        addProductsVC.delegate = self
        present(addProductsVC, animated: false)
    }
    
    private func setupAppearance() {
        let theme = viewModel.theme
        view.backgroundColor = theme.light
        
        mainImageView.setIsFavorite(shouldSetFavorite: isFavorite)
    }
    
    private func setupActions() {
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
    }
    
    private func configureContent() {
        mainImageView.setupFor(recipe: viewModel.recipe)
        mainImageView.setupKcal(value: viewModel.recipe.values?.serving ?? viewModel.recipe.values?.dish)
        servingSelector.setCountInitially(to: viewModel.recipe.totalServings)
        
        if viewModel.recipe.description.isEmpty {
            descriptionTitleLabel.isHidden = true
            descriptionRecipeLabel.isHidden = true
            descriptionTitleLabel.snp.updateConstraints { $0.top.equalTo(showCostView.snp.bottom).offset(0) }
            descriptionRecipeLabel.snp.updateConstraints { $0.top.equalTo(descriptionTitleLabel.snp.bottom).offset(0) }
            instructionsLabel.snp.updateConstraints { $0.top.equalTo(descriptionRecipeLabel.snp.bottom).offset(0) }
        } else {
            descriptionRecipeLabel.text = viewModel.recipe.description
        }

        showCostView.changedSwitchValue = { [weak self] isShowCost in
            guard let self else {
                return
            }
            self.ingredientViews.enumerated().forEach({ index, view in
                if isShowCost {
                    AmplitudeManager.shared.logEvent(.recipeShowPriceStores)
                    let store = self.viewModel.getStoreAndCost(by: index)
                    view.setupCost(isVisible: isShowCost,
                                              storeTitle: store.store, costValue: store.cost)
                } else {
                    view.setupCost(isVisible: isShowCost,
                                              storeTitle: nil, costValue: nil)
                }
            })
        }
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
    
    private func setupContextMenu() {
        let menuTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(menuTapAction))
        contextMenuBackgroundView.addGestureRecognizer(menuTapRecognizer)
        contextMenuBackgroundView.backgroundColor = .black.withAlphaComponent(0.2)
        
        contextMenuView.delegate = self
        contextMenuView.configure(color: viewModel.theme)
        contextMenuView.setupMenuFunctions(isDefaultRecipe: viewModel.recipe.isDefaultRecipe,
                                           isFavorite: isFavorite)
        
        contextMenuView.isHidden = true
        contextMenuBackgroundView.isHidden = true
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
    
    @objc
    private func menuTapAction() {
        contextMenuView.fadeOut()
        contextMenuBackgroundView.isHidden = true
    }
    
    // swiftlint:disable:next function_body_length
    private func setupSubviews() {
        view.addSubviews([contentScrollView, header, promptingView, contextMenuBackgroundView])
        contentScrollView.addSubview(containerView)
        containerView.addSubviews([ingredientsLabel, vectorArrowImage, ingredientsStack,
                                   descriptionTitleLabel, descriptionRecipeLabel,
                                   instructionsLabel, instructionsStack,
                                   overlayView, mainImageView, servingSelector, addToCartButton, showCostView])
        contextMenuBackgroundView.addSubviews([contextMenuView])
        
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
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        ingredientsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
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
        
        showCostView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-4)
            make.trailing.equalToSuperview()
            make.top.equalTo(ingredientsStack.snp.bottom).offset(-12)
            make.height.equalTo(showCostView.requiredHeight)
        }
        
        descriptionTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(ingredientsLabel)
            make.top.equalTo(showCostView.snp.bottom).offset(16)
        }
        
        descriptionRecipeLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(ingredientsStack)
        }
        
        instructionsLabel.snp.makeConstraints { make in
            make.leading.equalTo(descriptionTitleLabel)
            make.top.equalTo(descriptionRecipeLabel.snp.bottom).offset(24)
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
        
        makeContextMenuViewConstraints()
    }
    
    private func makeContextMenuViewConstraints() {
        contextMenuBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contextMenuView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(contextMenuView.requiredHeight)
            $0.width.equalTo(250)
        }
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
    
    func contextMenuButtonTapped() {
        if viewModel.fromSearch {
            AmplitudeManager.shared.logEvent(.recipeContextFromSearch)
        }
        if viewModel.recipe.isDefaultRecipe || backButtonTitle != R.string.localizable.search() {
            contextMenuView.removeDeleteButton()
        }
        contextMenuView.setupMenuFunctions(isDefaultRecipe: viewModel.recipe.isDefaultRecipe,
                                           isFavorite: isFavorite)
        contextMenuView.snp.updateConstraints {
            $0.height.equalTo(contextMenuView.requiredHeight)
        }
        
        contextMenuView.fadeIn()
        contextMenuBackgroundView.isHidden = false
    }
}

extension RecipeViewController: RecipeMainImageViewDelegate {
    func shareButtonTapped() {
        AmplitudeManager.shared.logEvent(.recipeSendOnPhoto)
        let screenshot = containerView.snapshotNewView(with: view.backgroundColor)
        DispatchQueue.main.async {
            let activityVC = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
            self.present(activityVC, animated: true)
        }
    }
    
    func addToFavoritesTapped() {
        viewModel.updateFavoriteState(isSelected: !isFavorite)
    }
}

extension RecipeViewController: AddProductsSelectionListDelegate {
    func ingredientsSuccessfullyAdded() {
        AmplitudeManager.shared.logEvent(.recipeAddToList)
    }
}

extension RecipeViewController: RecipeListContextMenuViewDelegate {
    func selectedState(state: RecipeListContextMenuView.MainMenuState) {
        UIView.animate(withDuration: 0.4) {
            self.contextMenuView.alpha = 0.0
            self.contextMenuBackgroundView.alpha = 0.0
        } completion: { _ in
            self.contextMenuView.isHidden = true
            self.contextMenuBackgroundView.isHidden = true
            self.contextMenuView.alpha = 1.0
            self.contextMenuBackgroundView.alpha = 1.0

            switch state {
            case .addToShoppingList:
                self.viewModel.addToShoppingList(contentViewHeigh: self.view.frame.height, delegate: self)
            case .addToFavorites:
                self.viewModel.updateFavoriteState(isSelected: !self.isFavorite)
                self.mainImageView.setIsFavorite(shouldSetFavorite: self.isFavorite)
            case .addToCollection:
                self.viewModel.addToCollection()
            case .edit:
                self.viewModel.edit()
            case .delete:
                self.viewModel.removeRecipe()
                self.backButtonTapped()
            }
            
            self.contextMenuView.removeSelected()
        }
    }
}
