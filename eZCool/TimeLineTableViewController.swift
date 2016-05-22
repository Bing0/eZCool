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
    
    // MARK: - Variable
    
    private let cacheTool = CacheTool()

    private let imageManager = ImageManager()
    
    private var prototypeCell :TimeLineTypeCell!
    
    let threshold: CGFloat = 1000.0 // threshold from bottom of tableView
    
    var isLoadingMore = false // flag
    
    private var newWeiboCount = 0 {
        willSet{
            print("new weibo \(newValue)")
        }
    }
    
    // MARK: - Functions
    
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
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...

        do {
            try WeiboAccessTool().getNewestTimeline(){
                do {
                    let jsonResult = try $0()
                    
                    self.newWeiboCount = parseJSON().parseHomeTimelineJSON(jsonResult)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        //TODO show new weibo count
                        
                    }
                }catch{
                    print(error)
                    self.refreshControl?.endRefreshing()
                }
            }
        }catch{
            print(error)
            refreshControl.endRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        imageManager.clearImageCache()
    }
    
    func weiboImageClicked(weiboID: Int, imageIndex: Int, sourceImageView: UIImageView) {
        if let picModels = imageManager.getWeiboOriginalImage(weiboID){
            let imageViewSegueData = ImageViewSegueData()
            imageViewSegueData.imageIndex = imageIndex
            imageViewSegueData.sourceImageView = sourceImageView
            imageViewSegueData.picModels = picModels
            performSegueWithIdentifier("showWeiboImage", sender: imageViewSegueData)
        }
    }
    
    func cellClicked(weiboID: Int, index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("weiboDetail") as! WeiboDetailViewController
        vc.index = index
        vc.weiboID = weiboID
        vc.cacheTool = cacheTool
        vc.imageManager = imageManager
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileImageClicked(weiboID: Int, index: Int) {
        print("profileImageClicked")
    }
    
    // MARK: - Table view data source
    
    func calculateHeight(heightForRowAtIndex index: Int) -> CGFloat {
        do {
            let wbContent = try cacheTool.getWeiboContent(withIndex: index)
            return CellConfigureTool().estimateCellHeight(self.view.bounds.width, cell: prototypeCell, wbContent: wbContent)
        }catch{
            print(error)
        }
        return 0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return cacheTool.getWeiboCount()
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
                
                do {
                    let wbContent = try cacheTool.getWeiboContent(withIndex: indexPath.section)
                    CellConfigureTool().configureWeiboContentCell(cell, wbContent: wbContent)
                }catch{
                    print(error)
                }
                
                return cell
            }
        }else{
            if let cell = tableView.dequeueReusableCellWithIdentifier("bottomBarCell", forIndexPath: indexPath) as? BottomBarCell {
                // Configure the cell...
                cell.callbackDelegate = self
                do {
                    let wbContent = try cacheTool.getWeiboContent(withIndex: indexPath.section)
                    CellConfigureTool().configureWeiboBottomBarCell(cell, wbContent: wbContent)
                }catch{
                    print(error)
                }
                
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
            do {
                let wbContent = try cacheTool.getWeiboContent(withIndex: indexPath.section)
                //Careful.  Call this method in main thread, but image fetch is in a none main thrad
                imageManager.loadMiddleQualityImageFor(cell, wbContent: wbContent)
            }catch{
                print(error)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? TimeLineTypeCell {
            cell.removeTapGestureFromAllImages()
        }
    }
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if !isLoadingMore && (maximumOffset - contentOffset <= threshold) {
            // Get more data - API call
            self.isLoadingMore = true
            
            do {
                try WeiboAccessTool().getLaterTimeline(){
                    do {
                        let jsonResult = try $0()
                        
                        let number = parseJSON().parseHomeLaterTimelineJSON(jsonResult)
                        print("get \(number) weibo")
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                            self.isLoadingMore = false
                        }
                    }catch{
                        print(error)
                        self.isLoadingMore = false
                    }
                }
            }catch{
                print(error)
                self.isLoadingMore = false
            }
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
            let imageViewSegueData = sender as! ImageViewSegueData
            dest.imageViewSegueData = imageViewSegueData
        }
     }
}



