//
//  Layout.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/09/25.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import Foundation

class Layout {
    let size: CGSize
    let columns: [CGRect]
    let supplymentaryColumn: CGRect?
    
    init(layout: RowsLayout) {
        size = layout.size
        columns = layout.columns
        supplymentaryColumn = layout.supplymentaryColumn
    }
}
