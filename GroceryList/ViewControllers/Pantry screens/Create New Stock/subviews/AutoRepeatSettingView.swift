//
//  AutoRepeatSettingView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 04.06.2023.
//

import UIKit
 
protocol AutoRepeatSettingViewDelegate: AnyObject {
    func tappedDone()
    func changeRepeat(_ autoRepeat: String?)
}

class AutoRepeatSettingView: UIView {
    
    weak var delegate: AutoRepeatSettingViewDelegate?
    var isAutoRepeat: Bool {
        notification != nil
    }
    var isReminder: Bool {
        reminderSwitch.isOn
    }
    var notification: AutoRepeatModel? {
        guard let selectedTag,
              let state = StockAutoRepeat(rawValue: selectedTag) else {
            return nil
        }
        return AutoRepeatModel(state: state,
                               times: customSettingView.times,
                               weekday: customSettingView.weekday,
                               period: customSettingView.period)
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 16).font
        label.text = R.string.localizable.autoRepeatSetting()
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 14).font
        label.text = R.string.localizable.foodGoodsWillBeMarked()
        label.numberOfLines = 0
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var reminderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.autorepeat_reminder()?.withTintColor(R.color.lightGray() ?? .lightGray)
        return imageView
    }()
    
    private lazy var reminderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 16).font
        label.textColor = R.color.lightGray()
        label.text = R.string.localizable.setReminder()
        return label
    }()
    
    private lazy var reminderSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        return switcher
    }()
    private var switchEnable = false {
        didSet { reminderSwitch.isUserInteractionEnabled = switchEnable }
    }
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.done().uppercased(), for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.addDefaultShadowForPopUp()
        return button
    }()
    
    private let containerView = UIView()
    private let customSettingView = AutoRepeatCustomSettingView()
    
    private let autoRepeatStates: [StockAutoRepeat] = StockAutoRepeat.allCases
    private var selectedTag: Int?
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
        descriptionLabel.textColor = theme.dark
        doneButton.backgroundColor = theme.dark
        reminderSwitch.onTintColor = theme.dark
        self.backgroundColor = theme.light
        
        customSettingView.setupColor(theme: theme)
    }
    
    func configure(autoRepeat: AutoRepeatModel?, isReminder: Bool) {
        guard let autoRepeat else {
            return
        }
        switchEnable = true
        reminderSwitch.isOn = isReminder
        selectedTag = autoRepeat.state.rawValue
        stackView.arrangedSubviews.forEach { view in
            (view as? AutoRepeatSettingSubView)?.markAsSelected(selectedTag == view.tag,
                                                                color: color)
            (view as? AutoRepeatSettingSubView)?.isVisibleCheckmark(selectedTag == view.tag)
        }
        if autoRepeat.state == .custom {
            customSettingView.configure(autoRepeatModel: autoRepeat)
        }
    }
    
    private func setup() {
        switchEnable = false
        
        autoRepeatStates.forEach { autoRepeatState in
            let view = AutoRepeatSettingSubView()
            view.setRepeat(autoRepeatState)
            view.tag = autoRepeatState.rawValue
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints {
                $0.height.equalTo(46)
            }
            view.selectView = { [weak self] tag in
                Vibration.selection.vibrate()
                self?.delegate?.changeRepeat(StockAutoRepeat(rawValue: tag)?.title)
                self?.selectedTag = tag
                self?.updateReminderColor()
                self?.updateAutoRepeatSettingSubView()
                self?.switchEnable = true
            }
        }
        
        customSettingView.backHandler = { [weak self] autoRepeat in
            self?.showCustomSettingView(isShow: false)
            self?.delegate?.changeRepeat(autoRepeat)
            guard autoRepeat != nil else {
                return
            }
            self?.stackView.arrangedSubviews.forEach { view in
                if view.tag == StockAutoRepeat.custom.rawValue {
                    (view as? AutoRepeatSettingSubView)?.isVisibleCheckmark(true)
                }
            }
        }
        
        customSettingView.valueChangeHandler = { [weak self] autoRepeat in
            self?.delegate?.changeRepeat(autoRepeat)
        }
        
        updateReminderColor()
        makeConstraints()
    }

    private func updateAutoRepeatSettingSubView() {
        stackView.arrangedSubviews.forEach { view in
            (view as? AutoRepeatSettingSubView)?.markAsSelected(selectedTag == view.tag,
                                                                color: color)
            if selectedTag == StockAutoRepeat.custom.rawValue {
                (view as? AutoRepeatSettingSubView)?.isVisibleCheckmark(false)
                showCustomSettingView(isShow: true)
            } else {
                (view as? AutoRepeatSettingSubView)?.isVisibleCheckmark(selectedTag == view.tag)
            }
        }
    }
    
    private func updateReminderColor() {
        guard selectedTag != nil else {
            reminderLabel.textColor = R.color.lightGray()
            reminderSwitch.tintColor = R.color.lightGray()
            reminderImageView.image = R.image.autorepeat_reminder()?.withTintColor(R.color.lightGray() ?? .lightGray)
            return
        }
        reminderLabel.textColor = R.color.darkGray()
        reminderSwitch.tintColor = R.color.darkGray()
        reminderImageView.image = R.image.autorepeat_reminder()?.withTintColor(R.color.darkGray() ?? .darkGray)
    }
    
    private func showCustomSettingView(isShow: Bool) {
        containerView.snp.updateConstraints {
            $0.leading.equalToSuperview().offset(isShow ? -self.bounds.width : 0)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.6, options: [.curveEaseInOut]) {
            self.containerView.alpha = isShow ? 0 : 1
            self.customSettingView.alpha = isShow ? 1 : 0
            self.layoutIfNeeded()
        }
    }
    
    @objc
    private func doneButtonTapped() {
        Vibration.success.vibrate()
        delegate?.tappedDone()
    }
    
    @objc
    private func switchValueDidChange() {
        Vibration.rigid.vibrate()
    }
    
    private func makeConstraints() {
        self.addSubviews([containerView, customSettingView])
        containerView.addSubviews([titleLabel, descriptionLabel, stackView,
                          reminderImageView, reminderLabel, reminderSwitch,
                          doneButton])
        
        containerView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        customSettingView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(containerView.snp.trailing)
            $0.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(titleLabel)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(230)
        }
        
        makeReminderViewConstraints()
        
        doneButton.snp.makeConstraints {
            $0.top.equalTo(reminderImageView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
        }
    }
    
    private func makeReminderViewConstraints() {
        reminderImageView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.height.width.equalTo(40)
        }
        
        reminderLabel.snp.makeConstraints {
            $0.leading.equalTo(reminderImageView.snp.trailing).offset(8)
            $0.centerY.equalTo(reminderImageView)
            $0.trailing.equalTo(reminderSwitch.snp.leading)
        }
        
        reminderSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(reminderImageView)
        }
    }
}

final private class AutoRepeatSettingSubView: UIView {
    
    var selectView: ((Int) -> Void)?
    
    private let colorView = UIView()
    
    private let capitalLetterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.SFProRounded.bold(size: 16).font
        label.textAlignment = .center
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = R.color.darkGray()
        return label
    }()
    
    private let checkmarkImageView = UIImageView()
    private let checkImage = R.image.autorepeat_checkmark()
    
    private let separatorView = UIView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        self.addGestureRecognizer(tapOnView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setRepeat(_ autoRepeat: StockAutoRepeat) {
        titleLabel.text = autoRepeat.title
        capitalLetterLabel.text = autoRepeat.title.first?.uppercased()
    }
    
    func markAsSelected(_ isSelected: Bool, color: UIColor) {
        colorView.backgroundColor = isSelected ? color : R.color.darkGray()
        titleLabel.textColor = isSelected ? color : R.color.darkGray()
        
        checkmarkImageView.image = checkImage?.withTintColor(color)
    }
    
    func isVisibleCheckmark(_ isVisibleCheckmark: Bool) {
        checkmarkImageView.isHidden = !isVisibleCheckmark
    }
    
    private func setup() {
        colorView.layer.cornerRadius = 12
        colorView.layer.cornerCurve = .continuous
        colorView.backgroundColor = R.color.darkGray()
        
        separatorView.backgroundColor = UIColor(hex: "E7EEEE")
        checkmarkImageView.isHidden = true
        
        makeConstraints()
    }
    
    @objc
    private func tappedOnView() {
        selectView?(self.tag)
    }

    private func makeConstraints() {
        self.addSubviews([colorView, capitalLetterLabel, titleLabel,
                          checkmarkImageView, separatorView])
        
        colorView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.top.equalToSuperview().offset(10)
            $0.height.width.equalTo(24)
        }
        
        capitalLetterLabel.snp.makeConstraints {
            $0.center.leading.top.equalTo(colorView)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(colorView.snp.trailing).offset(8)
            $0.centerY.equalTo(colorView)
        }
        
        checkmarkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(2)
            $0.height.width.equalTo(40)
        }
        
        separatorView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-2)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
    }
}

extension StockAutoRepeat {
    var title: String {
        switch self {
        case .daily:    return R.string.localizable.autoDaily()
        case .weekly:   return R.string.localizable.autoWeekly()
        case .monthly:  return R.string.localizable.autoMonthly()
        case .yearly:   return R.string.localizable.autoYearly()
        case .custom:   return R.string.localizable.autoCustom()
        }
    }
}
