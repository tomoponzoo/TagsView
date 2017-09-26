//
//  LayoutCache.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/09/25.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import Foundation

public class LayoutCache {
    static let shared = LayoutCache()
    
    private var layouts = [AnyHashable: Layout]()
    private var keys = [AnyHashable]()
    private var capacity = 500
    
    private init() {
    }
    
    func getLayout(identifier: AnyHashable) -> Layout? {
        return layouts[identifier]
    }
    
    func setLayout(_ layout: Layout, identifier: AnyHashable) {
        layouts[identifier] = layout
        setKey(identifier)
    }
    
    func removeLayout(identifier: AnyHashable) {
        layouts.removeValue(forKey: identifier)
        removeKey(identifier)
    }
    
    public func removeAllLayout() {
        layouts.removeAll()
        keys.removeAll()
    }
    
    func setKey(_ key: AnyHashable) {
        keys.append(key)
        if keys.count > capacity {
            removeLayout(identifier: keys[0])
        }
    }
    
    func removeKey(_ key: AnyHashable) {
        guard let index = keys.index(of: key) else {
            return
        }
        keys.remove(at: index)
    }
}
