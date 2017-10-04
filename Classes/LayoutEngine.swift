//
//  TagsViewLayoutEngine.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/09/25.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import Foundation

class LayoutEngine {
    let tagsView: TagsView
    let preferredMaxLayoutWidth: CGFloat
    
    init(tagsView: TagsView, preferredMaxLayoutWidth: CGFloat) {
        self.tagsView = tagsView
        self.preferredMaxLayoutWidth = preferredMaxLayoutWidth
    }
    
    func layout(identifier: String? = nil, partition: String? = "defaults") -> Layout {
        if
            let identifier = identifier,
            let partition = partition,
            let layout = LayoutCache.shared.getLayout(identifier: makeIdentifier(identifier, partition: partition)) {
            return layout
        }
        
        let rowsLayout = RowsLayout(tagsView: tagsView, preferredMaxLayoutWidth: preferredMaxLayoutWidth)
        rowsLayout.layout()
        
        let layout = Layout(layout: rowsLayout)
        if let identifier = identifier, let partition = partition, preferredMaxLayoutWidth > 0 {
            LayoutCache.shared.setLayout(layout, identifier: makeIdentifier(identifier, partition: partition))
        }
        
        return layout
    }
    
    func makeIdentifier(_ identifier: String, partition: String) -> String {
        return "\(partition)#\(identifier)"
    }
}

class RowsLayout {
    let tagsView: TagsView
    let preferredMaxLayoutWidth: CGFloat
    
    var layouts = [ColumnsLayout]()
    
    var size: CGSize {
        guard let layout = layouts.last else { return .zero }
        return CGSize(width: layout.frame.width + tagsView.padding.left + tagsView.padding.right, height: layout.frame.maxY + tagsView.padding.top + tagsView.padding.bottom)
    }
    
    var columns: [CGRect] {
        return layouts.flatMap { $0.alignedColumns(self.tagsView.layoutProperties.alignment) }
    }
    
    var supplementaryColumn: CGRect? {
        return tailLayout?.alignedSupplementaryColumn(tagsView.layoutProperties.alignment)
    }
    
    var tailLayout: ColumnsLayout? {
        if let layout = layouts.filter({ $0.isLimited }).first {
            return layout
        } else {
            return layouts.last
        }
    }
    
    init(tagsView: TagsView, preferredMaxLayoutWidth: CGFloat) {
        self.tagsView = tagsView
        self.preferredMaxLayoutWidth = preferredMaxLayoutWidth - tagsView.padding.left - tagsView.padding.right
    }
    
    func layout() {
        let tagViews = (0..<tagsView.layoutProperties.numberOfTags).flatMap { (index) -> TagView? in
            return tagsView.dataSource?.tagsView(self.tagsView, viewForIndexAt: index)
        }
        let tagViewSizes = tagViews.map { $0.intrinsicContentSize }
        
        let supplementaryTagView = tagsView.dataSource?.supplementaryTagView(in: tagsView)
        let supplementaryTagViewSize = supplementaryTagView?.intrinsicContentSize
        
        let h = tagViewSizes.reduce(supplementaryTagViewSize?.height ?? 0) { max($0, $1.height) }
        let frame = CGRect(x: 0, y: 0, width: preferredMaxLayoutWidth, height: h)
        let layout = ColumnsLayout(tagsView: tagsView, frame: frame, index: 0)
        
        _ = tagViewSizes.reduce(layout) { (layout, size) -> ColumnsLayout in
            return layout.push(size: size)
        }
        
        layouts = [ColumnsLayout](layout)
        
        tailLayout?.set(wishSupplementaryTagViewSize: supplementaryTagViewSize)
    }
}

class ColumnsLayout {
    let tagsView: TagsView
    let frame: CGRect
    let index: Int
    
    var columns = [CGRect]()
    var supplementaryColumn: CGRect?
    var x: CGFloat
    
    var nextLayout: ColumnsLayout?
    
    var spacer: Spacer {
        return tagsView.layoutProperties.spacer
    }
    
    var endIndex: Int? {
        if case let .rows(num) = tagsView.layoutProperties.numberOfRows {
            return num - 1
        } else {
            return nil
        }
    }
    
    var isLimited: Bool {
        guard let endIndex = endIndex else { return false }
        return index == endIndex
    }
    
    var isOutOfLimited: Bool {
        guard let endIndex = endIndex else { return false }
        return index > endIndex
    }
    
    init(tagsView: TagsView, frame: CGRect, index: Int) {
        self.tagsView = tagsView
        self.frame = frame
        self.index = index
        self.x = frame.minX
    }
    
    func push(size: CGSize) -> ColumnsLayout {
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
                let nextLayout = ColumnsLayout(tagsView: tagsView, frame: nextFrame, index: index + 1)
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
                let nextLayout = ColumnsLayout(tagsView: tagsView, frame: nextFrame, index: index + 1)
                self.nextLayout = nextLayout
                
                return nextLayout.push(size: size)
            }
        }
    }
    
    func pop() -> CGRect? {
        guard let column = columns.popLast() else { return nil }
        x -= column.width
        
        if !columns.isEmpty {
            x -= spacer.horizontal
        }
        
        return column
    }
    
    func set(wishSupplementaryTagViewSize size: CGSize?) {
        guard let size = size else { return }
        
        let isVisible = tagsView.dataSource?.isVisibleSupplementaryTagView(
            in: tagsView,
            rows: tagsView.numberOfRows,
            row: index,
            hasNextRow: nextLayout != nil
        ) ?? false
        
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
            
            supplementaryColumn = CGRect(x: x - size.width, y: frame.minY, width: size.width, height: frame.height)
        }
    }
    
    func alignedColumns(_ alignment: Alignment) -> [CGRect] {
        guard let tailColumn = columns.last, alignment != .left else {
            return columns.map {
                CGRect(
                    x: $0.minX + tagsView.padding.left,
                    y: $0.minY + tagsView.padding.top,
                    width: $0.width,
                    height: $0.height
                )
            }
        }
        
        let offset: CGFloat
        let div: CGFloat = alignment == .center ? 2.0 : 1.0
        if let supplementaryColumn = supplementaryColumn {
            offset = (frame.width - supplementaryColumn.maxX) / div
        } else {
            offset = (frame.width - tailColumn.maxX) / div
        }
        
        return columns.map {
            CGRect(
                x: $0.minX + offset + tagsView.padding.left,
                y: $0.minY + tagsView.padding.top,
                width: $0.width,
                height: $0.height
            )
        }
    }
    
    func alignedSupplementaryColumn(_ alignment: Alignment) -> CGRect? {
        guard let supplementaryColumn = supplementaryColumn, alignment != .left else {
            return self.supplementaryColumn.map {
                CGRect(
                    x: $0.minX + tagsView.padding.left,
                    y: $0.minY + tagsView.padding.top,
                    width: $0.width,
                    height: $0.height
                )
            }
        }
        
        let div: CGFloat = alignment == .center ? 2.0 : 1.0
        let offset = (frame.width - supplementaryColumn.maxX) / div
        return CGRect(
            x: supplementaryColumn.minX + offset + tagsView.padding.left,
            y: supplementaryColumn.minY + tagsView.padding.top,
            width: supplementaryColumn.width,
            height: supplementaryColumn.height
        )
    }
}

extension ColumnsLayout: Sequence {
    
    func makeIterator() -> ColumnsLayoutIterator {
        return ColumnsLayoutIterator(self)
    }
}

struct ColumnsLayoutIterator: IteratorProtocol {
    typealias Element = ColumnsLayout
    
    var currentLayout: ColumnsLayout?
    
    init(_ layout: ColumnsLayout) {
        self.currentLayout = layout
    }
    
    mutating func next() -> ColumnsLayout? {
        guard let currentLayout = currentLayout else { return nil }
        
        if let nextLayout = currentLayout.nextLayout, !nextLayout.isOutOfLimited {
            self.currentLayout = currentLayout.nextLayout
        } else {
            self.currentLayout = nil
        }
        
        return currentLayout
    }
}

struct LayoutProperties {
    let numberOfTags: Int
    let numberOfRows: Rows
    let alignment: Alignment
    let padding: UIEdgeInsets
    let spacer: Spacer
    
    init(numberOfTags: Int = 0, numberOfRows: Rows = .infinite, alignment: Alignment = .left, padding: UIEdgeInsets = .zero, spacer: Spacer = .zero) {
        self.numberOfTags = numberOfTags
        self.numberOfRows = numberOfRows
        self.alignment = alignment
        self.padding = padding
        self.spacer = spacer
    }
}
