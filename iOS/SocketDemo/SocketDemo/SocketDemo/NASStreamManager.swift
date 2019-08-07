//
//  NASStreamManager.swift
//  SocketDemo
//
//  Created by yuecheng on 2019/8/7.
//  Copyright © 2019 NanoSparrow. All rights reserved.
//

import UIKit

class NASStreamManager: NSObject {
    
    lazy var urlSession: URLSession = {
        let urlSession = URLSession.init(configuration: URLSessionConfiguration.default)
        return urlSession
    }()

    
    func connectWithServer(host: String, port: Int) -> Void {
        let task = self.urlSession.streamTask(withHostName: host, port: port)
        task.resume()
        task.write("hello a".data(using: String.Encoding.utf8)!, timeout: 30) { (error) in
            if (error != nil) {
                print(error!)
            }
        }
    }

}
