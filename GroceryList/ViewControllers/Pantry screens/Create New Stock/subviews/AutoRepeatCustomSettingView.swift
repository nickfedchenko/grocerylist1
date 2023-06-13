//
//  AutoRepeatCustomSettingView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 04.06.2023.
//

import UIKit

class AutoRepeatCustomSettingView: UIView {
    
    var backHandler: ((String?) -> Void)?
    var valueChangeHandler: ((String?) -> Void)?
    
    var times: Int {
        pickerView.selectedRow(inComponent: 0)
    }
    var weekday: Int {
        selectWeekdayNumber
    }
    var period: RepeatPeriods {
        repeatPeriods[pickerView.selectedRow(inComponent: 1)]
    }
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var setButton: UIButton = {
        let button = UIButton()
        button.setTitle("Set", for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.addTarget(self, action: #selector(setButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.contentEdgeInsets.left = 10
        button.contentEdgeInsets.right = 10
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.text = "Repeat every ..."
        return label
    }()
    
    private let weekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.isHidden = true
        return stackView
    }()
    
    private let pickerView = UIPickerView()
    
    private let repeatPeriods = RepeatPeriods.allCases
    private var shortWeekdays: [String] = []
    private var fullWeekdays: [String] = []
    private var selectWeekdayNumber: Int = 0
    private var color: UIColor = .white
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupColor(theme: Theme) {
        self.color = theme.dark
        titleLabel.textColor = theme.dark
        backButton.setImage(R.image.greenArrowBack()?.withTintColor(theme.dark), for: .normal)
        setButton.backgroundColor = theme.dark
        self.backgroundColor = theme.light
        
        setupWeekdays()
    }
    
    func configure(autoRepeatModel: AutoRepeatModel) {
        pickerView.selectRow(autoRepeatModel.times ?? 0,
                             inComponent: 0,
                             animated: true)
        pickerView.selectRow(autoRepeatModel.period?.rawValue ?? 0,
                             inComponent: 1,
                             animated: true)
        if autoRepeatModel.period == .weeks {
            weekStackView.isHidden = false
            selectWeekdayNumber = autoRepeatModel.weekday ?? 0
            weekStackView.arrangedSubviews.forEach {
                ($0 as? WeekdayView)?.markAsSelected($0.tag == selectWeekdayNumber)
            }
        }
    }
    
    private func setup() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let symbols = DateFormatter().shortWeekdaySymbols ?? []
        shortWeekdays = Array(symbols[1..<symbols.count]) + symbols[0..<1]
        let fullSymbols = DateFormatter().standaloneWeekdaySymbols ?? []
        fullWeekdays = Array(fullSymbols[1..<fullSymbols.count]) + fullSymbols[0..<1]
        
        makeConstraints()
    }
    
    private func setupWeekdays() {
        weekStackView.removeAllArrangedSubviews()

        shortWeekdays.enumerated().forEach { index, day in
            let view = WeekdayView()
            view.configure(color: color, text: day)
            view.tag = index
            let dayNumberOfWeek = (index + 1) % 7
            view.markAsSelected(dayNumberOfWeek == Date().dayNumberOfWeek)
            weekStackView.addArrangedSubview(view)
            view.snp.makeConstraints {
                $0.height.width.equalTo(40)
            }
            view.tappedOnView = { [weak self] tag in
                self?.selectWeekdays(tag: tag)
                self?.selectWeekdayNumber = tag
                self?.valueChangeHandler?(self?.pickerValue())
            }
        }
    }
    
    private func isVisibleWeekdays(_ isVisible: Bool) {
        weekStackView.isHidden = !isVisible
    }
    
    private func selectWeekdays(tag: Int) {
        weekStackView.arrangedSubviews.forEach {
            ($0 as? WeekdayView)?.markAsSelected($0.tag == tag)
        }
    }
    
    private func pickerValue() -> String {
        var value = ""
        let period = pickerView.selectedRow(inComponent: 1)
        let times = pickerView.selectedRow(inComponent: 0)
        
        if period == 1 { // weeks
            if times >= 1 {
                value = "every \(times + 1) weekly: \(fullWeekdays[selectWeekdayNumber])"
            } else {
                value = "weekly: \(fullWeekdays[selectWeekdayNumber])"
            }
        } else {
            if times == 0 {
                value = repeatPeriods[period].title
            } else {
                value = "every \(times + 1) \(repeatPeriods[period])"
            }
        }
        
        return value
    }
    
    @objc
    private func setButtonTapped() {
        backHandler?(pickerValue())
    }
    
    @objc
    private func backButtonTapped() {
        backHandler?(nil)
    }
    
    private func makeConstraints() {
        self.addSubviews([backButton, titleLabel, setButton, pickerView,
                          weekStackView])
        
        backButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.centerX.equalToSuperview()
            
        }
        
        setButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
            $0.width.greaterThanOrEqualTo(70)
        }
        
        pickerView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(268)
        }
        
        weekStackView.snp.makeConstraints {
            $0.top.equalTo(pickerView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
    }
}

extension AutoRepeatCustomSettingView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:     return 10
        case 1:     return repeatPeriods.count
        default:    return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                    forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let height: CGFloat = 0.5
        for subview in pickerView.subviews {
            if subview.subviews.isEmpty {
              let topLineView = UIView()
              topLineView.frame = CGRect(x: 0.0, y: 0.0, width: subview.frame.size.width, height: height)
                topLineView.backgroundColor = UIColor(hex: "3C3C43", alpha: 0.36)
              subview.addSubview(topLineView)
                
              let bottomLineView = UIView()
              bottomLineView.frame = CGRect(x: 0.0, y: subview.frame.size.height - height, width: subview.frame.size.width, height: height)
              bottomLineView.backgroundColor = UIColor(hex: "3C3C43", alpha: 0.36)
              subview.addSubview(bottomLineView)
            }
          subview.backgroundColor = .clear
        }
        
        let pickerLabel = UILabel()
        pickerLabel.font = UIFont.SFProDisplay.regular(size: 22).font
        pickerLabel.textAlignment = NSTextAlignment.center
        switch component {
        case 0:     pickerLabel.text = "\(row + 1)"
        case 1:     pickerLabel.text = repeatPeriods[row].title
        default:    pickerLabel.text = "\(row)"
        }
        let selectedRow = pickerView.selectedRow(inComponent: component)
        pickerLabel.textColor = selectedRow == row ? color : UIColor(hex: "537979")
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        valueChangeHandler?(pickerValue())
        isVisibleWeekdays(pickerView.selectedRow(inComponent: 1) == 1)
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    rowHeightForComponent component: Int) -> CGFloat {
        return 31
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:     return 70
        case 1:     return 100
        default:    return 100
        }
    }
}

private final class WeekdayView: UIView {
    
    var tappedOnView: ((Int) -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.semibold(size: 14).font
        label.textAlignment = .center
        return label
    }()
    
    private(set) var isSelected = false
    private var color: UIColor = .white
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(color: UIColor, text: String) {
        self.color = color
        titleLabel.text = text
    }
    
    func markAsSelected(_ isSelected: Bool) {
        self.isSelected = isSelected
        titleLabel.textColor = isSelected ? .white : R.color.darkGray()
        self.backgroundColor = isSelected ? color : .clear
        self.layer.borderColor = isSelected ? color.cgColor : R.color.darkGray()?.cgColor
    }
    
    private func setup() {
        self.layer.cornerRadius = 20
        self.layer.cornerCurve = .continuous
        self.layer.borderWidth = 1
        self.layer.borderColor = R.color.darkGray()?.cgColor
        
        let tapOnViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        self.addGestureRecognizer(tapOnViewRecognizer)
        
        makeConstraints()
    }
    
    @objc
    private func tapOnView() {
        tappedOnView?(self.tag)
    }
    
    private func makeConstraints() {
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}

extension RepeatPeriods {
    var title: String {
        switch self {
        case .days:     return "days"
        case .weeks:    return "weeks"
        case .months:   return "months"
        case .years:    return "years"
        }
    }
}
