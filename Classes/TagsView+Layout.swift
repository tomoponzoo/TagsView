//
//  TagsView+Layout.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/09/25.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit

extension TagsView {
    
    open override func updateConstraints() {
        containerViewTopConstraint.constant = layoutProperties.padding.top
        containerViewLeftConstraint.constant = layoutProperties.padding.left
        containerViewRightConstraint.constant = layoutProperties.padding.right
        containerViewBottomConstraint.constant = layoutProperties.padding.bottom
        
        super.updateConstraints()
    }
    
    open override var intrinsicContentSize: CGSize {
        let preferredMaxLayoutWidth = measureView.preferredMaxLayoutWidth
        guard preferredMaxLayoutWidth > 0 else {
            return super.intrinsicContentSize
        }
        
        self.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        
        let engine = LayoutEngine(tagsView: self, preferredMaxWidth: measureView.preferredMaxLayoutWidth)
        let layout = engine.layout(identifier: layoutIdentifier)
        return layout.size
    }
    
    open override func layoutSubviews() {
        let engine = LayoutEngine(tagsView: self, preferredMaxWidth: measureView.preferredMaxLayoutWidth)
        let layout = engine.layout(identifier: layoutIdentifier)
        
        let tagViews = self.tagViews
        tagViews.forEach { (tagView) in
            tagView.isHidden = true
        }
        
        zip(tagViews, layout.columns).forEach { (tagView, frame) in
            tagView.frame = frame
            tagView.isHidden = false
        }
        
        if let frame = layout.supplymentaryColumn {
            supplymentaryTagView?.frame = frame
            supplymentaryTagView?.isHidden = false
        } else {
            supplymentaryTagView?.isHidden = true
        }
    }
    
    func resetLayoutProperties() -> LayoutProperties {
        guard let dataSource = dataSource else {
            return LayoutProperties()
        }
        
        let numberOfTags = dataSource.numberOfTags(in: self)
        let numberOfRows = dataSource.numberOfRows(in: self)
        let alignment = dataSource.alignment(in: self)
        let padding = dataSource.padding(in: self)
        let spacer = dataSource.spacer(in: self)
        
        let layoutProperties = LayoutProperties(
            numberOfTags: numberOfTags,
            numberOfRows: numberOfRows,
            alignment: alignment,
            padding: padding,
            spacer: spacer
        )
        return layoutProperties
    }
}
