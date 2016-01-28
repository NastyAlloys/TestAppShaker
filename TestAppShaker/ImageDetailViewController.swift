//
//  ViewController.swift
//  TestAppShaker
//
//  Created by Andrey Egorov on 1/27/16.
//  Copyright © 2016 Andrey Egorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class ImageDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var data: JSON?
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var imageCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = nil
        if let url = data?["url"] {
            self.imageView.imageFromUrl(url.rawString()!)
        }
        
        self.titleLabel.text = String(data!["name"])
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.reloadData()
    }
    
    // MARK : UICollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let images = data?["images"] {
            return images.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageDetailCollectionCell", forIndexPath: indexPath) as! ImageDetailCollectionViewCell
        
        if let items = data?["images"] {
            let url = items[indexPath.item]
            cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width / 2
            cell.imageView.clipsToBounds = true
            cell.imageView.imageFromUrl(url.rawString()!)
        }
        
        return cell
    }
}

