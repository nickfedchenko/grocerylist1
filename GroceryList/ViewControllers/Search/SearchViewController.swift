//
//  SearchViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.03.2023.
//

import UIKit

class SearchViewController: UIViewController {

    private let navView = UIView()
    
    private let iconImageView = UIImageView(image: R.image.searchButtonImage())
    private lazy var searchView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle(R.string.localizable.cancel(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.bold(size: 15).font
        button.setTitleColor(UIColor(hex: "#1A645A"), for: .normal)
        button.addTarget(self, action: #selector(tappedCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var crossCleanerButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.xMarkInput(), for: .normal)
        button.addTarget(self, action: #selector(tappedCleanerButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.SFPro.medium(size: 16).font
        textField.tintColor = UIColor(hex: "#1A645A")
        textField.backgroundColor = .clear
        textField.textColor = .black
        return textField
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchView.alpha = 0
        searchTextField.alpha = 0
        cancelButton.alpha = 0
        
        searchView.transform = CGAffineTransform(scaleX: 0, y: 1)
            .translatedBy(x: self.view.bounds.width - 100,
                          y: navView.bounds.midY)
        iconImageView.transform = CGAffineTransform(translationX: self.view.bounds.width - 96,
                                                    y: navView.bounds.midY - 4)
        
        UIView.animate(withDuration: 0.4) {
            self.searchView.alpha = 1.0
            self.searchView.transform = .identity
            self.iconImageView.transform = .identity
        } completion: { _ in
            self.searchTextField.alpha = 1
            self.cancelButton.alpha = 1
        }
    }

    func setSearchPlaceholder(_ placeholder: String) {
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: " " + R.string.localizable.searchIn() + placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "#7A948F")]
        )
    }
    
    func setup() {
        self.view.backgroundColor = UIColor(hex: "#E5F5F3")
        searchTextField.becomeFirstResponder()
        
        setupTableView()
        makeConstraints()
    }
    
    func setupTableView() { }
    
    @objc
    func tappedCancelButton() { }
    
    @objc
    func tappedCleanerButton() {
        searchTextField.text = ""
    }
    
    func setCleanerButton(isVisible: Bool) {
        crossCleanerButton.isHidden = !isVisible
    }
    
    private func makeConstraints() {
        self.view.addSubviews([tableView, navView])
        navView.addSubviews([searchView, iconImageView, searchTextField, crossCleanerButton, cancelButton])
        
        navView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(navView.snp.bottom).offset(-20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        searchView.snp.makeConstraints {
            $0.top.equalTo(navView)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        iconImageView.snp.makeConstraints {
            $0.centerY.equalTo(searchView)
            $0.leading.equalTo(searchView)
            $0.width.height.equalTo(40)
        }
        
        searchTextField.snp.makeConstraints {
            $0.centerY.equalTo(searchView)
            $0.leading.equalTo(iconImageView.snp.trailing)
            $0.trailing.equalTo(crossCleanerButton.snp.leading).offset(-7)
            $0.height.equalTo(28)
        }
        
        crossCleanerButton.snp.makeConstraints {
            $0.centerY.equalTo(searchView)
            $0.trailing.equalTo(cancelButton.snp.leading).offset(-12)
            $0.height.width.equalTo(24)
        }
        
        cancelButton.snp.makeConstraints {
            $0.centerY.equalTo(searchView)
            $0.trailing.equalTo(searchView).offset(-12)
            $0.height.equalTo(24)
        }
    }
}
