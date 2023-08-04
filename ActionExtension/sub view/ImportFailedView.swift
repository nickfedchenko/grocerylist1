//
//  ImportFailedView.swift
//  ActionExtension
//
//  Created by Хандымаа Чульдум on 02.08.2023.
//

import UIKit

class ImportFailedView: UIView {

    var openUrl: ((String?) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 22).font
        label.textColor = UIColor(hex: "045C5C")
        label.text = "Import failed"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = UIColor(hex: "045C5C")
        label.text = R.string.localizable.groceryListWasUnable()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var bottomDescriptionLabel: UILabel = {
        let label = UILabel()
        let underlineString = NSMutableAttributedString(string: bottomDescriptionText)
        underlineString.addAttribute(NSAttributedString.Key.underlineStyle,
                                     value: NSUnderlineStyle.single.rawValue, range: requiredRange)
        underlineString.addAttribute(NSAttributedString.Key.font,
                                     value: UIFont.SFPro.medium(size: 16).font ?? .systemFont(ofSize: 16),
                                     range: requiredRange)
        underlineString.addAttribute(NSAttributedString.Key.foregroundColor,
                                     value: UIColor(hex: "045C5C"),
                                     range: requiredRange)
        label.text = bottomDescriptionText
        label.attributedText = underlineString
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = UIColor(hex: "045C5C")
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.webRecipe()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 32
        tableView.register(classCell: ImportWebRecipeCell.self)
        return tableView
    }()
    
    private let alertView = ImportAlertView()
    
    private let bottomDescriptionText = R.string.localizable.weHaveCompiledAList()
    private lazy var requiredRange = (bottomDescriptionText as NSString).range(of: R.string.localizable.rangeRequiredImportStandard())
    
    private let websites = RecipeWebsite.allCases
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        alertView.fadeOut()
        alertView.delegate = self
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewDidDisappear() {
        alertView.stopViewPropertyAnimator()
    }
    
    @objc
    private func tapLabel(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: bottomDescriptionLabel,
                                               inRange: requiredRange) {
            alertView.fadeIn()
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, descriptionLabel, bottomDescriptionLabel,
                          imageView, tableView,
                          alertView])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(19)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        bottomDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        [titleLabel, descriptionLabel, bottomDescriptionLabel].forEach {
            $0.setContentHuggingPriority(.init(999), for: .vertical)
            $0.setContentCompressionResistancePriority(.init(999), for: .vertical)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(bottomDescriptionLabel.snp.bottom).offset(17)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(imageView)
        }
        
        alertView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension ImportFailedView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        websites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(classCell: ImportWebRecipeCell.self, indexPath: indexPath)
        cell.configure(title: websites[indexPath.row].title)
        cell.titleLabel.font = UIFont.SFPro.semibold(size: 18).font
        cell.titleLabel.textColor = R.color.primaryDark()
        cell.tapTitle = { [weak self] in
            self?.openUrl?(self?.websites[indexPath.row].urlString)
        }
        return cell
    }
}

extension ImportFailedView: UITableViewDelegate { }

extension ImportFailedView: ImportAlertViewDelegate {
    func tappedItsClear() {
        alertView.fadeOut()
    }
    
    func tappedMicrodata() {
        openUrl?("https://schema.org/docs/gs.html")
    }
    
    func tappedHrecipe() {
        openUrl?("https://microformats.org/wiki/hrecipe")
    }
}
