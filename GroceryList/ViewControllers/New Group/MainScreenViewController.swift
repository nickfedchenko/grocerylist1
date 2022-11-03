//
//  MainScreenViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import SnapKit
import UIKit

class MainScreenViewController: UIViewController {
    
    var viewModel: MainScreenViewModelDelegate?
    weak var router: RootRouter?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupTableView()
        addRecognizer()
    }
    
    @objc
    private func searchButtonAction() {
        
    }
    
    private func createAttributedString(title: String, color: UIColor = .white) -> NSAttributedString {
        NSAttributedString(string: title, attributes: [
            .font: UIFont.SFPro.bold(size: 18).font ?? UIFont(),
            .foregroundColor: color
        ])
    }
        // MARK: - UI
    
    private let avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "profileImage")
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "Unnamed"
        return label
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        button.setImage(UIImage(named: "searchButtonImage"), for: .normal)
        return button
    }()
    
    private let segmentControl: UISegmentedControl = {
        let control = CustomSegmentedControl(items: ["Grocery Lists".localized, "Recipes".localized])
        control.setTitleFont(UIFont.SFPro.bold(size: 18).font)
        control.setTitleColor(UIColor(hex: "#657674"))
        control.setTitleColor(UIColor(hex: "#31635A"), state: .selected)
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor(hex: "#D2E7E4")
        control.selectedSegmentTintColor = .white
        return control
    }()
    
    private let groceryListsView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let tableview: UITableView = {
        let tableview = UITableView()
        tableview.showsVerticalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.estimatedRowHeight = UITableView.automaticDimension
        return tableview
    }()
    
    private let bottomCreateListView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let plusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "#plusImage")
        return imageView
    }()
    
    private let createListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "CreateList".localized
        return label
    }()
    
    private func setupConstraints() {
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        view.addSubviews([avatarImage, userNameLabel, searchButton, segmentControl, groceryListsView])
        groceryListsView.addSubviews([tableview, bottomCreateListView])
        bottomCreateListView.addSubviews([plusImage, createListLabel])
        
        avatarImage.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.left.equalTo(22)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(5)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImage.snp.right).inset(-10)
            make.centerY.equalTo(avatarImage)
        }
        
        searchButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(22)
            make.centerY.equalTo(avatarImage)
            make.width.height.equalTo(40)
        }
        
        segmentControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(22)
            make.top.equalTo(avatarImage.snp.bottom).inset(-16)
            make.height.equalTo(48)
        }
        
        groceryListsView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).inset(-18)
            make.bottom.right.left.equalToSuperview()
        }
        
        tableview.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(bottomCreateListView.snp.top)
        }
        
        bottomCreateListView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(86)
        }
        
        plusImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(38)
            make.top.equalToSuperview().inset(24)
            make.height.width.equalTo(24)
        }
        
        createListLabel.snp.makeConstraints { make in
            make.left.equalTo(plusImage.snp.right).inset(-8)
            make.centerY.equalTo(plusImage)
        }
    }
}

// MARK: - TableView
extension MainScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        tableview.backgroundColor = UIColor(hex: "#E8F5F3")
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(GroseryListsTableViewCell.self, forCellReuseIdentifier: "GroseryListsTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableview.dequeueReusableCell(withIdentifier: "GroseryListsTableViewCell", for: indexPath)
                as? GroseryListsTableViewCell else { return UITableViewCell() }
        return cell
    }
}

// MARK: - CreateListAction
extension MainScreenViewController {
    private func addRecognizer() {
        let firstRecognizer = UITapGestureRecognizer(target: self, action: #selector(createListAction))
        bottomCreateListView.addGestureRecognizer(firstRecognizer)
    }
    
    @objc
    private func createListAction() {
     print("createList")
    }
}
