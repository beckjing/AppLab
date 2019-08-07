//
//  ViewController.swift
//  SocketDemo
//
//  Created by yuecheng on 2019/8/7.
//  Copyright © 2019 NanoSparrow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var streamManager = NASStreamManager.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.streamManager.connectWithServer(host: "192.168.2.1", port: 65432)
        // Do any additional setup after loading the view.
    }


}

