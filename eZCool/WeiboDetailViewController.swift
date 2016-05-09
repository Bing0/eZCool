//
//  WeiboDetailViewController.swift
//  eZCool
//
//  Created by POD on 5/6/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

class WeiboDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var dataProcessCenter: DataProcessCenter!
    var index: Int!
    var weiboID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.registerNib(UINib.init(nibName: "TimeLineTypeCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "timelineTypeCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 33
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("timelineTypeCell", forIndexPath: indexPath) as? TimeLineTypeCell {
            // Configure the cell...
            dataProcessCenter.configureWeiboContentCell(cell, index: index, weiboID: weiboID)
//            cell.callbackDelegate = self
            return cell
        }
        
        return tableView.dequeueReusableCellWithIdentifier("timelineTypeCell", forIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? TimeLineTypeCell {
            dataProcessCenter.loadImageFor(cell, cellForRowAtIndex: index, weiboID: weiboID)
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? TimeLineTypeCell {
            cell.removeTapGestureFromAllImages()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
