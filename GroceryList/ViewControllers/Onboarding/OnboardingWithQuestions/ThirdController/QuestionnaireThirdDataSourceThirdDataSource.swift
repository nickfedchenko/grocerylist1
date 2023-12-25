//
//  QuestionnaireThirdDataSource.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 25.12.2023.
//

import Foundation

class QuestionnaireThirdDataSource {
    
    lazy var sections = [firstSection, secondSection, thirdSection, fourthSection]
    
    private var firstSection = QuestionnaireThirdControllerSections(
        headerTitle: R.string.localizable.onboardingWithQuestionsQuestion1Title(),
        headerQuestionNumber: "1",
        questions: [
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion1answer1()),
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion1answer2()),
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion1answer3()),
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion1answer4())
        ],
        isMultiselectionEnabled: true
    )
    
    private var secondSection = QuestionnaireThirdControllerSections(
        headerTitle: R.string.localizable.onboardingWithQuestionsQuestion2Title(),
        headerQuestionNumber: "2",
        questions: [
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion2answer1()),
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion2answer2()),
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion2answer3())
        ],
        isMultiselectionEnabled: true
    )
    
    private var thirdSection = QuestionnaireThirdControllerSections(
        headerTitle: R.string.localizable.onboardingWithQuestionsQuestion3Title(),
        headerQuestionNumber: "3",
        questions: [
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion3answer1()),
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion3answer2()),
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion3answer3()),
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion3answer4())
        ],
        isMultiselectionEnabled: false
    )
    
    private var fourthSection = QuestionnaireThirdControllerSections(
        headerTitle: R.string.localizable.onboardingWithQuestionsQuestion4Title(),
        headerQuestionNumber: "4",
        questions: [
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion4answer1()),
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion4answer2()),
            QuestionModel(question: R.string.localizable.onboardingWithQuestionsQuestion4answer3())
        ],
        isMultiselectionEnabled: false
    )
    
    func questionSelected(indexPath: IndexPath) {
        let section = sections[indexPath.section]
        if !section.isMultiselectionEnabled {
            section.questions.enumerated().forEach({
                sections[indexPath.section].questions[$0.offset].isSelected = false
            })
        }
       
        sections[indexPath.section].questions[indexPath.row - 1].isSelected = !section.questions[indexPath.row - 1].isSelected
    }
    
    func configureAnswers() {
        print(sections.map({ $0.questions }))
    }
    
    func isNextButtonEnabled(page: Int) -> Bool {
        sections[page].questions.contains(where: { $0.isSelected })
    }
}
