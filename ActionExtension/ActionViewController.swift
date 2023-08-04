//
//  ActionViewController.swift
//  ActionExtension
//
//  Created by Хандымаа Чульдум on 01.08.2023.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import SnapKit

enum ActionExtensionError: Error {
    case userCancelledRequest
}

class ActionViewController: UIViewController {

    private let network = NetworkEngine()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.cancel(), for: .normal)
        button.setTitleColor(UIColor(hex: "045C5C"), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "045C5C")
        button.setTitle("Save Recipe", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.heavy(size: 17).font
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.contentEdgeInsets.left = 20
        button.contentEdgeInsets.right = 20
        button.layer.cornerRadius = 20
        button.layer.cornerCurve = .continuous
        button.layer.maskedCorners = [.layerMinXMaxYCorner]
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let recipeView = RecipeView()
    private let importFailedView = ImportFailedView()
    private let activityView = ActivityIndicatorView()
    private var webRecipe: WebRecipe?
    private var pageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hex: "EBFEFE")
        importFailedView.fadeOut()
        importFailedView.openUrl = { url in
            guard let urlString = url,
                  let url = URL(string: urlString) else {
                return
            }
            self.openUrl(url: url)
        }
        
        makeConstraints()
        getPageUrlFromExtensionContext()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityView.show(for: self.view)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        importFailedView.viewDidDisappear()
    }
    
    func openUrl(url: URL?) {
        let selector = sel_registerName("openURL:")
        var responder = self as UIResponder?
        while let respon = responder,
                !respon.responds(to: selector) {
            responder = respon.next
        }
        _ = responder?.perform(selector, with: url)
    }
    
    private func getPageUrlFromExtensionContext() {
        guard let inputItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = inputItem.attachments?.first else {
            activityView.removeFromView()
            showImportFailedView()
            return
        }
        
        let typeIdentifier: String
        if #available(iOS 15, *) {
            typeIdentifier = UTType.propertyList.identifier
        } else {
            typeIdentifier = kUTTypePropertyList as String
        }

        itemProvider.loadItem(forTypeIdentifier: typeIdentifier) { [weak self] (dict, error) in
            if error != nil {
                self?.activityView.removeFromView()
                self?.showImportFailedView()
            }

            guard let itemDict = dict as? NSDictionary,
                  let jsValues = itemDict[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else {
                return
            }

            let pageURL = jsValues["URL"] as? String ?? ""
            self?.getParseRecipe(url: pageURL)
        }
        
    }
    
    private func getParseRecipe(url: String) {
        network.parseWebRecipe(recipeUrl: url) { [weak self] result in
            self?.activityView.removeFromView()
            switch result {
            case let .failure(error):
                print(error)
                self?.showImportFailedView()
            case let .success(recipeResponse):
                self?.showRecipe(webRecipe: recipeResponse.recipe, url: url)
            }
        }
    }
    
    private func showRecipe(webRecipe: WebRecipe?, url: String) {
        AmplitudeManager.shared.logEvent(.recipeImportDone)
        guard let webRecipe else {
            showImportFailedView()
            return
        }
        self.webRecipe = webRecipe
        saveButton.isUserInteractionEnabled = true
        recipeView.isHidden = false
        
        guard let url = URL(string: url),
              let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            recipeView.configure(recipe: webRecipe, url: url)
            pageUrl = url
            return
        }
        pageUrl = host
        recipeView.configure(recipe: webRecipe, url: host)
    }
    
    private func showImportFailedView() {
        AmplitudeManager.shared.logEvent(.recipeImportFailed)
        saveButton.isUserInteractionEnabled = true
        recipeView.isHidden = true
        importFailedView.fadeIn()
        cancelButton.fadeOut()
        saveButton.setTitle(R.string.localizable.cancel(), for: .normal)
    }
    
    @objc
    private func cancelButtonTapped() {
        extensionContext?.cancelRequest(withError: ActionExtensionError.userCancelledRequest)
    }
    
    @objc
    private func saveButtonTapped() {
        guard saveButton.titleLabel?.text != R.string.localizable.cancel() else {
            cancelButtonTapped()
            return
        }
        guard let webRecipe else {
            return
        }
        let controller = CollectionsViewController(recipe: webRecipe, url: pageUrl)
        self.present(controller, animated: true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([cancelButton, saveButton, recipeView, importFailedView])
        
        self.view.addSubview(activityView)
        
        cancelButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(42)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.greaterThanOrEqualTo(120)
        }
        
        activityView.snp.makeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        recipeView.snp.makeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        importFailedView.snp.makeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
