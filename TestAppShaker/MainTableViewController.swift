//
//  MainTableViewController.swift
//  TestAppShaker
//
//  Created by Andrey Egorov on 1/27/16.
//  Copyright © 2016 Andrey Egorov. All rights reserved.
//

import UIKit
import SwiftyJSON
import Starscream

class MainTableViewController: UITableViewController, WebSocketDelegate {
    
    var socket = WebSocket(url: NSURL(string: "ws://54.154.96.23:8082/")!)
    var dataArray: [JSON] = []
    let cellIdentifier = "ImageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.delegate = self
        socket.connect()
    }
    
    // MARK: Websocket Delegate Methods.
    
    func websocketDidConnect(ws: WebSocket) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        let data: NSData = text.dataUsingEncoding(NSUTF8StringEncoding)!
        var urlString: String?
        var jsonData: JSON?
        
        do {
            let jsonObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
            urlString = (jsonObject as! NSDictionary)["url"] as? String
        } catch _ {
            print("Что-то пошло не так")
            return
        }
        
        let url = NSURL(string: urlString!)
        let request = NSURLRequest(URL: url!)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if let e = error {
                print("Ошибка: \(e.localizedDescription)")
            } else {
                jsonData = JSON(data: data!)
                let jsonArray = jsonData!.arrayValue
                // сортируем по time
                self.dataArray = jsonArray.sort { $0["time"] < $1["time"] }
                self.reloadTableViewContent()
            }
        }
        task.resume()
        
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length)")
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ImageCell
        let item: JSON? = dataArray[indexPath.row]
        
        cell.mainImage.image = nil
        
        // загружаем главную картинку
        if let url = item?["url"] {
            cell.mainImage.layer.cornerRadius = cell.mainImage.frame.size.width / 2
            cell.mainImage.clipsToBounds = true
            cell.mainImage.imageFromUrl(url.rawString()!)
        }
        
        // добавляем название
        if let name = item?["name"] {
            cell.imageTitle.text = name.rawString()!
        }
        
        // пишем количество картинок в images и отдаем в метод UICollectionViewDataSourceDelegate
        if let items = item?["images"] {
            let count = items.arrayValue.count
            cell.imagesCount.text = String(count)
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        }
        
        return cell
    }
    
    // перезагружаем таблицу
    func reloadTableViewContent() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
        })
    }
    
    // segue для перехода во ViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "imageDetailSegue" {
            
            let imageDetailViewController = segue.destinationViewController as! ImageDetailViewController
            
            if let selectedImageCell = sender as? ImageCell {
                let indexPath = tableView.indexPathForCell(selectedImageCell)!
                let selectedProject = dataArray[indexPath.row]
                imageDetailViewController.data = selectedProject
            }
        }
    }

}

// Метод для получения картинки по URL
extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
  
                if let e = error {
                    print("Ошибка: \(e.localizedDescription)")
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.image = UIImage(data: data!)
                    })
                    
                }
            }
            task.resume()
        }
    }
}

// Delegate methods для uicollectionview
extension MainTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let item: JSON? = dataArray[collectionView.tag]
        
        if let images = item?["images"] {
            return images.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imagesCollectionCell", forIndexPath: indexPath) as! ImagesCollectionViewCell
        let item: JSON? = dataArray[collectionView.tag]

        if let items = item?["images"] {
            let url = items[indexPath.item]
            cell.imageCollectionView.layer.cornerRadius = cell.imageCollectionView.frame.size.width / 2
            cell.imageCollectionView.clipsToBounds = true
            cell.imageCollectionView.imageFromUrl(url.rawString()!)
        }
        
        return cell
    }

}