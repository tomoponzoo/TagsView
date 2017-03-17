//
//  TagsViewLayout.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/03/08.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit

// Basic struct / enum
public struct TagsViewSpacer {
    public let vertical: CGFloat
    public let horizontal: CGFloat
    
    public static var zero: TagsViewSpacer {
        return TagsViewSpacer(vertical: 0, horizontal: 0)
    }
    
    public init(vertical: CGFloat, horizontal: CGFloat) {
        self.vertical = vertical
        self.horizontal = horizontal
    }
}

public enum TagsViewRows {
    case infinite
    case rows(Int)
}

public enum TagsViewAlignment {
    case left, right, center
}

// Layout delegate
public protocol TagsViewLayoutDelegate: class {
    func numberOfRowsInTagsView(_ tagsView: TagsView, layout: TagsViewLayout) -> TagsViewRows
    func numberOfTagsInTagsView(_ tagsView: TagsView, layout: TagsViewLayout) -> Int
    func alignmentInTagsView(_ tagsView: TagsView, layout: TagsViewLayout) -> TagsViewAlignment
    func paddingInTagsView(_ tagsView: TagsView, layout: TagsViewLayout) -> UIEdgeInsets
    func spacerInTagsView(_ tagsView: TagsView, layout: TagsViewLayout) -> TagsViewSpacer
    func isVisibleSupplymentaryTagViewInTagsView(_ tagsView: TagsView, layout: TagsViewLayout, rows: TagsViewRows, row: Int, hasNextRow: Bool) -> Bool
}

// Layout store
public protocol TagsViewLayoutStore {
    var layout: TagsViewLayout? { get set }
}

// Layout implement
open class TagsViewLayout {
    public private(set) var layout: TagsViewRowsLayout?
    public var padding: UIEdgeInsets = .zero
    
    public weak var tagsView: TagsView?
    public weak var delegate: TagsViewLayoutDelegate?
    
    public var tagsViewSize: CGSize?
    
    public var isInvalidLayout: Bool {
        return layout == nil
    }
    
    public init() {
    }
    
    open func calculate(width: CGFloat) -> CGSize {
        guard let tagsView = tagsView else { return .zero }
        
        let numberOfRows = delegate?.numberOfRowsInTagsView(tagsView, layout: self) ?? .infinite
        let numberOfTags = delegate?.numberOfTagsInTagsView(tagsView, layout: self) ?? 0
        let padding = delegate?.paddingInTagsView(tagsView, layout: self) ?? .zero
        let spacer = delegate?.spacerInTagsView(tagsView, layout: self) ?? .zero
        let alignment = delegate?.alignmentInTagsView(tagsView, layout: self) ?? .left
        
        let tagViews = (0 ..< numberOfTags).flatMap { (index) -> TagView? in
            return tagsView.dataSource?.tagsView(tagsView, viewForIndexAt: index)
        }
        
        let supplymentaryTagView = tagsView.dataSource?.supplymentaryTagViewInTagsView(tagsView)
        
        let layoutWidth = width - padding.left - padding.right
        let tagViewSizes = tagViews.map { $0.intrinsicContentSize }
        let supplymentaryTagViewSize = supplymentaryTagView?.intrinsicContentSize
        
        let layout = TagsViewRowsLayout(width: layoutWidth, rows: numberOfRows, spacer: spacer, alignment: alignment)
        layout.parentLayout = self
        layout.calculate(tagViewSizes: tagViewSizes, supplymentaryTagViewSize: supplymentaryTagViewSize)
        
        let size = layout.size
        let tagsViewSize = CGSize(width: padding.left + size.width + padding.right, height: padding.top + size.height + padding.bottom)
        
        self.tagsViewSize = tagsViewSize
        self.layout = layout
        self.padding = padding
        
        return tagsViewSize
    }
    
    public func invalidateLayout() {
        tagsViewSize = nil
        layout = nil
    }
}

// MARK: Private
extension TagsViewLayout {
    
    fileprivate func isVisibleSupplymentaryTagView(rows: TagsViewRows, row: Int, hasNextRow: Bool) -> Bool {
        guard let tagsView = tagsView else { return true }
        return delegate?.isVisibleSupplymentaryTagViewInTagsView(tagsView, layout: self, rows: rows, row: row, hasNextRow: hasNextRow) ?? true
    }
}

public class TagsViewRowsLayout {
    fileprivate let width: CGFloat
    fileprivate let rows: TagsViewRows
    fileprivate let spacer: TagsViewSpacer
    fileprivate let alignment: TagsViewAlignment
    
    fileprivate var layouts = [TagsViewColumnsLayout]()
    
    fileprivate weak var parentLayout: TagsViewLayout?
    
    public var size: CGSize {
        guard let layout = layouts.last else { return .zero }
        return CGSize(width: layout.frame.width, height: layout.frame.maxY)
    }
    
    public var columns: [CGRect] {
        return layouts.flatMap { $0.alignedColumns(self.alignment) }
    }
    
    public var supplymentaryColumn: CGRect? {
        return tailLayout?.alignedSupplymentaryColumn(alignment)
    }
    
    public init(width: CGFloat, rows: TagsViewRows, spacer: TagsViewSpacer, alignment: TagsViewAlignment) {
        self.width = width
        self.rows = rows
        self.spacer = spacer
        self.alignment = alignment
    }
    
    public func calculate(tagViewSizes: [CGSize], supplymentaryTagViewSize: CGSize?) {
        let h = tagViewSizes.reduce(supplymentaryTagViewSize?.height ?? 0) { max($0, $1.height) }
        
        let frame = CGRect(x: 0, y: 0, width: width, height: h)
        let layout = TagsViewColumnsLayout(frame: frame, spacer: spacer, index: 0, endIndex: endIndex)
        layout.parentLayout = self
        
        _ = tagViewSizes.reduce(layout) { (layout, size) -> TagsViewColumnsLayout in
            return layout.push(size: size)
        }
        
        layouts = [TagsViewColumnsLayout](layout)
        
        tailLayout?.set(wishSupplymentaryTagViewSize: supplymentaryTagViewSize)
    }
}

extension TagsViewRowsLayout {
    
    fileprivate var tailLayout: TagsViewColumnsLayout? {
        if let layout = layouts.filter({ $0.isLimited }).first {
            return layout
        } else {
            return layouts.last
        }
    }
    
    fileprivate var isLimited: Bool {
        if case let .rows(num) = rows {
            return layouts.count >= num
        } else {
            return false
        }
    }
    
    fileprivate var endIndex: Int? {
        if case let .rows(num) = rows {
            return num - 1
        } else {
            return nil
        }
    }
    
    fileprivate func isVisibleSupplymentaryTagView(row: Int, hasNextRow: Bool) -> Bool {
        return parentLayout?.isVisibleSupplymentaryTagView(rows: rows, row: row, hasNextRow: hasNextRow) ?? true
    }
}

public class TagsViewColumnsLayout {
    public var columns = [CGRect]()
    public var supplymentaryColumn: CGRect?
    
    public let frame: CGRect
    private let spacer: TagsViewSpacer
    private let index: Int
    private let endIndex: Int?
    
    private var x = CGFloat(0)
    
    fileprivate weak var parentLayout: TagsViewRowsLayout?
    fileprivate var nextLayout: TagsViewColumnsLayout?
    
    var isLimited: Bool {
        guard let endIndex = endIndex else { return false }
        return index == endIndex
    }
    
    var isOutOfLimited: Bool {
        guard let endIndex = endIndex else { return false }
        return index > endIndex
    }
    
    public init(frame: CGRect, spacer: TagsViewSpacer, index: Int, endIndex: Int?) {
        self.frame = frame
        self.spacer = spacer
        self.index = index
        self.endIndex = endIndex
        
        self.x = frame.minX
    }
    
    public func push(size: CGSize) -> TagsViewColumnsLayout {
        if columns.isEmpty {
            // 要素なし
            if size.width <= frame.width {
                // 収まる
                columns.append(CGRect(x: x, y: frame.minY, width: size.width, height: frame.height))
                x += size.width
                return self
                
            } else {
                // 収まらない (タグサイズをフレーム幅にリサイズ)
                columns.append(CGRect(x: x, y: frame.minY, width: frame.width, height: frame.height))
                
                let nextFrame = CGRect(x: frame.minX, y: frame.maxY + spacer.vertical, width: frame.width, height: frame.height)
                let nextLayout = TagsViewColumnsLayout(frame: nextFrame, spacer: spacer, index: index + 1, endIndex: endIndex)
                nextLayout.parentLayout = parentLayout
                self.nextLayout = nextLayout
                
                return nextLayout
            }
            
        } else {
            // 要素あり
            if x + size.width <= frame.width {
                // 収まる
                x += spacer.horizontal

                columns.append(CGRect(x: x, y: frame.minY, width: size.width, height: frame.height))
                x += size.width
                return self
                
            } else {
                // 収まらない (次の行にタグを配置する)
                let nextFrame = CGRect(x: frame.minX, y: frame.maxY + spacer.vertical, width: frame.width, height: frame.height)
                let nextLayout = TagsViewColumnsLayout(frame: nextFrame, spacer: spacer, index: index + 1, endIndex: endIndex)
                nextLayout.parentLayout = parentLayout
                self.nextLayout = nextLayout
                
                return nextLayout.push(size: size)
            }
        }
    }
    
    public func pop() -> CGRect? {
        guard let column = columns.popLast() else { return nil }
        x -= column.width
        
        if !columns.isEmpty {
            x -= spacer.horizontal
        }
        
        return column
    }
    
    public func set(wishSupplymentaryTagViewSize size: CGSize?) {
        guard let size = size else { return }
        
        let isVisible = parentLayout?.isVisibleSupplymentaryTagView(row: index, hasNextRow: nextLayout != nil) ?? true
        
        var column: CGRect?
        while (x + spacer.horizontal + size.width > frame.width) && isVisible {
            column = pop()
        }
        
        if let _ = column, columns.isEmpty {
            let newFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width - spacer.horizontal - size.width, height: frame.height)
            columns.append(newFrame)
            
            x += newFrame.width
        }
        
        if isVisible {
            x += spacer.horizontal
            x += size.width
        
            supplymentaryColumn = CGRect(x: x - size.width, y: frame.minY, width: size.width, height: frame.height)
        }
    }
    
    public func alignedColumns(_ alignment: TagsViewAlignment) -> [CGRect] {
        guard let tailColumn = columns.last, alignment != .left else { return columns }
        
        let offset: CGFloat
        let div: CGFloat = alignment == .center ? 2.0 : 1.0
        if let supplymentaryColumn = supplymentaryColumn {
            offset = (frame.width - supplymentaryColumn.maxX) / div
        } else {
            offset = (frame.width - tailColumn.maxX) / div
        }
        
        return columns.map { CGRect(x: $0.minX + offset, y: $0.minY, width: $0.width, height: $0.height) }
    }
    
    public func alignedSupplymentaryColumn(_ alignment: TagsViewAlignment) -> CGRect? {
        guard let supplymentaryColumn = supplymentaryColumn, alignment != .left else { return self.supplymentaryColumn }
        
        let div: CGFloat = alignment == .center ? 2.0 : 1.0
        let offset = (frame.width - supplymentaryColumn.maxX) / div
        return CGRect(
            x: supplymentaryColumn.minX + offset,
            y: supplymentaryColumn.minY,
            width: supplymentaryColumn.width,
            height: supplymentaryColumn.height
        )
    }
}

extension TagsViewColumnsLayout: Sequence {
    
    public func makeIterator() -> TagsViewColumnsLayoutIterator {
        return TagsViewColumnsLayoutIterator(self)
    }
}

public struct TagsViewColumnsLayoutIterator: IteratorProtocol {
    public typealias Element = TagsViewColumnsLayout
    
    var currentLayout: TagsViewColumnsLayout?
    
    public init(_ layout: TagsViewColumnsLayout) {
        self.currentLayout = layout
    }
    
    public mutating func next() -> TagsViewColumnsLayout? {
        guard let currentLayout = currentLayout else { return nil }
        
        if let nextLayout = currentLayout.nextLayout, !nextLayout.isOutOfLimited {
            self.currentLayout = currentLayout.nextLayout
        } else {
            self.currentLayout = nil
        }
        
        return currentLayout
    }
}
