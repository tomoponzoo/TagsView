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
        let engine = LayoutEngine(tagsView: self, preferredMaxLayoutWidth: preferredMaxLayoutWidth)
        let layout = engine.layout(identifier: layoutIdentifier, partition: layoutPartition)
        
        removeConstraints(constraints)
        
        widthAnchor.constraint(equalToConstant: layout.size.width).isActive = true
        
        let heightConstraint = heightAnchor.constraint(equalToConstant: layout.size.height)
        heightConstraint.priority = .fittingSizeLevel
        heightConstraint.isActive = true
        
        tagViews.forEach { (tagView) in
            tagView.constraints.filter { (constraint) -> Bool in
                if let firstItem = constraint.firstItem as? UIView, firstItem == tagView, constraint.secondItem == nil {
                    return true
                } else {
                    return false
                }
            }.forEach { (constraint) in
                tagView.removeConstraint(constraint)
            }
            tagView.isHidden = true
        }
        
        zip(tagViews, layout.columns).forEach { (tagView, column) in
            tagView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: column.minX).isActive = true
            tagView.topAnchor.constraint(equalTo: self.topAnchor, constant: column.minY).isActive = true
            tagView.widthAnchor.constraint(equalToConstant: column.width).isActive = true
            tagView.heightAnchor.constraint(equalToConstant: column.height).isActive = true
            tagView.isHidden = false
        }

        if let supplymentaryTagView = supplymentaryTagView {
            supplymentaryTagView.constraints.filter { (constraint) -> Bool in
                if let firstItem = constraint.firstItem as? UIView, firstItem == supplymentaryTagView, constraint.secondItem == nil {
                    return true
                } else {
                    return false
                }
            }.forEach { (constraint) in
                supplymentaryTagView.removeConstraint(constraint)
            }
            supplymentaryTagView.isHidden = true
        }
        
        if let supplymentaryTagView = supplymentaryTagView, let column = layout.supplymentaryColumn {
            supplymentaryTagView.leftAnchor.constraint(equalTo: leftAnchor, constant: column.minX).isActive = true
            supplymentaryTagView.topAnchor.constraint(equalTo: topAnchor, constant: column.minY).isActive = true
            supplymentaryTagView.widthAnchor.constraint(equalToConstant: column.width).isActive = true
            supplymentaryTagView.heightAnchor.constraint(equalToConstant: column.height).isActive = true
            supplymentaryTagView.isHidden = false
        }

        super.updateConstraints()
    }
    
    open override var intrinsicContentSize: CGSize {
        let engine = LayoutEngine(tagsView: self, preferredMaxLayoutWidth: preferredMaxLayoutWidth)
        let layout = engine.layout(identifier: layoutIdentifier, partition: layoutPartition)
        return layout.size
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
