//
//  Models.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.12.2023.
//

import Foundation
struct QuestionnaireThirdControllerSections: Hashable {
    var headerTitle: String
    var questions: [String]
    
    func getHeaderModel() -> QuestionnaireThirdControllerCellModel {
        .topHeader(model: QuestionnaireHeaderCellModel() )
    }
    
    func getQuestionModels() -> [QuestionnaireThirdControllerCellModel] {
        questions.map({ _ in .cell(model: QuestionnaireCellModel() ) })
    }
}

enum QuestionnaireThirdControllerCellModel: Hashable {
    case topHeader(model: QuestionnaireHeaderCellModel)
    case cell(model: QuestionnaireCellModel)
}

struct QuestionnaireHeaderCellModel: Hashable {
    var id: UUID = UUID()
}

struct QuestionnaireCellModel: Hashable {
    var id: UUID = UUID()
}
