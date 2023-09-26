//
//  AddNoteToMealPlanViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 25.09.2023.
//

import UIKit

class AddNoteToMealPlanViewModel {
    
    weak var router: RootRouter?
    var updateUI: (() -> Void)?
    
    var updateLabels: (() -> Void)?
    
    private(set) var note: MealPlanNote?
    private(set) var labels: [MealPlanLabel] = []
    private(set) var date: Date
    
    private var allNote: [MealPlanNote] = []
    private let colorManager = ColorManager.shared
    private var mealPlanLabel: MealPlanLabel? {
        didSet { selectedLabel() }
    }
    
    init(note: MealPlanNote?, date: Date) {
        self.note = note
        self.date = date
        setNote()
        
        getNotesFromStorage()
        getLabelsFromStorage()
    }
    
    func getLabelColors(by date: Date) -> [UIColor] {
        let notesByDate = allNote.filter { $0.date.onlyDate == date.onlyDate }
        let labels = notesByDate.compactMap {
            if let labelId = $0.label,
               let dbLabel = CoreDataManager.shared.getLabel(id: labelId.uuidString) {
                return MealPlanLabel(dbModel: dbLabel)
            } else {
                return MealPlanLabel(defaultLabel: .none)
            }
        }
        let colorNumbers = labels.compactMap { $0.color }
        return colorNumbers.map { colorManager.getLabelColor(index: $0) }
    }
    
    func saveNote(title: String, details: String?, date: Date) {
        let label = mealPlanLabel
        let newNote: MealPlanNote
        if var note {
            note.title = title
            note.details = details
            note.date = date
            note.label = label?.id
            newNote = note
        } else {
            newNote = MealPlanNote(title: title, details: details,
                                   date: date, label: label?.id)
        }
        CoreDataManager.shared.saveMealPlanNote(newNote)
        updateUI?()
    }
    
    func selectLabel(index: Int) {
        guard let selectedLabel = labels[safe: index] else {
            return
        }
        
        mealPlanLabel = selectedLabel
    }
    
    func showLabels() {
        router?.goToMealPlanLabels(label: mealPlanLabel,
                                   updateUI: { [weak self] selectedLabel in
            self?.mealPlanLabel = selectedLabel
            self?.getLabelsFromStorage()
            self?.updateLabels?()
        })
    }
    
    private func setNote() {
        guard let note else {
            mealPlanLabel = MealPlanLabel(defaultLabel: .none)
            return
        }
        
        if let labelId = note.label,
           let dbLabel = CoreDataManager.shared.getLabel(id: labelId.uuidString) {
            mealPlanLabel = MealPlanLabel(dbModel: dbLabel)
        } else {
            mealPlanLabel = nil
        }
    }
    
    private func selectedLabel() {
        for (index, label) in labels.enumerated() {
            labels[index].isSelected = label.id == mealPlanLabel?.id
        }
        updateLabels?()
    }
    
    private func getNotesFromStorage() {
        allNote = CoreDataManager.shared.getMealPlanNotes()?.map({ MealPlanNote(dbModel: $0) }) ?? []
    }
    
    private func getLabelsFromStorage() {
        labels = CoreDataManager.shared.getAllLabels()?.map({
            var label = MealPlanLabel(dbModel: $0)
            label.isSelected = label.id == mealPlanLabel?.id
            return label
        }) ?? []
    }
}
