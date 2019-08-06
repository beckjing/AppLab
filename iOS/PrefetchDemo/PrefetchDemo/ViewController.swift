//
//  ViewController.swift
//  PrefetchDemo
//
//  Created by yuecheng on 2019/8/1.
//  Copyright © 2019 NanoSparrow. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10000
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UICollectionViewCell.classForCoder()), for: indexPath);
        
        collectionViewCell.backgroundColor = UIColor.red
        
        return collectionViewCell;
    }
    
    
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: NSStringFromClass(UICollectionViewCell.classForCoder()))
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.prefetchDataSource = self
        self.collectionView.reloadData()
        // Do any additional setup after loading the view.
    }


}

