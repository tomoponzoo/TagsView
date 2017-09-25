//
//  Spacer.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/09/25.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import Foundation

public struct Spacer {
    let vertical: CGFloat
    let horizontal: CGFloat
    
    public static var zero: Spacer {
        return .init(vertical: 0, horizontal: 0)
    }
    
    public init(vertical: CGFloat, horizontal: CGFloat) {
        self.vertical = vertical
        self.horizontal = horizontal
    }
}
