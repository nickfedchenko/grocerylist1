//
//  AddIngredientsToListCalendarView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.10.2023.
//

import UIKit

class AddIngredientsToListCalendarView: UIView {

    var selectDates: (([Date]) -> Void)?
    var fadeOutView: (() -> Void)?
    var labelColors: ((Date) -> [UIColor])?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadius(16)
        view.addDefaultShadowForPopUp()
        return view
    }()
    
    private lazy var calendarView: CalendarView = {
        let view = CalendarView(viewScope: .month)
        view.delegate = self
        view.allowsMultipleSelection = true
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
    
    func configure(dates: [Date] = []) {
        calendarView.setDates(dates: dates)
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
        selectDates?(calendarView.selectedDates)
        fadeOutView?()
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

extension AddIngredientsToListCalendarView: CalendarViewDelegate {
    func selectedDates() {
        selectDates?(calendarView.selectedDates)
    }
    
    func selectedDate(_ date: Date) { }
    
    func getLabelColors(by date: Date) -> [UIColor] {
        labelColors?(date) ?? []
    }
    
    func pageDidChange() { }
    func movedToDate(date: Date) { }
}

extension AddIngredientsToListCalendarView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.calendarView) ?? false)
    }
}
