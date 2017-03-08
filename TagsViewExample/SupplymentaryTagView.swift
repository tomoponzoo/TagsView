//
//  SupplymentaryTagView.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/03/08.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit
import TagsView

class SupplymentaryTagViewEx: SupplymentaryTagView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 3
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 40, height: 26)
    }
}
