//
//  SharingListViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.02.2023.
//

import UIKit

final class SharingListViewController: UIViewController {

    var viewModel: SharingListViewModel?
    
    private let contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = UIColor(hex: "#E5F5F3")
        return view
    }()
    
    private let navView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E5F5F3").withAlphaComponent(0.9)
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.sharingList()
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = R.color.primaryDark()
        label.text = "Sync With Family & Friends".localized
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var crossButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.closeButtonCross(), for: .normal)
        button.addTarget(self, action: #selector(crossButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private var contentViewHeight = 306.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showContentView()
    }
    
//    deinit {
//        print("SharingListViewController deinited")
//    }
    
    private func setup() {
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        swipeDownRecognizer.direction = .down
        contentView.addGestureRecognizer(swipeDownRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(crossButtonAction))
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
        
        viewModel?.updateUsers = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                self.calculateContentViewHeight()
                self.contentView.snp.updateConstraints { $0.height.equalTo(self.contentViewHeight) }
                self.view.layoutIfNeeded()
                self.tableView.reloadData()
            }
        }
        
        calculateContentViewHeight()
        setupTableView()
        makeConstraints()
    }
    
    private func calculateContentViewHeight() {
        contentViewHeight = 306.0
        let maxHeight = self.view.frame.height * 0.75
        contentViewHeight += viewModel?.necessaryHeight ?? 0
        tableView.isScrollEnabled = contentViewHeight > maxHeight
        contentViewHeight = contentViewHeight > maxHeight ? maxHeight : contentViewHeight
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(classCell: TitleCell.self)
        tableView.register(classCell: SharedCell.self)
        tableView.register(classCell: SendInvitationCell.self)
        tableView.registerHeader(classHeader: SharingHeaderView.self)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .down:
            hideContentView()
        default: break
        }
    }
    
    @objc
    private func crossButtonAction() {
        hideContentView()
    }
    
    private func hideContentView() {
        updateConstraints(with: contentViewHeight, alpha: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false) {
                self.viewModel?.showCustomReview()
            }
        }
    }
    
    private func showContentView() {
        updateConstraints(with: 0, alpha: 0.2)
    }
    
    private func updateConstraints(with inset: Double, alpha: Double) {
        UIView.animate(withDuration: 0.3) { [ weak self ] in
            self?.view.backgroundColor = .black.withAlphaComponent(alpha)
            self?.contentView.snp.updateConstraints { $0.bottom.equalToSuperview().offset(inset) }
            
            self?.view.layoutIfNeeded()
        }
    }
    
    private func sharingList(url: String) {
        if let urlToShare = NSURL(string: url) {
            let objectsToShare = [urlToShare] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop,
                                                UIActivity.ActivityType.addToReadingList]

            self.present(activityVC, animated: true)
        }
    }
    
    private func makeConstraints() {
        self.view.addSubview(contentView)
        contentView.addSubviews([tableView, navView])
        navView.addSubviews([imageView, titleLabel, crossButton])
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(contentViewHeight)
            $0.height.equalTo(contentViewHeight)
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        navView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(73)
        }
        
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(24)
            $0.height.width.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(12)
            $0.trailing.equalTo(crossButton.snp.leading).offset(-24)
            $0.centerY.equalTo(imageView)
        }
        
        crossButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-28)
            $0.centerY.equalTo(imageView)
            $0.height.width.equalTo(32)
        }
    }
}

extension SharingListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.getSection() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getNumberOfRows(inSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.reusableCell(classCell: TitleCell.self, indexPath: indexPath)
            return cell
        }
        
        if indexPath.section == 1 && !(viewModel?.sharedFriendsIsEmpty ?? true) {
            let cell = tableView.reusableCell(classCell: SharedCell.self, indexPath: indexPath)
            cell.configure(name: viewModel?.getName(by: indexPath.row),
                           photo: viewModel?.getPhoto(by: indexPath.row))
            return cell
        }
        
        let cell = tableView.reusableCell(classCell: SendInvitationCell.self, indexPath: indexPath)
        cell.sendInvitationAction = { [weak self] in
            self?.viewModel?.shareListTapped()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !(section == 0) else {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }
        let headerView = tableView.reusableHeader(classHeader: SharingHeaderView.self)
        let title = section == 1 && !(viewModel?.sharedFriendsIsEmpty ?? true) ? "Shared".localized
                                                                               : "Send Invitation".localized
        headerView.configure(title)
        return headerView
    }
}

extension SharingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) as? SendInvitationCell != nil {
            viewModel?.shareListTapped()
        }
        
        if tableView.cellForRow(at: indexPath) as? SharedCell != nil {
            viewModel?.showStopSharingPopUp(by: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0 : 32
    }
}

extension SharingListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.tableView) ?? false)
    }
}

extension SharingListViewController: SharingListViewModelDelegate {
    func openShareController(with urlToShare: String) {
        sharingList(url: urlToShare)
    }
}
