//
//  FAQViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 13.07.2023.
//

import UIKit
import WebKit

class FAQViewController: UIViewController {

    private let navigationView = UIView()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(
            string: R.string.localizable.back(),
            attributes: [.foregroundColor: UIColor(hex: "1A645A"),
                         .font: UIFont.SFProDisplay.semibold(size: 17).font ?? UIFont()]
        )
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setImage(R.image.back_Chevron(), for: .normal)
        button.tintColor = UIColor(hex: "0C695E")
        button.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        return button
    }()
    
    private let webView = WKWebView()
    private let activityView = ActivityIndicatorView()
    private var initialUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.backgroundColor = UIColor(hex: "E5F5F3")
        self.view.backgroundColor = UIColor(hex: "E5F5F3")
        webView.navigationDelegate = self
        webView.isHidden = true
        webView.scrollView.contentInset.bottom = 80
        
        makeConstraints()
        loadFAQ()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityView.show(for: webView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !InternetConnection.isConnected() {
            let alert = UIAlertController(title: "", message: "Проверьте Интернет соединение", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default) { _ in

            }
            alert.addAction(alertAction)
            self.present(alert, animated: true)
        }
    }
    
    private func loadFAQ() {
        initialUrl = getUrlForFAQ()
        guard let url = URL(string: initialUrl) else {
            return
        }
        
        webView.load(URLRequest(url: url))
    }
    
    private func getUrlForFAQ() -> String {
        let urlString = "https://ketodietapplication.site/faq/"
        guard let locale = Locale.current.languageCode,
              let currentLocale = CurrentLocale(rawValue: locale) else {
            return urlString + "en"
        }
        return urlString + currentLocale.rawValue
    }
    
    private func updateNavigationConstraints() {
        let isInitialPage = initialUrl == webView.url?.absoluteString
        backButton.isHidden = !isInitialPage
        navigationView.snp.updateConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(isInitialPage ? 42 : 2)
        }
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func tappedBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([webView, activityView, navigationView])
        navigationView.addSubview(backButton)
        
        navigationView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(42)
        }
        
        webView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        activityView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}

extension FAQViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityView.removeFromView()
        self.webView.isHidden = false
        updateNavigationConstraints()
    }
}
