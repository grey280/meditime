//
//  CircleButton.swift
//  meditation
//
//  Created by Grey Patterson on 11/5/18.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import UIKit

@IBDesignable class CircleButton: UIButton {
    override func prepareForInterfaceBuilder() {
        customConfig()
    }
    
    @IBInspectable var inset: CGFloat = 3.0{
        didSet{
            customConfig()
        }
    }
    
    func customConfig(){
        layer.cornerRadius = bounds.size.width / 2
        clipsToBounds = true
        imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customConfig()
    }
    
}
