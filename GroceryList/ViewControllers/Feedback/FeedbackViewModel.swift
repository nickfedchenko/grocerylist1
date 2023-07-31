//
//  FeedbackViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 17.05.2023.
//

import ApphudSDK
import Foundation

final class FeedbackViewModel {
    
    enum State {
        case grade
        case writeReview
        case suggestions
    }
    
    weak var router: RootRouter?
    private let network: NetworkEngine
    private var grade: Int = 0
    
    init() {
        self.network = NetworkEngine()
    }
    
    func getNextState(grade: Int) -> State {
        self.grade = grade + 1
        sendGrade(feedbackText: nil)
        return grade != 4 ? .suggestions : .writeReview
    }
    
    func stepTwo(state: State, text: String) {
        switch state {
        case .writeReview:
            writeReview()
        case .suggestions:
            suggestions(text: text)
        case .grade:
            break
        }
    }
    
    func tappedNoThanks() {
        FeedbackManager.shared.setLastShowDate()
        dismissVC()
    }
    
    private func writeReview() {
        FeedbackManager.shared.setDoneFeedBack()
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id1659848939?action=write-review"),
              UIApplication.shared.canOpenURL(url) else {
            router?.navigationDismiss()
            return
        }
        UIApplication.shared.open(url)
        router?.navigationDismiss()
    }
    
    private func suggestions(text: String) {
        sendGrade(feedbackText: text)
        FeedbackManager.shared.setDoneFeedBack()
        router?.navigationDismiss()
    }
    
    private func dismissVC() {
        router?.navigationDismiss()
    }
    
    private func sendGrade(feedbackText: String?) {
        guard let isAutoCategory = UserDefaultsManager.isActiveAutoCategory else {
            return
        }
        let userToken = Apphud.userID()
        let lists = CoreDataManager.shared.getAllLists() ?? []
        
        let feedback = Feedback(userToken: userToken,
                                stars: grade,
                                totalLists: lists.count,
                                isAutoCategory: isAutoCategory,
                                text: feedbackText)
        
        network.sendFeedback(feedback: feedback) { result in
            switch result {
            case .failure(let error):       print(error)
            case .success(let response):    print(response)
            }
        }
    }
}
