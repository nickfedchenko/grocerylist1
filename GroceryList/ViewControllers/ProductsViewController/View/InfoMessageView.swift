//
//  InfoMessageView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 13.02.2023.
//

import UIKit

final class InfoMessageView: UIView {
    
    private lazy var blackView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var handImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.hand_white()
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Long press on an Item".localized
        label.textColor = .black
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#85F3D5")
        view.layer.cornerRadius = 10
        view.addShadowForView(radius: 22, height: 3)
        return view
    }()
    
    private lazy var crossButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.close_cross(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        setUpTriangle()
        crossButton.layer.cornerRadius = crossButton.frame.height / 2
        blackView.layer.cornerRadius = blackView.frame.height / 2
        titleLabel.sizeToFit()
    }
    
    func updateView() {
        blackView.isHidden = UserDefaultsManager.countInfoMessage != 0
    }
    
    private func setup() {
        self.backgroundColor = .clear
        updateView()
        makeConstraints()
    }
    
    private func setUpTriangle() {
        let shapeName = "TriangleShape"
        self.layer.sublayers?.removeAll(where: { $0.name == shapeName })
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: self.frame.width / 2, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width / 2 + 12, y: 20))
        path.addLine(to: CGPoint(x: self.frame.width / 2 - 12, y: 20))
        path.addLine(to: CGPoint(x: self.frame.width / 2, y: 0))
        
        let shape = CAShapeLayer()
        shape.name = shapeName
        shape.path = path
        shape.fillColor = UIColor(hex: "#85F3D5").cgColor
        self.layer.addSublayer(shape)
    }
    
    @objc
    private func closeButtonTapped() {
        UserDefaultsManager.countInfoMessage = 5
        UIView.animate(withDuration: 0.5) { self.isHidden = true }
    }
    
    private func makeConstraints() {
        blackView.addSubview(handImageView)
        infoView.addSubview(titleLabel)
        self.addSubviews([blackView, infoView, crossButton])
        
        blackView.snp.makeConstraints {
            $0.height.width.equalTo(48)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.snp.top).offset(-4)
        }
        
        handImageView.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.width.equalTo(17)
            $0.center.equalToSuperview()
        }
        
        infoView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(14)
            $0.bottom.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(14)
            $0.bottom.trailing.equalToSuperview().offset(-14)
        }
        
        crossButton.snp.makeConstraints {
            $0.height.width.equalTo(26)
            $0.centerX.equalTo(infoView.snp.trailing)
            $0.centerY.equalTo(infoView.snp.top)
        }
    }
}
