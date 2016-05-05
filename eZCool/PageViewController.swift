//
//  PageViewController.swift
//  ScrollImageViewTest
//
//  Created by BinWu on 5/4/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {

    var dataProcessCenter: DataProcessCenter!
    var segueData: SegueData!
    
    var currentIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        currentIndex = self.segueData.imageIndex
        
        dataSource = self
        
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            if let image = self.dataProcessCenter.getWeiboOriginalImage(self.segueData.weiboID, imageIndex: self.currentIndex) {
                dispatch_async(dispatch_get_main_queue()){
                if let viewController = self.viewImageShowController(image) {
                    self.setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func viewImageShowController(image: UIImage) -> ImageViewController? {
        if let storyboard = storyboard,
            page = storyboard.instantiateViewControllerWithIdentifier("ImageViewerController") as? ImageViewController {
            page.image = image
            return page
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if currentIndex > 0 {
            currentIndex -= 1
            let image = self.dataProcessCenter.getWeiboOriginalImage(self.segueData.weiboID, imageIndex: currentIndex )
            return self.viewImageShowController(image!)
        }else{
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if let image = self.dataProcessCenter.getWeiboOriginalImage(self.segueData.weiboID, imageIndex: currentIndex + 1){
            currentIndex += 1
            return self.viewImageShowController(image)
        }
        return nil
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
