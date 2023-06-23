//
//  SelectListDataManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import UIKit

class SelectListDataManager: ListDataSource {
    
    override func createDataSourceArray() {
       
        // секции - у нас их ограниченое количество
        var finalArray: [SectionModel] = []
        var favoriteSection = SectionModel(id: 1, cellType: .usual, sectionType: .favorite, lists: [])
        var todaySection = SectionModel(id: 2, cellType: .usual, sectionType: .today, lists: [])
        var weekSection = SectionModel(id: 3, cellType: .usual, sectionType: .week, lists: [])
        var monthSection = SectionModel(id: 4, cellType: .usual, sectionType: .month, lists: [])
        
        // сортировка всеъ моделек и раскидывание по секциям
        transformedModels?.filter({ $0.isFavorite == true }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ favoriteSection.lists.append($0) })

        transformedModels?.filter({ Calendar.current.isDateInToday($0.dateOfCreation) && !$0.isFavorite }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ todaySection.lists.append($0) })
       
        transformedModels?.filter({ isDateInWeek(date: $0.dateOfCreation) && !Calendar.current.isDateInToday($0.dateOfCreation) && !$0.isFavorite }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ weekSection.lists.append($0) })
      
        transformedModels?.filter({ !isDateInWeek(date: $0.dateOfCreation) && !Calendar.current.isDateInToday($0.dateOfCreation) && !$0.isFavorite }).forEach({ monthSection.lists.append($0) })
        
        let sections: [SectionModel] = [favoriteSection, todaySection, weekSection, monthSection]
        
        // защита от краша при наличии пустой секции
        sections.filter({ $0.lists != [] }).forEach({ finalArray.append($0) })
        
        dataSourceArray = finalArray
    }
}
