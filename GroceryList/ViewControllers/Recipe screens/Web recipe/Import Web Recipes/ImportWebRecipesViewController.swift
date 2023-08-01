//
//  ImportWebRecipesViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 31.07.2023.
//

import UIKit

class ImportWebRecipesViewController: UIViewController {
    
    private let viewModel: ImportWebRecipesViewModel
    
    private let navigationView = UIView()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(
            string: R.string.localizable.back(),
            attributes: [
                .font: UIFont.SFProRounded.semibold(size: 17).font ?? .systemFont(ofSize: 17),
                .foregroundColor: R.color.primaryDark() ?? UIColor(hex: "#045C5C")
            ]
        )
        button.setImage(R.image.back_Chevron(), for: .normal)
        button.tintColor = R.color.primaryDark()
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let topInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.background()
        view.addCustomShadow(offset: .init(width: 0, height: 2))
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 22).font
        label.textColor = R.color.primaryDark()
        label.text = "Import Web Recipes"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.text = "Our iOS action extension allows you to import recipes directly into AnyList while browsing the web."
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var activateButton: UIButton = {
        let button = UIButton()
        button.setTitle("ACTIVATE EXTENSION", for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.backgroundColor = UIColor(hex: "1A645A")
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.addDefaultShadowForPopUp()
        button.addTarget(self, action: #selector(activateButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.webRecipe()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let bottomTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 22).font
        label.textColor = R.color.primaryDark()
        label.text = "Suggested recipe websites"
        return label
    }()
    
    private lazy var bottomDescriptionLabel: UILabel = {
        let label = UILabel()
        let underlineString = NSMutableAttributedString(string: bottomDescriptionText)
        underlineString.addAttribute(NSAttributedString.Key.underlineStyle,
                                     value: NSUnderlineStyle.single.rawValue, range: requiredRange)
        underlineString.addAttribute(NSAttributedString.Key.font,
                                     value: UIFont.SFPro.medium(size: 14).font ?? .systemFont(ofSize: 14),
                                     range: requiredRange)
        underlineString.addAttribute(NSAttributedString.Key.foregroundColor,
                                     value: R.color.darkGray() ?? .gray,
                                     range: requiredRange)
        label.text = bottomDescriptionText
        label.attributedText = underlineString
        label.font = UIFont.SFPro.medium(size: 14).font
        label.textColor = R.color.darkGray()
        label.numberOfLines = 2
        label.isUserInteractionEnabled = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 32
        tableView.contentInset.top = 110
        tableView.register(classCell: ImportWebRecipeCell.self)
        return tableView
    }()
    
    private let alertView = ImportAlertView()
    private var viewDidLayout = false
    
    private let bottomDescriptionText = "We have compiled a list of some suggested recipe websites that support the required import standard"
    private lazy var requiredRange = (bottomDescriptionText as NSString).range(of: "required import standard")
    
    init(viewModel: ImportWebRecipesViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = R.color.background()
        navigationView.backgroundColor = R.color.background()
        
        alertView.delegate = self
        alertView.fadeOut()
        
        makeConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewDidLayout {
            tableView.setContentOffset(.init(x: 0, y: -150), animated: false)
            viewDidLayout = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        alertView.stopViewPropertyAnimator()
    }
    
    private func openUrl(string: String?) {
        guard let urlString = string,
              let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc
    private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func activateButtonTapped() {
        viewModel.showManual()
    }
    
    @objc
    private func tapLabel(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: bottomDescriptionLabel,
                                               inRange: requiredRange) {
            alertView.fadeIn()
        }
    }
    
    private func makeConstraints() {
        self.view.addSubviews([bottomImageView, topInfoView, navigationView, alertView])
        navigationView.addSubview(backButton)
        topInfoView.addSubviews([titleLabel, descriptionLabel, activateButton])
        bottomImageView.addSubview(tableView)
        tableView.addSubviews([bottomTitleLabel, bottomDescriptionLabel])
        
        navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(40)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.verticalEdges.equalToSuperview()
        }
        
        topInfoView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        activateButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(64)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        bottomImageView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.top.equalTo(topInfoView.snp.bottom)
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomTitleLabel.snp.makeConstraints {
            $0.bottom.equalTo(bottomDescriptionLabel.snp.top).offset(-8)
            $0.leading.equalToSuperview().offset(20)
        }
        
        bottomDescriptionLabel.snp.makeConstraints {
            $0.bottom.equalTo(tableView.snp.top).offset(-12)
            $0.leading.equalTo(self.view).offset(20)
            $0.trailing.equalTo(self.view).offset(-20)
        }
        
        alertView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension ImportWebRecipesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.websites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(classCell: ImportWebRecipeCell.self, indexPath: indexPath)
        cell.configure(title: viewModel.websites[safe: indexPath.row]?.title ?? "")
        cell.tapTitle = { [weak self] in
            self?.openUrl(string: self?.viewModel.websites[safe: indexPath.row]?.urlString)
        }
        return cell
    }
}

extension ImportWebRecipesViewController: UITableViewDelegate { }

extension ImportWebRecipesViewController: ImportAlertViewDelegate {
    func tappedItsClear() {
        alertView.fadeOut()
    }
    
    func tappedMicrodata() {
        openUrl(string: "https://schema.org/docs/gs.html")
    }
    
    func tappedHrecipe() {
        openUrl(string: "https://microformats.org/wiki/hrecipe")
    }
}