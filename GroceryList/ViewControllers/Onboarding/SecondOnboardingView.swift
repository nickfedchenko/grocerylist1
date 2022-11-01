//
//  SecondView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.11.2022.
//

import UIKit

class SecondOnboardingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
      }

      required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      }
    
    func firstAnimation() {
        
    }
    
    func secndAnimation() {
        
    }
    
    private let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "secondBG")
        return imageView
    }()
    
    private func setupConstraints() {
       
        addSubviews([backgroundView])
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }
}
