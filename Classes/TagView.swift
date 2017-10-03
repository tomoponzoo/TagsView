//
//  TagView.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/03/08.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit

open class BaseTagView: UIView {
    open var isHighlighted: Bool = false
    open var isSelected: Bool = false
}

open class TagView: BaseTagView {
    open var reuseIdentifier = "default"
}

open class SupplymentaryTagView: BaseTagView {
}
