//
//  CalendarViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.10.2023.
//

import UIKit

class CalendarViewController: UIViewController {

    var selectedDate: ((Date) -> Void)?
    
    private let calendarView = MealPlanUpdateDateView()
    private var allMealPlans: [MealPlan] = []
    private let currentDate: Date
    
    init(currentDate: Date) {
        self.currentDate = currentDate
        super.init(nibName: nil, bundle: nil)
        
        allMealPlans = CoreDataManager.shared.getAllMealPlans()?.map({ MealPlan(dbModel: $0) }) ?? []
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.configure(date: currentDate)
        calendarView.configure(isEditMode: true)
        
        calendarView.labelColors = { [weak self] date in
            self?.getLabelColors(by: date) ?? []
        }
        
        calendarView.selectDate = { [weak self] selectedDate in
            self?.calendarView.fadeOut()
            if let selectedDate {
                self?.selectedDate?(selectedDate)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self?.dismiss(animated: true)
            }
        }
        
        makeConstraints()
    }
    
    private func getLabelColors(by date: Date) -> [UIColor] {
        let mealPlansByDate = allMealPlans.filter { $0.date.onlyDate == date.onlyDate }
        let labels = mealPlansByDate.compactMap {
            if let labelId = $0.label,
               let dbLabel = CoreDataManager.shared.getLabel(id: labelId.uuidString) {
                return MealPlanLabel(dbModel: dbLabel)
            } else {
                return MealPlanLabel(defaultLabel: .none)
            }
        }
        let colorNumbers = labels.compactMap { $0.color }
        return colorNumbers.map { ColorManager.shared.getLabelColor(index: $0) }
    }
    
    private func makeConstraints() {
        self.view.addSubviews([calendarView])
        
        calendarView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
