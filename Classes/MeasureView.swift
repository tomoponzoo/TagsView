//
//  MeasureView.swift
//  TagsView
//
//  Created by Tomoki Koga on 2017/09/25.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit

class MeasureView: UILabel {
    private var _preferedMaxLayoutWidth: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override var intrinsicContentSize: CGSize {
        if preferredMaxLayoutWidth > 0 && _preferedMaxLayoutWidth != preferredMaxLayoutWidth {
            _preferedMaxLayoutWidth = preferredMaxLayoutWidth
            superview?.superview?.invalidateIntrinsicContentSize()
        }
        
        let size = super.intrinsicContentSize
        return size
    }
    
    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        numberOfLines = 0
    }
    
    func attach(view: UIView) {
        view.addSubview(self)
        
        view.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    }
}
