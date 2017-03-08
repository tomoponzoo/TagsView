//
//  TableViewCell.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/03/08.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit
import TagsView

protocol TableViewCellDelegate: class {
    func tableViewCell(_ cell: TableViewCell, tagsView: TagsView, didSelectItemAt index: Int)
    func tableViewCell(_ cell: TableViewCell, didSelectSupplymentaryItemInTagsView tagsView: TagsView)
}

class TableViewCell: UITableViewCell {
    @IBOutlet weak var tagsView: TagsView! {
        didSet {
            tagsView.registerTagView(nib: UINib(nibName: "TagViewEx", bundle: nil))
            tagsView.registerSupplymentaryTagView(nib: UINib(nibName: "SupplymentaryTagViewEx", bundle: nil))
            tagsView.dataSource = self
            tagsView.delegate = self
        }
    }
    
    weak var delegate: TableViewCellDelegate?
    var viewModel: ViewModel?
    
    func updateCell(viewModel: ViewModel) {
        self.viewModel = viewModel
        tagsView.reloadData(withLayoutStore: viewModel, layoutDelegate: self)
    }
}

extension TableViewCell: TagsViewLayoutDelegate {
    func numberOfRowsInTagsView(_ tagsView: TagsView, layout: TagsViewLayout) -> TagsViewRows {
        return viewModel?.rows ?? .infinite
    }
    
    func numberOfTagsInTagsView(_ tagsView: TagsView, layout: TagsViewLayout) -> Int {
        return viewModel?.strings.count ?? 0
    }
    
    func alignmentInTagsView(_ tagsView: TagsView, layout: TagsViewLayout) -> TagsViewAlignment {
        return .right
    }
    
    func paddingInTagsView(_ tagsView: TagsView, layout: TagsViewLayout) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func spacerInTagsView(_ tagsView: TagsView, layout: TagsViewLayout) -> TagsViewSpacer {
        return TagsViewSpacer(vertical: 4, horizontal: 4)
    }
    
    func isVisibleSupplymentaryTagViewInTagsView(_ tagsView: TagsView, layout: TagsViewLayout, rows: TagsViewRows, row: Int, hasNextRow: Bool) -> Bool {
        switch rows {
        case .infinite:
            return row > 0
            
        case .rows(_):
            return hasNextRow
        }
    }
}

extension TableViewCell: TagsViewDataSource {
    func tagsView(_ tagsView: TagsView, viewForIndexAt index: Int) -> TagView? {
        let tagView = tagsView.dequeueReusableTagView(for: index) as? TagViewEx
        tagView?.string = viewModel!.strings[index]
        tagView?.label.text = viewModel!.strings[index]
        return tagView ?? TagViewEx()
    }
    
    func supplymentaryTagViewInTagsView(_ tagsView: TagsView) -> SupplymentaryTagView? {
        let supplymentaryTagView = tagsView.dequeueReusableSupplymentaryTagView() as? SupplymentaryTagViewEx
        return supplymentaryTagView
    }
}

extension TableViewCell: TagsViewDelegate {
    func tagsView(_ tagsView: TagsView, didSelectItemAt index: Int) {
        print("Select:\(index)")
        delegate?.tableViewCell(self, tagsView: tagsView, didSelectItemAt: index)
    }
    
    func didSelectSupplymentaryItem(_ tagsView: TagsView) {
        print("Supplymentary select")
        delegate?.tableViewCell(self, didSelectSupplymentaryItemInTagsView: tagsView)
    }
}
