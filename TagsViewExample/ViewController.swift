//
//  ViewController.swift
//  TagsViewExample
//
//  Created by Tomoki Koga on 2017/02/10.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit
import TagsView

class ViewModel: TagsViewLayoutStore {
    let strings: [String]
    
    var layout: TagsViewLayout?
    var rows: TagsViewRows = .rows(1)
    
    init() {
        self.strings = (0 ..< arc4random_uniform(20) + 1).map { _ in "タグ\(arc4random_uniform(10000000))" }
        self.layout = TagsViewLayout()
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 44
        }
    }

    fileprivate let viewModels = [ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        cell.delegate = self
        cell.updateCell(viewModel: viewModels[indexPath.row])
        return cell
    }
}

extension ViewController: TableViewCellDelegate {
    internal func tableViewCell(_ cell: TableViewCell, tagsView: TagsView, didSelectItemAt index: Int) {
    }

    internal func tableViewCell(_ cell: TableViewCell, didSelectSupplymentaryItemInTagsView tagsView: TagsView) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        switch viewModels[indexPath.row].rows {
        case .infinite:
            viewModels[indexPath.row].rows = .rows(1)
        case .rows(_):
            viewModels[indexPath.row].rows = .infinite
        }
        
        viewModels[indexPath.row].layout?.invalidateLayout()
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
