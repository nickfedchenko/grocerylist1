//
//  SelectIconViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 29.05.2023.
//

import UIKit

final class SelectIconViewController: UIViewController {

    var selectedIcon: ((UIImage?) -> Void)?
    var icon: UIImage?
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerCurve = .continuous
        view.addCustomShadow(radius: 11, offset: CGSize(width: 0, height: -12))
        return view
    }()
    
    private let selectIconView = SelectIconView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectIconView.delegate = self
        selectIconView.selectedIcon = icon
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        tapOnView.delegate = self
        self.view.addGestureRecognizer(tapOnView)
        
        makeConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateBottomConstraint(view: contentView, with: 0)
    }
    
    func updateColor(theme: Theme) {
        selectIconView.configure(theme: theme)
    }
    
    private func updateBottomConstraint(view: UIView, with offset: Double) {
        view.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(offset)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    private func hidePanel() {
        updateBottomConstraint(view: contentView, with: 776)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc
    func tappedOnView() {
        hidePanel()
    }
    
    private func makeConstraints() {
        self.view.addSubview(contentView)
        contentView.addSubview(selectIconView)

        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(776)
            $0.height.equalTo(776)
        }
        
        selectIconView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}

extension SelectIconViewController: SelectIconViewDelegate {
    func selectIcon(_ icon: UIImage?) {
        selectedIcon?(icon)
        hidePanel()
    }
    
    func tappedCross() {
        hidePanel()
    }
}

extension SelectIconViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.contentView) ?? false)
    }
}
