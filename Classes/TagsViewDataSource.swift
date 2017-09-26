//
//  TagsViewDataSource.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/09/25.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import Foundation

public protocol TagsViewDataSource: class {
    func numberOfTags(in tagsView: TagsView) -> Int
    
    func numberOfRows(in tagsView: TagsView) -> Rows
    func alignment(in tagsView: TagsView) -> Alignment
    func padding(in tagsView: TagsView) -> UIEdgeInsets
    func spacer(in tagsView: TagsView) -> Spacer
    func isVisibleSupplymentaryTagView(in tagsView: TagsView, rows: Rows, row: Int, hasNextRow: Bool) -> Bool
    func tagsView(_ tagsView: TagsView, viewForIndexAt index: Int) -> TagView?
    func supplymentaryTagView(in tagsView: TagsView) -> SupplymentaryTagView?
}

extension TagsViewDataSource {
    public func numberOfRows(in tagsView: TagsView) -> Rows { return .infinite }
    public func alignment(in tagsView: TagsView) -> Alignment { return .left }
    public func padding(in tagsView: TagsView) -> UIEdgeInsets { return .zero }
    public func spacer(in tagsView: TagsView) -> Spacer { return .init(vertical: 8, horizontal: 8) }
    public func isVisibleSupplymentaryTagView(in tagsView: TagsView, rows: Rows, row: Int, hasNextRow: Bool) -> Bool { return false }
    public func tagsView(_ tagsView: TagsView, viewForIndexAt index: Int) -> TagView? { return nil }
    public func supplymentaryTagView(in tagsView: TagsView) -> SupplymentaryTagView? { return nil }
}
