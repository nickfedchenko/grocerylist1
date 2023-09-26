//
//  AddNoteToMealPlanViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 25.09.2023.
//

import UIKit

class AddNoteToMealPlanViewController: UIViewController {

    private let viewModel: AddNoteToMealPlanViewModel
    
    private let grabberBackgroundView = UIView()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "3C3C43", alpha: 0.3)
        view.setCornerRadius(2.5)
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle(R.string.localizable.cancel(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.bold(size: 16).font
        button.setTitleColor(R.color.primaryDark(), for: .normal)
        button.addTarget(self, action: #selector(tappedCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "045C5C")
        button.setTitle("Done".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.heavy(size: 17).font
        button.addTarget(self, action: #selector(tappedDoneButton), for: .touchUpInside)
        button.contentEdgeInsets.left = 20
        button.contentEdgeInsets.right = 20
        button.layer.cornerRadius = 20
        button.layer.cornerCurve = .continuous
        button.layer.maskedCorners = [.layerMinXMaxYCorner]
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset.top = 78
        scrollView.contentInset.bottom = 120
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let noteView = MealPlanNoteTitleView()
    private let dateView = MealPlanDateView()
    private let mealPlanLabelView = MealPlanLabelView()
    
    private let calendarView = MealPlanUpdateDateView()
    
    init(viewModel: AddNoteToMealPlanViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        makeConstraints()

        setupNote()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setup() {
        self.view.backgroundColor = UIColor(hex: "FEFEEB")
        grabberBackgroundView.backgroundColor = UIColor(hex: "FEFEEB").withAlphaComponent(0.95)
        
        noteView.delegate = self
        dateView.delegate = self
        mealPlanLabelView.delegate = self
        calendarView.fadeOut()
        
        viewModel.updateLabels = { [weak self] in
            guard let self else { return }
            self.mealPlanLabelView.configure(allLabels: self.viewModel.labels)
            self.mealPlanLabelView.snp.updateConstraints {
                $0.height.greaterThanOrEqualTo(self.viewModel.labels.count * 42 + 38)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupNote() {
        mealPlanLabelView.configure(allLabels: viewModel.labels)
        dateView.configure(date: viewModel.date)
        calendarView.configure(date: viewModel.date)
        
        calendarView.labelColors = { [weak self] date in
            self?.viewModel.getLabelColors(by: date) ?? []
        }
        
        calendarView.selectDate = { [weak self] selectedDate in
            self?.calendarView.fadeOut()
            if let selectedDate {
                self?.dateView.configure(date: selectedDate)
            }
        }
        
        updateDoneButton()
        guard let note = viewModel.note else {
            return
        }
        
        noteView.configure(title: note.title, details: note.details)
        updateDoneButton()
    }
    
    private func updateDoneButton() {
        let isActive = noteView.title.count > 0
        guard isActive != doneButton.isUserInteractionEnabled else {
            return
        }
        doneButton.backgroundColor = isActive ? R.color.primaryDark() : R.color.lightGray()
        doneButton.setTitleColor(isActive ? .white : R.color.mediumGray(), for: .normal)
        doneButton.isUserInteractionEnabled = isActive
    }
    
    @objc
    private func tappedCancelButton() {
        self.dismiss(animated: true)
    }
    
    @objc
    private func tappedDoneButton() {
        viewModel.saveNote(title: noteView.title,
                           details: noteView.details,
                           date: dateView.currentDate)
        self.dismiss(animated: true)
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc
    func dismissKeyboard() {
        guard let gestureRecognizers = self.view.gestureRecognizers else {
            return
        }
        gestureRecognizers.forEach { $0.isEnabled = false }
        self.view.endEditing(true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([scrollView, grabberBackgroundView, grabberView, cancelButton, doneButton])
        self.scrollView.addSubview(contentView)
        contentView.addSubviews([noteView, dateView, mealPlanLabelView])
        self.view.addSubviews([calendarView])
        
        navigationMakeConstraints()

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(self.view)
        }
        
        noteView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.greaterThanOrEqualTo(81)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        dateView.snp.makeConstraints {
            $0.top.equalTo(noteView.snp.bottom).offset(16)
            $0.height.equalTo(56)
            $0.leading.trailing.equalTo(noteView)
        }
        
        mealPlanLabelView.snp.makeConstraints {
            $0.top.equalTo(dateView.snp.bottom).offset(16)
            $0.height.greaterThanOrEqualTo(viewModel.labels.count * 41 + 38)
            $0.leading.trailing.equalTo(noteView)
            $0.bottom.equalToSuperview()
        }

        calendarView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func navigationMakeConstraints() {
        grabberBackgroundView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(cancelButton.snp.bottom).offset(8)
        }
        
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(5)
            $0.width.equalTo(36)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(24)
        }
        
        doneButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.greaterThanOrEqualTo(120)
        }
        doneButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        doneButton.setContentHuggingPriority(.init(1000), for: .horizontal)
    }
}

extension AddNoteToMealPlanViewController: MealPlanNoteTitleViewDelegate {
    func titleInput() {
        updateDoneButton()
    }
}

extension AddNoteToMealPlanViewController: MealPlanDateViewDelegate {
    func selectDate() {
        calendarView.fadeIn()
    }
}

extension AddNoteToMealPlanViewController: MealPlanLabelViewDelegate {
    func tapMenuLabel() {
        viewModel.showLabels()
    }
    
    func tapLabel(index: Int) {
        viewModel.selectLabel(index: index)
    }
}
