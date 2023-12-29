//
//  Models.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.12.2023.
//

import Foundation
struct QuestionnaireThirdControllerSections: Hashable {
    var headerTitle: String
    var headerQuestionNumber: String
    var questions: [QuestionModel]
    var isMultiselectionEnabled: Bool
    
    func getHeaderModel() -> QuestionnaireThirdControllerCellModel {
        .topHeader(model: QuestionnaireHeaderCellModel(
            text: headerTitle,
            questionNumber: headerQuestionNumber,
            isMultiselected: isMultiselectionEnabled
        ))
    }
    
    func getQuestionModels() -> [QuestionnaireThirdControllerCellModel] {
        questions.map({ .cell(model: QuestionnaireCellModel(text: $0.question) ) })
    }
}

struct QuestionModel: Hashable {
    var question: String
    var isSelected = false
}

enum QuestionnaireThirdControllerCellModel: Hashable {
    case topHeader(model: QuestionnaireHeaderCellModel)
    case cell(model: QuestionnaireCellModel)
}

struct QuestionnaireHeaderCellModel: Hashable {
    var id: UUID = UUID()
    var text: String
    var questionNumber: String
    var isMultiselected: Bool
}

struct QuestionnaireCellModel: Hashable {
    var id: UUID = UUID()
    var text: String
}
