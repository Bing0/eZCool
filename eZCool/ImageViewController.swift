//
//  ImageViewController.swift
//  ScrollImageViewTest
//
//  Created by BinWu on 5/4/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topPadConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomPadConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingPadConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingPadConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
 
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.delegate = self
        
        imageViewWidthConstraint.active = false
        imageViewHeightConstraint.active = false
        
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height)

        view.layoutIfNeeded()
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToGoBack(_:)))
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapToZoom(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        view.addGestureRecognizer(singleTapGesture)
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale, 1)
        // 2
        scrollView.minimumZoomScale = minScale
        // 3
        scrollView.zoomScale = minScale
    }
    
    func tapToGoBack(sender: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true) {
        }
    }

    func doubleTapToZoom(sender: UITapGestureRecognizer) {
        let point = sender.locationInView(imageView)

        if scrollView.zoomScale != 1 {
            scrollView.zoomToRect(CGRectMake(point.x - 1, point.y - 1, 3, 3), animated: true)
        }else{
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
    
    private func updateConstraintsForSize(size: CGSize) {
        // 2
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        topPadConstraint.constant = yOffset
        bottomPadConstraint.constant = yOffset
        // 3
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        leadingPadConstraint.constant = xOffset
        trailingPadConstraint.constant = xOffset
        
        view.layoutIfNeeded()
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
