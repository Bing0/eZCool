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
    var floatingView: UIView!
    
    let imageViewSegueData = ImageViewSegueData()
    
    var dataProcessCenter: DataProcessCenter!
    var index: Int!
    var weiboID: Int!
    
    var weiboContentHeight: CGFloat! {
        willSet{
            floatingViewTopPadConstraint.constant = newValue
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func weiboImageClicked(weiboID: Int, imageIndex: Int, sourceImageView: UIImageView) {
        if dataProcessCenter.hasCacheImageAt(weiboID, imgaeIndex: imageIndex) {
            if let picModels = dataProcessCenter.getWeiboOriginalImage(weiboID){
                imageViewSegueData.imageIndex = imageIndex
                imageViewSegueData.sourceImageView = sourceImageView
                imageViewSegueData.picModels = picModels
                performSegueWithIdentifier("showWeiboImageFromWeiboDetail", sender: imageViewSegueData)
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
        self.showViewController(vc, sender: nil)
    }
    
    func profileImageClicked(weiboID: Int, index: Int) {
        print("profileImageClicked")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCellWithIdentifier("timelineTypeCell", forIndexPath: indexPath) as? TimeLineTypeCell {
                // Configure the cell...
                cell.callbackDelegate = self
                cell.index = index
                cell.isShownWeiboDetail = true
                dataProcessCenter.configureWeiboContentCell(cell, index: index, weiboID: weiboID)
                return cell
            }
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("floatViewCell", forIndexPath: indexPath)
                // Configure the cell...
            return cell
        }
        
        return tableView.dequeueReusableCellWithIdentifier("timelineTypeCell", forIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? TimeLineTypeCell {
            dataProcessCenter.loadImageFor(cell, cellForRowAtIndex: index, weiboID: weiboID)
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
        print(tableView.contentOffset)
        weiboScrollOffset = tableView.contentOffset.y
    }
    
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
