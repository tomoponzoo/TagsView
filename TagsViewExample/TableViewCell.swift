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
    func tableViewCell(_ cell: TableViewCell, didSelectSupplementaryItemInTagsView tagsView: TagsView)
}

class TableViewCell: UITableViewCell {
    @IBOutlet weak var tagsView: TagsView! {
        didSet {
            tagsView.registerTagView(nib: UINib(nibName: "TagViewEx", bundle: nil), forReuseIdentifier: "TagViewEx")
            tagsView.registerTagView(nib: UINib(nibName: "TagViewEx2", bundle: nil), forReuseIdentifier: "TagViewEx2")
            tagsView.registerSupplementaryTagView(nib: UINib(nibName: "SupplementaryTagViewEx", bundle: nil))
            tagsView.dataSource = self
            tagsView.delegate = self
            tagsView.allowsMultipleSelection = true
        }
    }
    
    weak var delegate: TableViewCellDelegate?
    var viewModel: ViewModel?
    
    func updateCell(viewModel: ViewModel) {
        self.viewModel = viewModel
        tagsView.reloadData()
    }
    
    func checkSupplementaryIndex() {
    }
}

extension TableViewCell: TagsViewDataSource {
    func numberOfRows(in tagsView: TagsView) -> Rows {
        return viewModel?.rows ?? .infinite
    }
    
    func numberOfTags(in tagsView: TagsView) -> Int {
        return viewModel?.tagDatas.count ?? 0
    }
    
    func alignment(in tagsView: TagsView) -> Alignment {
        return .left
    }
    
    func padding(in tagsView: TagsView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func spacer(in tagsView: TagsView) -> Spacer {
        return Spacer(vertical: 4, horizontal: 4)
    }
    
    func isVisibleSupplementaryTagView(in tagsView: TagsView, rows: Rows, row: Int, hasNextRow: Bool) -> Bool {
        switch rows {
        case .infinite:
            return row > 0
            
        case .rows(_):
            return hasNextRow
        }
    }
   
    func tagsView(_ tagsView: TagsView, viewForIndexAt index: Int) -> TagView? {
        if let reuseIdentifier = viewModel?.tagDatas[index].reuseIdentifier {
            if reuseIdentifier == "TagViewEx" {
                let tagView = tagsView.dequeueReusableTagView(for: index, withReuseIdentifier: reuseIdentifier) as? TagViewEx
                tagView?.string = viewModel!.tagDatas[index].string
                tagView?.label.text = viewModel!.tagDatas[index].string
                return tagView
            } else {
                let tagView = tagsView.dequeueReusableTagView(for: index, withReuseIdentifier: reuseIdentifier) as? TagViewEx2
                tagView?.string = viewModel!.tagDatas[index].string
                tagView?.label.text = viewModel!.tagDatas[index].string
                return tagView
            }
        } else {
            return nil
        }
    }
    
    func supplementaryTagView(in tagsView: TagsView) -> SupplementaryTagView? {
        let supplementaryTagView = tagsView.dequeueReusableSupplementaryTagView() as? SupplementaryTagViewEx
        return supplementaryTagView
    }
}

extension TableViewCell: TagsViewDelegate {
    func tagsView(_ tagsView: TagsView, didSelectItemAt index: Int) {
        print("Select:\(index)")
        delegate?.tableViewCell(self, tagsView: tagsView, didSelectItemAt: index)
    }
    
    func didSelectSupplementaryItem(_ tagsView: TagsView) {
        print("Supplementary select")
        delegate?.tableViewCell(self, didSelectSupplementaryItemInTagsView: tagsView)
    }
}
