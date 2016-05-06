//
//  PageViewController.swift
//  ScrollImageViewTest
//
//  Created by BinWu on 5/4/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    var segueData: SegueData!
    
    var originalFrame :CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        dataSource = self
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = UIColor.blackColor()
        
        originalFrame = segueData.sourceImageView.convertRect(segueData.sourceImageView.bounds, toView: self.view)
        let animationImageView = UIImageView(frame: originalFrame)
        
        animationImageView.image = segueData.sourceImageView.image
        animationImageView.contentMode = segueData.sourceImageView.contentMode
        animationImageView.clipsToBounds = segueData.sourceImageView.clipsToBounds
        
        view.addSubview(animationImageView)
        
        self.view.addSubview(view)
        
        let animationImageSize = animationImageView.image!.size
        let targetImageFrameHeight = view.frame.width * animationImageSize.height / animationImageSize.width
        let targetImageFrameOriginY = targetImageFrameHeight >= view.frame.height ? 0 : (view.frame.height - targetImageFrameHeight) / 2
        
        let targetFrame = CGRect(x: 0, y: targetImageFrameOriginY, width: view.frame.width, height: targetImageFrameHeight)
        
        UIView.animateWithDuration(0.5, animations: { animationImageView.frame = targetFrame}) {
            (_) in
            if let viewController = self.viewImageShowController() {
                viewController.totalCount = self.segueData.picModels.count
                viewController.currentIndex = self.segueData.imageIndex
                viewController.picModel = self.segueData.picModels[viewController.currentIndex]
                self.setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
                //TODO download pics
                
            }
            view.removeFromSuperview()
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func viewImageShowController() -> ImageViewController? {
        if let storyboard = storyboard,
            page = storyboard.instantiateViewControllerWithIdentifier("ImageViewerController") as? ImageViewController {
            return page
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? ImageViewController {
            let currentIndex = viewController.currentIndex
            if currentIndex > 0 {
                if let viewController =  self.viewImageShowController(){
                    viewController.totalCount = segueData.picModels.count
                    viewController.currentIndex = currentIndex - 1
                    viewController.picModel = segueData.picModels[viewController.currentIndex]
                    return viewController
                }
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? ImageViewController {
            let currentIndex = viewController.currentIndex
            if currentIndex < segueData.picModels.count - 1 {
                if let viewController =  self.viewImageShowController(){
                    viewController.totalCount = segueData.picModels.count
                    viewController.currentIndex = currentIndex + 1
                    viewController.picModel = segueData.picModels[viewController.currentIndex]
                    return viewController
                }
            }
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
