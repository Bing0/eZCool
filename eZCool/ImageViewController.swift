//
//  ImageViewController.swift
//  ScrollImageViewTest
//
//  Created by BinWu on 5/4/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, NSURLSessionDownloadDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topPadConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomPadConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingPadConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingPadConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
 
    @IBOutlet weak var indexIndicator: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    var picModel: WBPictureModel!
    
    var totalCount = 1
    var currentIndex = 0
    
    var _finalImage: UIImage!
    
    var finalImage: UIImage! {
        set{
            _finalImage = newValue
            imageView.image = newValue
            imageView.bounds = CGRectMake(0, 0, newValue.size.width, newValue.size.height)
            updateZoomScaleForSize(view.bounds.size)
            updateConstraintsForSize(view.bounds.size)
        }
        get{
            return _finalImage
        }
    }
    var needDownload: Bool! {
        willSet{
            if newValue == true {
                progressView.hidden = false
                progressView.progress = 0
            }else{
                progressView.hidden = true
            }
        }
    }
    
    var downloadTask: NSURLSessionDownloadTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        scrollView.delegate = self
        
        imageViewWidthConstraint.active = false
        imageViewHeightConstraint.active = false
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        
        
        if let finalImage = getFinalImage(picModel) {
            self.finalImage = finalImage
            needDownload = false
        }else{
            if let tempImage = getLowerQualityImage(picModel) {
                finalImage = tempImage
            }
            needDownload = true
        }
        
        if totalCount == 1 {
            indexIndicator.text = ""
        }else{
            indexIndicator.text = "\(currentIndex + 1)/\(totalCount)"
        }
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToGoBack(_:)))
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapToZoom(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        view.addGestureRecognizer(singleTapGesture)
        view.addGestureRecognizer(doubleTapGesture)
     
        if needDownload == true {
            //Download Image
            if let audioUrl = NSURL(string: picModel.picURLHigh!) {
                let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
                downloadTask = session.downloadTaskWithURL(audioUrl)
                downloadTask.resume()
            }
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        if let imageData = NSData(contentsOfURL: location) {
            dispatch_async(dispatch_get_main_queue()) {
                self.finalImage = UIImage(data: imageData)
                self.picModel.pictureHigh = imageData
                self.needDownload = false
            }
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // println("download task did write data")
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print("progress: \(progress)")
        dispatch_async(dispatch_get_main_queue()) {
            self.progressView.progress = progress
        }
    }
    
    func getFinalImage(picModel: WBPictureModel) -> UIImage? {
        if let imagedata = picModel.pictureHigh {
            return UIImage(data: imagedata)!
        }
        return nil
    }
    func getLowerQualityImage(picModel: WBPictureModel) -> UIImage? {
        if let imagedata = picModel.pictureMedium {
            return UIImage(data: imagedata)!
        }
        if let imagedata = picModel.pictureLow{
            return UIImage(data: imagedata)!
        }
        return nil
    }
    
    private func updateZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale, 1)
        // 2
        scrollView.minimumZoomScale = minScale
        // 3
        scrollView.zoomScale = minScale
        
        if finalImage.size.width <= view.frame.width {
            scrollView.minimumZoomScale = 1
            scrollView.maximumZoomScale = view.frame.width / finalImage.size.width
            scrollView.zoomScale = scrollView.maximumZoomScale
        }else{
            scrollView.maximumZoomScale = 1
            scrollView.minimumZoomScale = view.frame.width / finalImage.size.width
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
    }
    
    func tapToGoBack(sender: UITapGestureRecognizer) {
        if (downloadTask != nil) {
            downloadTask.cancel()
        }
        
        dismissViewControllerAnimated(true) {
        }
    }

    func doubleTapToZoom(sender: UITapGestureRecognizer) {
        let point = sender.locationInView(imageView)

        if scrollView.zoomScale != scrollView.maximumZoomScale {
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
