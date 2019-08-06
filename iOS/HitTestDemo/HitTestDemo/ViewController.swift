//
//  ViewController.swift
//  HitTestDemo
//
//  Created by yuecheng on 2019/8/5.
//  Copyright © 2019 NanoSparrow. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    var hitTestView : HitTestView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hitTestView = HitTestView(frame: CGRect.zero)
        self.view.addSubview(self.hitTestView!)
        self.hitTestView?.snp.makeConstraints({ (make) -> Void in
            make.edges.equalTo(self.view)
        })
        // Do any additional setup after loading the view.
    }


}

