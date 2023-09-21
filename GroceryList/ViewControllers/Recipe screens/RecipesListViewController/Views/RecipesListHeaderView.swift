//
//  RecipesListHeaderView.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 06.12.2022.
//

import UIKit

protocol RecipesListHeaderViewDelegate: AnyObject {
    func backButtonTapped()
    func searchButtonTapped()
    func changeViewButtonTapped()
}

final class RecipesListHeaderView: UIView {
    
    weak var delegate: RecipesListHeaderViewDelegate?

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let attrTitle = NSAttributedString(
            string: R.string.localizable.recipes(),
            attributes: [
                .font: R.font.sfProRoundedBold(size: 15) ?? .systemFont(ofSize: 15),
                .foregroundColor: R.color.primaryDark() ?? UIColor(hex: "#045C5C")
            ]
        )
        button.imageEdgeInsets.right = 11
        button.setImage(R.image.greenArrowBack(), for: .normal)
        button.tintColor = R.color.primaryDark()
        button.setAttributedTitle(attrTitle, for: .normal)
        return button
    }()
    
    let searchButton = UIButton()
    let changeViewButton = UIButton()
    private var mainColor: UIColor = .black

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActions()
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    } 
    
    func setColor(color: UIColor) {
        mainColor = color
        
        let attrTitle = NSAttributedString(
            string: R.string.localizable.recipes(),
            attributes: [
                .font: R.font.sfProRoundedBold(size: 16) ?? .systemFont(ofSize: 15),
                .foregroundColor: color
            ]
        )
        backButton.setAttributedTitle(attrTitle, for: .normal)
        backButton.tintColor = color
        searchButton.setImage(R.image.searchButtonImage()?.withTintColor(color), for: .normal)
        updateImageChangeViewButton(recipeIsTableView: UserDefaultsManager.shared.recipeIsTableView)
    }
    
    func updateImageChangeViewButton(recipeIsTableView: Bool) {
        let tableIcon = R.image.recipeTableView()?.withTintColor(mainColor)
        let gridIcon = R.image.recipeGridView()?.withTintColor(mainColor)
        let image = recipeIsTableView ? tableIcon : gridIcon
        
        changeViewButton.setImage(image, for: .normal)
    }
    
    private func setupActions() {
        backButton.addAction(
            UIAction { [weak self] _ in
                self?.delegate?.backButtonTapped()
            }
            , for: .touchUpInside
        )
        
        searchButton.addAction(
            UIAction { [weak self] _ in
                self?.delegate?.searchButtonTapped()
            }
            , for: .touchUpInside
        )
        
        changeViewButton.addAction(
            UIAction { [weak self] _ in
                self?.delegate?.changeViewButtonTapped()
            }
            , for: .touchUpInside
        )
    }
    
    private func setupSubviews() {
        self.addSubviews([backButton, searchButton, changeViewButton])
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(2)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(97)
        }
        
        searchButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.trailing.equalTo(changeViewButton.snp.leading).inset(8)
            make.height.width.equalTo(40)
        }
        
        changeViewButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.trailing.equalToSuperview().inset(16)
            make.height.width.equalTo(40)
        }
    }
}
