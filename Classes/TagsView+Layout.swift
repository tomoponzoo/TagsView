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
        
        let markedTagViews = tagViews.filter({ $0.tag >= 0 }).sorted(by: { $0.tag < $1.tag })
        layout.columns.enumerated().forEach { (index, column) in
            let tagView = markedTagViews[index]
            tagView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: column.minX).isActive = true
            tagView.topAnchor.constraint(equalTo: self.topAnchor, constant: column.minY).isActive = true
            tagView.widthAnchor.constraint(equalToConstant: column.width).isActive = true
            tagView.heightAnchor.constraint(equalToConstant: column.height).isActive = true
            tagView.isHidden = false
        }
        
        if let supplementaryTagView = supplementaryTagView {
            supplementaryTagView.constraints.filter { (constraint) -> Bool in
                if let firstItem = constraint.firstItem as? UIView, firstItem == supplementaryTagView, constraint.secondItem == nil {
                    return true
                } else {
                    return false
                }
            }.forEach { (constraint) in
                supplementaryTagView.removeConstraint(constraint)
            }
            supplementaryTagView.isHidden = true
        }
        
        if let supplementaryTagView = supplementaryTagView, let column = layout.supplementaryColumn {
            supplementaryTagView.leftAnchor.constraint(equalTo: leftAnchor, constant: column.minX).isActive = true
            supplementaryTagView.topAnchor.constraint(equalTo: topAnchor, constant: column.minY).isActive = true
            supplementaryTagView.widthAnchor.constraint(equalToConstant: column.width).isActive = true
            supplementaryTagView.heightAnchor.constraint(equalToConstant: column.height).isActive = true
            supplementaryTagView.isHidden = false
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
