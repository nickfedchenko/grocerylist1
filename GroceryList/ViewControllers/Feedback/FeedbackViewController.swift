//
//  FeedbackViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.05.2023.
//

import UIKit

final class FeedbackViewController: UIViewController {

    var viewModel: FeedbackViewModel?
    
    private lazy var baseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.feedback()
        imageView.layer.cornerRadius = 8
        imageView.layer.cornerCurve = .continuous
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var baseShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.action()
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        view.addDefaultShadowForPopUp()
        return view
    }()
    
    private lazy var whiteView: FeedbackView = {
        let view = FeedbackView()
        view.updateView(by: .grade)
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var noThanksButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.noThanks(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
        button.addTarget(self, action: #selector(tappedNoThanksButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black.withAlphaComponent(0.5)
        makeConstraints()
        
        whiteView.tappedStar = { [weak self] grade in
            guard let state = self?.viewModel?.getNextState(grade: grade) else {
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self?.whiteView.updateView(by: state)
            }
        }
        
        whiteView.tappedNextButton = { [weak self] state, text in
            self?.viewModel?.stepTwo(state: state, text: text)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                               as? NSValue)?.cgRectValue,
           let keyWindow = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first(where: { $0.isKeyWindow }) {
            let safeAreaHeight = keyWindow.safeAreaInsets.bottom
            updateImageConstraints(offset: -(keyboardSize.height - safeAreaHeight) * 0.5)
        }
    }
    
    @objc
    private func onKeyboardDisappear() {
        updateImageConstraints(offset: 0)
    }
    
    @objc
    private func dismissKeyboard() {
        guard let gestureRecognizers = self.view.gestureRecognizers else {
            return
        }
        gestureRecognizers.forEach {
            $0.isEnabled = false
        }
        self.view.endEditing(true)
    }
    
    @objc
    private func tappedNoThanksButton() {
        viewModel?.tappedNoThanks()
    }

    private func updateImageConstraints(offset: CGFloat) {
        baseImageView.snp.updateConstraints {
            $0.centerY.equalToSuperview().offset(offset)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func makeConstraints() {
        self.view.addSubviews([baseShadowView, baseImageView])
        baseImageView.addSubviews([whiteView, noThanksButton])
        
        baseShadowView.snp.makeConstraints {
            $0.edges.equalTo(baseImageView)
        }
        
        baseImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(335)
            $0.height.equalTo(462)
        }
        
        whiteView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(303)
            $0.height.equalTo(250)
            $0.bottom.equalTo(noThanksButton.snp.top).offset(-2)
        }
        
        noThanksButton.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
    }
}
