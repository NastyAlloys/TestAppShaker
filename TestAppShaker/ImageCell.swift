//
//  ImageCell.swift
//  TestAppShaker
//
//  Created by Andrey Egorov on 1/28/16.
//  Copyright © 2016 Andrey Egorov. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    
    @IBOutlet weak var imageTitle: UILabel!
    @IBOutlet weak var imagesCount: UILabel!    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // function to set the delegate, datasource, and row number on the collection view
    // D type conforms to both the datasource and delegate protocols
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
            
            collectionView.delegate = dataSourceDelegate
            collectionView.dataSource = dataSourceDelegate
            collectionView.tag = row
            collectionView.reloadData()
    }
    
}
