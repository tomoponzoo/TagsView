//
//  LayoutCache.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/09/25.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import Foundation

class LayoutCache {
    static let shared = LayoutCache()
    
    private var layouts = [AnyHashable: Layout]()
    
    private init() {
    }
    
    func getLayout(identifier: String) -> Layout? {
        return layouts[identifier]
    }
    
    func setLayout(_ layout: Layout, identifier: String) {
        layouts[identifier] = layout
    }
    
    func removeLayout(identifier: String) {
        layouts.removeValue(forKey: identifier)
    }
    
    func removeAllLayout() {
        layouts.removeAll()
    }
}
