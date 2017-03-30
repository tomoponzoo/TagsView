//
//  TagsView.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/03/08.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit

public protocol TagsViewDataSource: class {
    func tagsView(_ tagsView: TagsView, viewForIndexAt index: Int) -> TagView?
    func supplymentaryTagViewInTagsView(_ tagsView: TagsView) -> SupplymentaryTagView?
}

public protocol TagsViewDelegate: class {
    func tagsView(_ tagsView: TagsView, didSelectItemAt index: Int)
    func didSelectSupplymentaryItem(_ tagsView: TagsView)
}

open class TagsView: UIView {
    public weak var dataSource: TagsViewDataSource?
    public weak var delegate: TagsViewDelegate?
    
    public var layout: TagsViewLayout? {
        didSet {
            layout?.tagsView = self
        }
    }
    
    fileprivate var tagViewNib: UINib?
    fileprivate var supplymentaryTagViewNib: UINib?

    fileprivate var containerView: UIView!

    fileprivate var tagViews: [TagView] {
        return containerView.subviews.flatMap { $0 as? TagView }
    }
    
    fileprivate var supplymentaryTagView: SupplymentaryTagView? {
        return containerView.subviews.flatMap { $0 as? SupplymentaryTagView }.first
    }
    
    fileprivate var indexPath: IndexPath?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    open override var intrinsicContentSize: CGSize {
        if let cachedSize = layout?.tagsViewSize {
            return cachedSize
        }
        
        let size = layout?.calculate(width: bounds.width) ?? .zero
        return size
    }
    
    open override func layoutSubviews() {
        guard let padding = self.layout?.padding, let layout = self.layout?.layout else { return }
        
        containerView.frame = CGRect(
            x: padding.left,
            y: padding.top,
            width: layout.size.width,
            height: layout.size.height
        )
        
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
    
    public func registerTagView(nib: UINib?) {
        self.tagViewNib = nib
    }
    
    public func registerSupplymentaryTagView(nib: UINib?) {
        self.supplymentaryTagViewNib = nib
    }
    
    open func reloadData() {
        guard let layout = self.layout else { return }
        
        let numberOfTags = layout.delegate?.numberOfTagsInTagsView(self, layout: layout) ?? 0
        let tagViews = (0 ..< numberOfTags).flatMap { (index) -> TagView? in
            return self.dataSource?.tagsView(self, viewForIndexAt: index)
        }
        
        tagViews.filter {
            $0.superview == nil
            }.forEach {
                self.subviews.first?.addSubview($0)
        }
        
        let supplymentaryTagView = dataSource?.supplymentaryTagViewInTagsView(self)
        if let supplymentaryTagView = supplymentaryTagView, supplymentaryTagView.superview == nil {
            self.subviews.first?.addSubview(supplymentaryTagView)
        }
        
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    open func reloadData(withLayoutStore layoutStore: TagsViewLayoutStore? = nil, layoutDelegate: TagsViewLayoutDelegate? = nil) {
        if let layout = layoutStore?.layout {
            layout.delegate = layoutDelegate
            self.layout = layout
        }
        
        reloadData()
    }
    
    open func selectTag(at index: Int) {
        tagView(at: index)?.isSelected = true
    }
    
    open func deselectTag(at index: Int) {
        tagView(at: index)?.isSelected = false
    }
    
    open func index(for view: TagView) -> Int? {
        return containerView.subviews.index(of: view)
    }
    
    open func tagView(at index: Int) -> TagView? {
        return index < tagViews.count ? tagViews[index] : nil
    }
}

// MARK: Private
extension TagsView {
    
    fileprivate func setupView() {
        let view = UIView(frame: bounds)
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
        
        containerView = view
    }
    
    fileprivate func newTagView() -> TagView {
        let tagView = tagViewNib?.instantiate(withOwner: nil, options: nil).first as? TagView ?? TagView()
        tagView.translatesAutoresizingMaskIntoConstraints = true
        
        return tagView
    }
    
    fileprivate func newSupplymentaryTagView() -> SupplymentaryTagView? {
        guard let supplymentaryTagView = supplymentaryTagViewNib?.instantiate(withOwner: nil, options: nil).first as? SupplymentaryTagView else { return nil }
        supplymentaryTagView.translatesAutoresizingMaskIntoConstraints = true
        
        return supplymentaryTagView
    }
}

// MARK: Event handle
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
                view.isSelected = !view.isSelected
                
                if let tagView = view as? TagView, let index = index(for: tagView) {
                    delegate?.tagsView(self, didSelectItemAt: index)
                }
                if let _ = view as? SupplymentaryTagView {
                    delegate?.didSelectSupplymentaryItem(self)
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

// MARK: Recycle views
extension TagsView {
    open func dequeueReusableTagView(for index: Int) -> TagView {
        if let tagView = tagView(at: index) {
            return tagView
        }
        
        return newTagView()
    }
    
    open func dequeueReusableSupplymentaryTagView() -> SupplymentaryTagView? {
        if let supplymentaryTagView = supplymentaryTagView {
            return supplymentaryTagView
        }
        
        return newSupplymentaryTagView()
    }
}
