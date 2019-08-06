//
//  HitTestView.swift
//  HitTestDemo
//
//  Created by yuecheng on 2019/8/5.
//  Copyright © 2019 NanoSparrow. All rights reserved.
//

import UIKit

class HitTestView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        print("hitTest")
        let view = super.hitTest(point, with: event)
        print("return hitTest")
        return view
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        print("pointInside")
        let inside = super.point(inside: point, with: event)
        print("return pointInside")
        return inside
    }

}
