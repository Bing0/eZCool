//
//  TimeLineTableViewController.swift
//  eZCool
//
//  Created by BinWu on 4/30/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

class ImageViewSegueData {
    var imageIndex = 0
    var picModels = [WBPictureModel]()
    var sourceImageView =  UIImageView()
}

class TimeLineTableViewController: UITableViewController, CellContentClickedCallback{
    
    let userDefault = UserDefaults()
    
    let dataProcessCenter = DataProcessCenter()
    var prototypeCell :TimeLineTypeCell!
    
    let imageViewSegueData = ImageViewSegueData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.registerNib(UINib.init(nibName: "TimeLineTypeCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "timelineTypeCell")
        tableView.registerNib(UINib.init(nibName: "BottomBarCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "bottomBarCell")
        
        prototypeCell = tableView.dequeueReusableCellWithIdentifier("timelineTypeCell") as! TimeLineTypeCell

        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
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
                imageViewSegueData.imageIndex = imageIndex
                imageViewSegueData.sourceImageView = sourceImageView
                imageViewSegueData.picModels = picModels
                performSegueWithIdentifier("showWeiboImage", sender: imageViewSegueData)
            }
            
        }else{
            print("Please wait until image downloaded")
        }
    }
    
    func cellClicked(weiboID: Int, index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("weiboDetail") as! WeiboDetailViewController
        vc.index = index
        vc.weiboID = weiboID
        vc.dataProcessCenter = dataProcessCenter
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileImageClicked(weiboID: Int, index: Int) {
        print("profileImageClicked")
    }
    
    // MARK: - Table view data source
    
    func calculateHeight(heightForRowAtIndex index: Int) -> CGFloat {
        return dataProcessCenter.estimateCellHeight(self.view.bounds.width, cell: prototypeCell, atIndex: index)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dataProcessCenter.getWeiboCount()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCellWithIdentifier("timelineTypeCell", forIndexPath: indexPath) as? TimeLineTypeCell {
                // Configure the cell...
                cell.callbackDelegate = self
                cell.index = indexPath.section
                cell.isShownWeiboDetail = false
                
                dataProcessCenter.configureWeiboContentCell(cell, index: indexPath.section)
                return cell
            }
        }else{
            if let cell = tableView.dequeueReusableCellWithIdentifier("bottomBarCell", forIndexPath: indexPath) as? BottomBarCell {
                // Configure the cell...
                dataProcessCenter.configureWeiboBottomBarCell(cell, cellForRowAtIndex: indexPath.section)
                cell.callbackDelegate = self
                return cell
            }
        }
        
        return tableView.dequeueReusableCellWithIdentifier("timelineTypeCell", forIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 38
        }
        let height = calculateHeight(heightForRowAtIndex: indexPath.section)
        return height
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? TimeLineTypeCell {
            dataProcessCenter.loadImageFor(cell, cellForRowAtIndex: indexPath.section)
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? TimeLineTypeCell {
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
            dest.imageViewSegueData = imageViewSegueData
        }
     }
}



