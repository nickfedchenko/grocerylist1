//
//  FiltersView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.07.2023.
//

import UIKit
import TagListView

class FiltersView: TagListView {

    private var tags: [RecipeTag] = []
    private var tagNames: [String] = [] {
        didSet {
            removeAllTags()
            addTags(tagNames)
            updateTagsColor()
        }
    }
    
    private var color = R.color.darkGray()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(tags: [RecipeTag], color: UIColor?) {
        self.tags = tags
        self.color = color
        tagNames = tags.compactMap({ $0.title + "      " })
    }
    
    private func setup() {
        self.backgroundColor = .clear
        
        self.textFont = UIFont.SFPro.regular(size: 17).font
        self.textColor = .white
        self.paddingY = 8
        self.paddingX = 8
        self.marginY = 12
        self.marginX = 12
        self.cornerRadius = 4
    }
    
    func updateTagsColor() {
        self.tagBackgroundColor = color ?? .green
        
        tags.enumerated().forEach { index, tag in
            let isException = (tag as? ExceptionFilter) != nil
            if isException {
                removeTag(tag.title + "      ")
                let tagView = self.insertTag("     " + tag.title + "      ", at: index)
                tagView.tagBackgroundColor = R.color.attention() ?? .red
            }
        }
        
        self.tagViews.forEach { tagView in
            let exceptionImageView = UIImageView(image: R.image.filterException())
            let tagClearImageView = UIImageView(image: R.image.filterTagClear())
            
            tagView.addSubviews([exceptionImageView, tagClearImageView])
            
            exceptionImageView.snp.makeConstraints {
                $0.leading.top.equalToSuperview().offset(4)
                $0.width.height.equalTo(tagView.backgroundColor == R.color.attention() ?? .red ? 24 : 0)
            }
            
            tagClearImageView.snp.makeConstraints {
                $0.width.height.equalTo(32)
                $0.centerY.trailing.equalToSuperview()
            }
        }
    }
}
