//
//  QuantityView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.03.2023.
//

import UIKit

protocol QuantityViewDelegate: AnyObject {
    func quantityChange(text: String?)
    func getUnitsNumberOfCells() -> Int
    func getTitleForCell(at index: Int) -> String?
    func cellSelected(at index: Int)
}

class QuantityView: UIView {
    
    weak var delegate: QuantityViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 15).font
        label.textColor = UIColor(hex: "#777777")
        label.text = R.string.localizable.quantity1()
        return label
    }()
    
    private lazy var quantityBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.isHidden = false
        view.addShadowForView()
        return view
    }()
    
    lazy var quantityTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.SFPro.medium(size: 18).font
        textField.delegate = self
        textField.textColor = .black
        textField.textAlignment = .center
        textField.text = "0"
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private lazy var minusButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(minusButtonAction), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(R.image.minusInactive(), for: .normal)
        return button
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(plusButtonAction), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(R.image.plusInactive(), for: .normal)
        return button
    }()
    
    private lazy var unitsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D2D5DA")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.addShadowForView()
        return view
    }()
    
    private lazy var whiteArrowForSelectUnit: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.whiteArrowRight()
        return imageView
    }()
    
    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        label.textAlignment = .center
        label.text = "pieces".localized
        return label
    }()

    private lazy var unitTableBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor(hex: "#31635A").cgColor
        view.layer.borderWidth = 1
        view.isHidden = false
        view.addShadowForView()
        return view
    }()
    
    private lazy var unitTableview: UITableView = {
        let tableview = UITableView()
        tableview.showsVerticalScrollIndicator = false
        tableview.estimatedRowHeight = UITableView.automaticDimension
        tableview.layer.cornerRadius = 8
        tableview.layer.masksToBounds = true
        return tableview
    }()

    var quantityCount: Double = 0.0 {
        didSet { quantityTextField.text = getDecimalString() }
    }
    private var quantityValueStep = 0.0
    private var isActive = true
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
        
        let tapOnSelectUnits = UITapGestureRecognizer(target: self, action: #selector(tapOnSelectUnitsAction))
        unitsView.addGestureRecognizer(tapOnSelectUnits)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func point(inside point: CGPoint,
                        with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)
        if !inside {
            for subview in subviews {
                let pointInSubview = subview.convert(point, from: self)
                if subview.point(inside: pointInSubview, with: event) {
                    return true
                }
            }
        }
        return inside
    }
    
    func setActive(_ isActive: Bool) {
        guard self.isActive != isActive else {
            return
        }
        self.isActive = isActive
        let color = UIColor(hex: isActive ? "#1A645A" : "#D1D5DB")
        quantityBackgroundView.layer.borderColor = color.cgColor
        unitsView.backgroundColor = color
        quantityTextField.textColor = color
        minusButton.setImage(isActive ? R.image.minusActive() : R.image.minusInactive(), for: .normal)
        plusButton.setImage(isActive ? R.image.plusActive() : R.image.plusInactive(), for: .normal)
    }
    
    func setQuantityCount(_ quantity: Double) {
        quantityCount = quantity
    }
    
    func setQuantityValueStep(_ step: Int) {
        quantityValueStep = Double(step)
        quantityCount = 0
        quantityTextField.text = "0"
    }
    
    func setUnit(title: String) {
        unitLabel.text = title
    }
    
    private func setup() {
        self.backgroundColor = .clear
        setupTableView()
        
        makeConstraints()
    }
    
    @objc
    private func plusButtonAction() {
        setActive(true)
        quantityCount += quantityValueStep
        delegate?.quantityChange(text: getQuantityString())
    }

    @objc
    private func minusButtonAction() {
        setActive(true)
        let difference = quantityCount - quantityValueStep
        quantityCount = difference <= 0 ? 0 : difference
        delegate?.quantityChange(text: getQuantityString())
    }
    
    private func getDecimalString() -> String {
        String(format: "%.\(quantityCount.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", quantityCount)
    }
    
    private func getQuantityString() -> String? {
        guard let quantityText = quantityTextField.text,
              let unitText = unitLabel.text else {
            return nil
        }
        return quantityText + " " + unitText
    }
    
    @objc
    private func tapOnSelectUnitsAction() {
        setActive(true)
        unitTableBackgroundView.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    @objc
    private func tapSelectUnitsBGAction() {
        hideTableview(cell: nil)
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, quantityBackgroundView, unitsView,
                          unitTableBackgroundView])
        quantityBackgroundView.addSubviews([quantityTextField, minusButton, plusButton])
        unitsView.addSubviews([unitLabel, whiteArrowForSelectUnit])
        unitTableBackgroundView.addSubviews([unitTableview])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(29)
            $0.top.equalToSuperview()
            $0.height.equalTo(17)
        }
        
        quantityBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.height.equalTo(40)
            $0.width.equalTo(200)
        }

        unitsView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.height.equalTo(40)
            $0.width.equalTo(134)
        }
        
        unitTableBackgroundView.transform = CGAffineTransform(scaleX: 1, y: 0)
        unitTableBackgroundView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(unitsView)
            make.height.equalTo(320)
        }
        
        unitTableview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        makeQuantityViewConstraints()
        makeUnitsViewConstraints()
    }
    
    private func makeQuantityViewConstraints() {
        quantityTextField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        minusButton.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.height.width.equalTo(40)
        }
        
        plusButton.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
            $0.height.width.equalTo(40)
        }
    }
    
    private func makeUnitsViewConstraints() {
        unitLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.trailing.equalTo(whiteArrowForSelectUnit.snp.leading).offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        whiteArrowForSelectUnit.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.top.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(17)
        }
    }
}

extension QuantityView: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        unitTableview.backgroundColor = .white
        unitTableview.delegate = self
        unitTableview.dataSource = self
        unitTableview.isScrollEnabled = true
        unitTableview.separatorStyle = .none
        unitTableview.register(classCell: UnitsCell.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        delegate?.getUnitsNumberOfCells() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(classCell: UnitsCell.self, indexPath: indexPath)
        let title = delegate?.getTitleForCell(at: indexPath.row) ?? ""
        cell.setupCell(title: title, isSelected: false, color: UIColor(hex: "#31635A"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = unitTableview.cellForRow(at: indexPath)
        cell?.isSelected = true
        hideTableview(cell: cell)
        delegate?.cellSelected(at: indexPath.row)
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func hideTableview(cell: UITableViewCell?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.unitTableBackgroundView.transform = CGAffineTransform(scaleX: 1, y: 0)
            cell?.isSelected = false
        }
    }
}

extension QuantityView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setActive(true)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        quantityCount = quantityTextField.text?.asDouble ?? 0
        delegate?.quantityChange(text: getQuantityString())
    }
}
