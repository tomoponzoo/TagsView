//
//  TagViewEx.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/03/08.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit
import TagsView

class TagViewEx: TagView {
    @IBOutlet weak var label: UILabel!
    
    var string: String?
    
    override var isHighlighted: Bool {
        didSet {
            label.textColor = isHighlighted ? UIColor.blue : UIColor.black
        }
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? UIColor.red : UIColor.black
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 3
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
    
    override var intrinsicContentSize: CGSize {
        guard let string = string else { return CGSize.zero }
        
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 26)
        let rect = (string as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [
            NSFontAttributeName: label.font
            ], context: nil)
        
        let newSize = rect.size
        return CGSize(width: newSize.width + 12, height: 26)
    }
}
