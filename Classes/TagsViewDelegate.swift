//
//  TagsViewDelegate.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/09/25.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import Foundation

public protocol TagsViewDelegate: class {
    func tagsView(_ tagsView: TagsView, didSelectItemAt index: Int)
    func didSelectSupplementaryItem(_ tagsView: TagsView)
}
