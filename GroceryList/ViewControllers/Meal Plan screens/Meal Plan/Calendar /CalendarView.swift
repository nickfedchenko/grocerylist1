//
//  CalendarView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.09.2023.
//

import FSCalendar
import UIKit

protocol CalendarViewDelegate: AnyObject {
    func selectedDate(_ date: Date)
    func getLabelColors(by date: Date) -> [UIColor]
    func pageDidChange()
}

final class CalendarView: UIView {
    
    weak var delegate: CalendarViewDelegate?
    
    private lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 16).font
        label.textColor = R.color.primaryDark()
        return label
    }()
    
    private lazy var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.dataSource = self
        calendar.delegate = self
        calendar.register(CalendarCell.self, forCellReuseIdentifier: "cell")

        calendar.scope = scope
        calendar.firstWeekday = UInt(Calendar.current.firstWeekday)
        calendar.scrollDirection = .vertical
        calendar.pagingEnabled = true
        calendar.headerHeight = 0
        
        calendar.backgroundColor = .clear
        calendar.appearance.weekdayFont = UIFont.SFPro.medium(size: 11).font
        calendar.appearance.titleFont = UIFont.SFPro.medium(size: 16).font
        calendar.appearance.titlePlaceholderColor = R.color.mediumGray()
        calendar.appearance.weekdayTextColor = R.color.primaryDark()
        
        calendar.appearance.titleDefaultColor = R.color.primaryDark()
        calendar.appearance.titleSelectionColor = R.color.primaryDark()
        calendar.appearance.titleTodayColor = R.color.primaryDark()
        calendar.appearance.selectionColor = .clear
        calendar.appearance.todaySelectionColor = .clear
        calendar.appearance.todayColor = .clear
        return calendar
    }()
    
    private lazy var previousMonthButton: UIButton = {
        var button = UIButton()
        button.addTarget(self, action: #selector(tappedPreviousMonthButton), for: .touchUpInside)
        button.setImage(R.image.chevronMiniLeft(), for: .normal)
        return button
    }()
    
    private lazy var nextMonthButton: UIButton = {
        var button = UIButton()
        button.addTarget(self, action: #selector(tappedNextMonthButton), for: .touchUpInside)
        button.setImage(R.image.chevronMiniRight(), for: .normal)
        return button
    }()

    private var scope: FSCalendarScope {
        UserDefaultsManager.shared.selectedMonthOrWeek == 0 ? .month : .week
    }
    private(set) var selectedDate = Date()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        calendar.collectionViewLayout.invalidateLayout()
    }
    
    func reloadData() {
        calendar.reloadData()
    }
    
    func setToday() {
        setDate(Date())
    }
    
    func setDate(_ date: Date) {
        selectedDate = date
        calendar.select(date)
        calendar.reloadData()
    }
    
    func setScope() {
        guard calendar.scope != scope else {
            return
        }
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            self.calendar.scope = self.scope
            self.calendar.alpha = 0
            self.previousMonthButton.alpha = self.scope == .month ? 0 : 1
            self.nextMonthButton.alpha = self.scope == .month ? 0 : 1
        } completion: { [weak self] _ in
            self?.updateScope()
            self?.calendar.alpha = 1
            self?.layoutIfNeeded()
        }
    }
    
    private func setup() {
        let isMonth = scope == .month
        previousMonthButton.alpha = isMonth ? 0 : 1
        nextMonthButton.alpha = isMonth ? 0 : 1
        calendar.weekdayHeight = scope == .month ? 0 : 12
        
        changeMonthLabel(selectedDate)
        makeConstraints()
    }
    
    private func changeMonthLabel(_ date: Date) {
        self.monthLabel.text = date.getStringDate(format: "MMMMyyyy").uppercased()
    }
    
    private func updateScope() {
        let topOffset = scope == .month ? 10 : 8
        let leadingOffset = scope == .month ? 8 : 25
        self.calendar.weekdayHeight = scope == .month ? 0 : 12
        calendar.snp.remakeConstraints {
            $0.top.equalTo(monthLabel.snp.bottom).offset(topOffset)
            $0.leading.equalToSuperview().offset(leadingOffset)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(topOffset)
        }
        self.layoutIfNeeded()
    }
    
    @objc
    private func tappedPreviousMonthButton() {
        calendar.setCurrentPage(calendar.currentPage.previousWeek, animated: true)
    }

    @objc
    private func tappedNextMonthButton() {
        calendar.setCurrentPage(calendar.currentPage.nextWeek, animated: true)
    }
    
    private func makeConstraints() {
        self.addSubviews([monthLabel, calendar, previousMonthButton, nextMonthButton])
        
        monthLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        let topOffset = scope == .month ? 10 : 8
        let leadingOffset = scope == .month ? 8 : 25
        calendar.snp.makeConstraints {
            $0.top.equalTo(monthLabel.snp.bottom).offset(topOffset)
            $0.leading.equalToSuperview().offset(leadingOffset)
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        previousMonthButton.snp.makeConstraints {
            $0.top.equalTo(monthLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(4)
            $0.height.equalTo(32)
            $0.width.equalTo(16)
        }
        
        nextMonthButton.snp.makeConstraints {
            $0.top.equalTo(monthLabel.snp.bottom).offset(24)
            $0.trailing.equalToSuperview().offset(-4)
            $0.height.equalTo(32)
            $0.width.equalTo(16)
        }
    }
}

extension CalendarView: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, cellFor date: Date,
                  at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        guard let cell = cell as? CalendarCell else {
            return cell
        }
        let type: CalendarCell.TypeOfSelection
        if date.onlyDate == selectedDate.onlyDate {
            if date.onlyDate == Date().onlyDate {
                type = .selectedToday
            } else {
                type = .selected
            }
        } else {
            if date.onlyDate == Date().onlyDate {
                type = .today
            } else {
                type = .none
            }
        }

        cell.configure(selection: type)
        cell.configure(labelColors: delegate?.getLabelColors(by: date) ?? [])
        return cell
    }
}

extension CalendarView: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        delegate?.selectedDate(date)
        
        calendar.reloadData()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        changeMonthLabel(calendar.currentPage)
        delegate?.pageDidChange()
    }
}
