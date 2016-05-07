//
//  TimeLineTableViewController.swift
//  eZCool
//
//  Created by BinWu on 4/30/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

class SegueData {
    var imageIndex = 0
    var picModels = [WBPictureModel]()
    var sourceImageView =  UIImageView()
}

class TimeLineTableViewController: UITableViewController, CellContentClickedCallback{
    
    let userDefault = UserDefaults()
    
    let dataProcessCenter = DataProcessCenter()
    var prototypeCell :BaseTypeTableViewCell!
    
    let segueData = SegueData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        prototypeCell = tableView.dequeueReusableCellWithIdentifier("baseTypeCell") as! BaseTypeTableViewCell

        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 1000
        
        self.refreshControl?.addTarget(self, action: #selector(TimeLineTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
//        dispatch_async(dispatch_get_main_queue()) {
//            self.getTimeline(1)
//        }
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        self.getTimeline(1)
        
//        self.tableView.reloadData()
//        refreshControl.endRefreshing()
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTimeline(page: Int){
        let urlPath: String = "https://api.weibo.com/2/statuses/home_timeline.json?access_token=\(userDefault.wbtoken!)&page=\(page)"
        let url: NSURL = (NSURL(string: urlPath))!
        let request1: NSURLRequest = NSURLRequest(URL: url)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        
        do{
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1, returningResponse: response)
            // print(response)
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(dataVal, options: []) as? NSDictionary {
                    dataProcessCenter.parseJSON(jsonResult)
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }catch let error as NSError
        {
            print(error.localizedDescription)
        }
    }
    
    func weiboImageClicked(weiboID: Int, imageIndex: Int, sourceImageView: UIImageView) {
        if dataProcessCenter.hasCacheImageAt(weiboID, imgaeIndex: imageIndex) {
            if let picModels = dataProcessCenter.getWeiboOriginalImage(weiboID){
                segueData.imageIndex = imageIndex
                segueData.sourceImageView = sourceImageView
                segueData.picModels = picModels
                performSegueWithIdentifier("showWeiboImage", sender: segueData)
            }
            
        }else{
            print("Please wait until image downloaded")
        }
    }
    
    
    // MARK: - Table view data source
    
    func calculateHeight(heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dataProcessCenter.estimateCellHeight(self.view.bounds.width, cell: prototypeCell, atIndex: indexPath)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataProcessCenter.getWeiboCount()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("baseTypeCell", forIndexPath: indexPath) as? BaseTypeTableViewCell {
            // Configure the cell...
            dataProcessCenter.configureCell(cell, cellForRowAtIndexPath: indexPath)
            cell.callbackDelegate = self
            return cell
        }
        return tableView.dequeueReusableCellWithIdentifier("baseTypeCell", forIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = calculateHeight(heightForRowAtIndexPath: indexPath)
        return height
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? BaseTypeTableViewCell {
            dataProcessCenter.loadImageFor(cell, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? BaseTypeTableViewCell {
            cell.removeTapGestureFromAllImages()
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if let dest = segue.destinationViewController as? PageViewController {
            dest.segueData = segueData
        }
     }
    
}



