//
//  TagsView.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/03/08.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit

let unassignedTag = -1

open class TagsView: UIView {
    public weak var dataSource: TagsViewDataSource?
    public weak var delegate: TagsViewDelegate?
    
    public var preferredMaxLayoutWidth: CGFloat = UIScreen.main.bounds.width
    
    public var allowsMultipleSelection = false
    
    public var numberOfTags: Int {
        return layoutProperties.numberOfTags
    }
    
    public var numberOfRows: Rows {
        return layoutProperties.numberOfRows
    }
    
    public var alignment: Alignment {
        return layoutProperties.alignment
    }
    
    public var padding: UIEdgeInsets {
        return layoutProperties.padding
    }
    
    public var spacer: Spacer {
        return layoutProperties.spacer
    }
    
    var layoutProperties = LayoutProperties()
    var layoutIdentifier: String?
    var layoutPartition: String?
    
    var tagViewNibs = [String: UINib]()
    var supplementaryTagViewNib: UINib?

    var tagViews: [TagView] {
        return subviews.flatMap { $0 as? TagView }
    }
    
    var supplementaryTagView: SupplementaryTagView? {
        return subviews.flatMap { $0 as? SupplementaryTagView }.first
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    public func registerTagView(nib: UINib?, forReuseIdentifier reuseIdentifier: String = "default") {
        guard let nib = nib else { return }
        tagViewNibs[reuseIdentifier] = nib
    }
    
    public func registerSupplementaryTagView(nib: UINib?) {
        supplementaryTagViewNib = nib
    }
    
    public func reloadData() {
        reloadData(identifier: nil, partition: nil)
    }
    
    public func reloadData(identifier: String? = nil, partition: String? = nil) {
        layoutProperties = resetLayoutProperties()
        layoutIdentifier = identifier
        layoutPartition = partition
        
        tagViews.forEach { (tagView) in
            tagView.tag = unassignedTag
        }
        
        (0..<numberOfTags).forEach { (index) in
            _ = self.dataSource?.tagsView(self, viewForIndexAt: index)
        }
        
        _ = dataSource?.supplementaryTagView(in: self)
        
        invalidateIntrinsicContentSize()
    }
    
    public func selectTag(at index: Int) {
        if let tagView = tagView(at: index) {
            selectTag(tagView: tagView)
        }
    }
    
    public func deselectTag(at index: Int) {
        tagView(at: index)?.isSelected = false
    }
    
    public func index(for view: TagView) -> Int? {
        return subviews.index(of: view)
    }
    
    public func tagView(at index: Int) -> TagView? {
        return index < tagViews.count ? tagViews[index] : nil
    }
    
    public var indexForSupplementaryView: Int? {
        let engine = LayoutEngine(tagsView: self, preferredMaxLayoutWidth: preferredMaxLayoutWidth)
        let layout = engine.layout(identifier: layoutIdentifier, partition: layoutPartition)
        
        guard let supplementaryColumn = layout.supplementaryColumn else {
            return nil
        }
        
        var index = 0
        for column in layout.columns {
            if column.minY < supplementaryColumn.minY {
                index += 1
            } else if column.minX < supplementaryColumn.minX {
                index += 1
            } else {
                break
            }
        }
        
        return index
    }
}

// MARK: - Private
extension TagsView {
    
    func setupView() {
    }
    
    func newTagView(for index: Int, withReuseIdentifier reuseIdentifier: String) -> TagView {
        let tagView = tagViewNibs[reuseIdentifier]?.instantiate(withOwner: nil, options: nil).first as? TagView ?? TagView()
        tagView.translatesAutoresizingMaskIntoConstraints = false
        tagView.reuseIdentifier = reuseIdentifier
        tagView.tag = index
        insertSubview(tagView, at: index)
        
        return tagView
    }
    
    func newSupplementaryTagView() -> SupplementaryTagView? {
        guard let supplementaryTagView = supplementaryTagViewNib?.instantiate(withOwner: nil, options: nil).first as? SupplementaryTagView else { return nil }
        supplementaryTagView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(supplementaryTagView)
        
        return supplementaryTagView
    }
    
    func selectTag(tagView: TagView, isEvent: Bool = false) {
        if allowsMultipleSelection {
            if isEvent {
                tagView.isSelected = !tagView.isSelected
            } else {
                tagView.isSelected = true
            }
        } else {
            if !tagView.isSelected {
                if let selectedTagView = tagViews.filter({ $0.isSelected }).first {
                    selectedTagView.isSelected = false
                }
            }
            tagView.isSelected = true
        }
    }
    
    func tagView(at index: Int, withReuseIdentifier reuseIdentifier: String) -> TagView? {
        if let tagView = tagViews.first(where: { $0.tag == index }), tagView.reuseIdentifier == reuseIdentifier {
            return tagView
        }
        
        if let tagView = tagViews.first(where: { $0.reuseIdentifier == reuseIdentifier && $0.tag == unassignedTag }) {
            tagView.tag = index
            return tagView
        }
        
        return nil
    }
}

// MARK: - Event handle
extension TagsView {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let view = touches.first?.view as? BaseTagView {
            view.isHighlighted = true
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let view = touch.view as? BaseTagView {
            let point = touch.location(in: view)
            view.isHighlighted = view.bounds.contains(point)
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let view = touch.view as? BaseTagView {
            let point = touch.location(in: view)
            
            view.isHighlighted = false
            if view.bounds.contains(point) {
                if let tagView = view as? TagView, let index = index(for: tagView) {
                    selectTag(tagView: tagView, isEvent: true)
                    delegate?.tagsView(self, didSelectItemAt: index)
                }
                if let _ = view as? SupplementaryTagView {
                    view.isSelected = !view.isSelected
                    delegate?.didSelectSupplementaryItem(self)
                }
            }
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let view = touches.first?.view as? BaseTagView {
            view.isHighlighted = false
        }
    }
}

// MARK: - Recycle views
extension TagsView {
    open func dequeueReusableTagView(for index: Int, withReuseIdentifier reuseIdentifier: String = "default") -> TagView {
        if let tagView = tagView(at: index, withReuseIdentifier: reuseIdentifier) {
            insertSubview(tagView, at: index)
            return tagView
        }
        
        return newTagView(for: index, withReuseIdentifier: reuseIdentifier)
    }
    
    open func dequeueReusableSupplementaryTagView() -> SupplementaryTagView? {
        if let supplementaryTagView = supplementaryTagView {
            return supplementaryTagView
        }
        
        return newSupplementaryTagView()
    }
}
