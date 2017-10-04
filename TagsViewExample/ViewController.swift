//
//  ViewController.swift
//  TagsViewExample
//
//  Created by Tomoki Koga on 2017/02/10.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit
import TagsView

class ViewModel {
    struct TagData {
        let string: String
        let reuseIdentifier: String?
    }
    
    let tagDatas: [TagData]
    
    var rows: Rows = .rows(1)

    var identifier: String {
        switch rows {
        case .infinite:
            return "\(tagDatas.first?.string ?? ""):OPN"
        default:
            return "\(tagDatas.first?.string ?? ""):CLS"
        }
    }
    
    init() {
        let endIndex = arc4random_uniform(20) + 1
        self.tagDatas = (0 ..< endIndex).map { (n) -> TagData in
            let isTag1 = arc4random_uniform(UInt32(n)) % 2 == 0
            
            let num: Int
            if n % 11 == 0 {
                num = 10000000
            } else if n % 7 == 0 {
                num = 1000000000
            } else if n % 5 == 0 {
                num = 10
            } else if n % 3 == 0 {
                num = 1000
            } else {
                num = 100000
            }
            
            return TagData(
                string: "タグ\(arc4random_uniform(UInt32(num)))",
                reuseIdentifier: isTag1 ? "TagViewEx" : "TagViewEx2"
            )
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 44
        }
    }

//    fileprivate let viewModels = [ViewModel()]
    fileprivate let viewModels = [ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel(), ViewModel()]
    
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
        cell.tagsView.preferredMaxLayoutWidth = tableView.bounds.width
        cell.updateCell(viewModel: viewModels[indexPath.row])
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? TableViewCell)?.checkSupplementaryIndex()
    }
}

extension ViewController: TableViewCellDelegate {
    internal func tableViewCell(_ cell: TableViewCell, tagsView: TagsView, didSelectItemAt index: Int) {
    }

    internal func tableViewCell(_ cell: TableViewCell, didSelectSupplementaryItemInTagsView tagsView: TagsView) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        switch viewModels[indexPath.row].rows {
        case .infinite:
            viewModels[indexPath.row].rows = .rows(1)
        case .rows(_):
            viewModels[indexPath.row].rows = .infinite
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
