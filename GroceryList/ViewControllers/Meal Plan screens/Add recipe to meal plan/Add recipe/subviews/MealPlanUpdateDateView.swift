//
//  MealPlanUpdateDateView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 18.09.2023.
//

import UIKit

class MealPlanUpdateDateView: UIView {

    var selectDate: ((Date?) -> Void)?
    var labelColors: ((Date) -> [UIColor])?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadius(16)
        view.addDefaultShadowForPopUp()
        return view
    }()
    
    private lazy var calendarView: CalendarView = {
        let view = CalendarView()
        view.delegate = self
        view.backgroundColor = .clear
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(date: Date = Date()) {
        calendarView.setDate(date)
    }
    
    func configure(isEditMode: Bool) {
        calendarView.isEditMode = isEditMode
    }
    
    private func setup() {
        self.backgroundColor = .black.withAlphaComponent(0.2)
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        tapOnView.delegate = self
        self.addGestureRecognizer(tapOnView)
        
        makeConstraints()
    }
    
    @objc
    private func tappedOnView() {
        selectDate?(nil)
    }
    
    private func makeConstraints() {
        self.addSubviews([containerView])
        containerView.addSubview(calendarView)
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.center.equalToSuperview()
            $0.height.equalTo(380)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension MealPlanUpdateDateView: CalendarViewDelegate {
    func selectedDate(_ date: Date) {
        selectDate?(date)
    }
    
    func getLabelColors(by date: Date) -> [UIColor] {
        labelColors?(date) ?? []
    }
    
    func pageDidChange() { }
    func selectedDates() { }
}

extension MealPlanUpdateDateView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.calendarView) ?? false)
    }
}
