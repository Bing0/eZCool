//
//  WeiboDetailViewController.swift
//  eZCool
//
//  Created by POD on 5/6/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

class WeiboDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellContentClickedCallback {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floatingViewTopPadConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var repostButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likesButton: UIButton!
    
    let userDefault = UserDefaults()
    var repostWeibos = [WBContentModel]()
    
    var cacheTool: CacheTool!
    var imageManager: ImageManager!
    
    var index: Int!
    var weiboID: Int!
    
    var _weiboContentHeight: CGFloat!
    var weiboContentHeight: CGFloat! {
        set{
            if _weiboContentHeight == nil {
                floatingViewTopPadConstraint.constant = newValue
                _weiboContentHeight = newValue
            }
        }
        get{
            return _weiboContentHeight
        }
    }
    var weiboScrollOffset: CGFloat!{
        willSet{
            floatingViewTopPadConstraint.constant = max(0, weiboContentHeight - newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.registerNib(UINib.init(nibName: "TimeLineTypeCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "timelineTypeCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 33
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        getCountOfRepostsComments()
        getRepostsTimeline()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCountOfRepostsComments(){
        do {
            try WeiboAccessTool().getRepostsCommentsCountsOf(weiboID){
                do {
                    let jsonResults = try $0()
                    for jsonResult in jsonResults {
                        if let id = jsonResult["id"] as? Int{
                            if id == self.weiboID{
                                let comments = jsonResult["comments"] as! Int
                                let reposts = jsonResult["reposts"] as! Int
                                do {
                                    if let wbContent = try self.cacheTool.getWeiboContent(withIndex: self.index, andWeiboID: self.weiboID) {
                                        wbContent.commentCount = comments
                                        wbContent.repostCount = reposts
                                    }
                                }catch{
                                    print(error)
                                }
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.repostButton.setTitle("Reposts \(reposts)", forState: UIControlState.Normal)
                                    self.commentButton.setTitle("Comments \(comments)", forState: UIControlState.Normal)
                                })
                                
                            }
                        }
                    }
                }catch{
                    print(error)
                }
            }
        }catch{
            print(error)
        }
    }
    
    func getRepostsTimeline(){
        do {
            try WeiboAccessTool().getRepostsTimelineWith(weiboID){
                do {
                    let jsonResult = try $0()
//                    let weiboIDs = DatabaseProcessCenter().parseJSONRepostsIDs(jsonResult)
//                    for weiboID in weiboIDs {
//                        self.getWeiboByID(weiboID)
//                    }
                    DatabaseProcessCenter().saveData()
                    
                    if let repostWeibo = DatabaseProcessCenter().isWeiboHasBeenCreated(self.weiboID){
                        if let repostWeibos = repostWeibo.beReposted?.allObjects as? [WBContentModel] {
                            self.repostWeibos = repostWeibos.sort(){
                                if $0.createdDate!.compare($1.createdDate!).rawValue < 0 {
                                    return  true
                                }
                                return false
                            }
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadSections(NSIndexSet.init(index: 2), withRowAnimation: UITableViewRowAnimation.None)
                    })
                    
                }catch{
                    print(error)
                }
            }
        }catch{
            print(error)
        }
    }
    
//    func getWeiboByID(weiboID: String){
//        let urlPath: String = "https://api.weibo.com/2/statuses/show.json?access_token=\(userDefault.wbtoken!)&id=\(weiboID)"
//        let url: NSURL = (NSURL(string: urlPath))!
//        let request1: NSURLRequest = NSURLRequest(URL: url)
//        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
//        
//        do{
//            let dataVal = try NSURLConnection.sendSynchronousRequest(request1, returningResponse: response)
//            // print(response)
//            do {
//                if let statuse = try NSJSONSerialization.JSONObjectWithData(dataVal, options: []) as? [String: AnyObject] {
//                    if let wbContent = ParseWBContent().parseOneWBContent(statuse) {
//                        dataProcessCenter.parseOneWeiboRecord(wbContent, isInTimeline: false)
//                    }
//                }
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//        }catch let error as NSError
//        {
//            print(error.localizedDescription)
//        }
//    }
    
    
    func weiboImageClicked(weiboID: Int, imageIndex: Int, sourceImageView: UIImageView) {
        if let picModels = imageManager.getWeiboOriginalImage(weiboID){
            let imageViewSegueData = ImageViewSegueData()
            imageViewSegueData.imageIndex = imageIndex
            imageViewSegueData.sourceImageView = sourceImageView
            imageViewSegueData.picModels = picModels
            performSegueWithIdentifier("showWeiboImageFromWeiboDetail", sender: imageViewSegueData)
        }
    }
    
    func cellClicked(weiboID: Int, index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("weiboDetail") as! WeiboDetailViewController
        vc.index = index
        vc.weiboID = weiboID
        vc.cacheTool = cacheTool
        vc.imageManager = imageManager

        self.showViewController(vc, sender: nil)
    }
    
    func profileImageClicked(weiboID: Int, index: Int) {
        print("profileImageClicked")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section < 2 {
            return 1
        }else{
           return repostWeibos.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCellWithIdentifier("timelineTypeCell", forIndexPath: indexPath) as? TimeLineTypeCell {
                // Configure the cell...
                cell.callbackDelegate = self
                cell.index = index
                cell.isShownWeiboDetail = true
                do {
                    if let wbContent = try cacheTool.getWeiboContent(withIndex: index, andWeiboID: weiboID) {
                        CellConfigureTool().configureWeiboContentCell(cell, wbContent: wbContent)
                    }
                }catch{
                    print(error)
                }
                return cell
            }
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("floatViewCell", forIndexPath: indexPath)
                // Configure the cell...
            return cell
        }else if indexPath.section == 2 {
            if let cell = tableView.dequeueReusableCellWithIdentifier("repostCommentCell", forIndexPath: indexPath) as? RepostCommentTableViewCell {
                cell.name.text = repostWeibos[indexPath.row].belongToWBUser!.name
                cell.mainText.text = repostWeibos[indexPath.row].text
                return cell
            }
        }
        
        return tableView.dequeueReusableCellWithIdentifier("timelineTypeCell", forIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? TimeLineTypeCell {
            do {
                if let wbContent = try cacheTool.getWeiboContent(withIndex: index, andWeiboID: weiboID) {
                    imageManager.loadMiddleQualityImageFor(cell, wbContent: wbContent)
                }
            }catch{
                print(error)
            }
        }
        if indexPath.section == 1 {
            weiboContentHeight = cell.frame.origin.y + cell.frame.height - 37
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? TimeLineTypeCell {
            cell.removeTapGestureFromAllImages()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        weiboScrollOffset = tableView.contentOffset.y
    }
    
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
