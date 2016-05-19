//
//  ImageManager.swift
//  eZCool
//
//  Created by BinWu on 5/19/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import Foundation

class ImageManager {
 
    func loadImageFor(cell: TimeLineTypeCell, wbContent: WBContentModel) {
        let wbUser = wbContent.belongToWBUser!
        var wbPics = wbContent.pictures
        var picWeibID :Int!
        
        cell.profileImage.image = nil
        
        cell.wbUserID = Int(wbUser.userID!)
        loadProfileImage(wbUser, forCell: cell)
        
        cell.weiboIDMain = Int(wbContent.wbID!)
        
        if let repostedWBContent = wbContent.repostContent{
            wbPics = repostedWBContent.pictures
            cell.weiboIDReposted = Int(repostedWBContent.wbID!)
            picWeibID = Int(repostedWBContent.wbID!)
        }else{
            wbPics = wbContent.pictures
            picWeibID = Int(wbContent.wbID!)
        }
        
        for picModel in (wbPics?.allObjects as? [WBPictureModel])! {
            cell.originalImageCollection[Int(picModel.index!)].image = UIImage(named: "timeline_icon_photo")
            loadWeiboImage(picModel, picWeiboID: picWeibID, weiboIDMain: Int(wbContent.wbID!), forCell: cell)
        }
    }
    
    func loadImageFor(cell: TimeLineTypeCell, cellForRowAtIndex index: Int) {
        let wbContent = weiboContent[index]
        loadImageFor(cell, wbContent: wbContent)
    }
    
    func loadImageFor(cell: TimeLineTypeCell, cellForRowAtIndex index: Int, weiboID: Int) {
        let wbContent = weiboContent[index]
        if wbContent.wbID == weiboID {
            loadImageFor(cell, wbContent: wbContent)
        }else if wbContent.repostContent?.wbID == weiboID {
            loadImageFor(cell, wbContent: wbContent.repostContent!)
        }
    }
    
    
    
    func loadProfileImage(wbUser: WBUserModel, forCell cell: TimeLineTypeCell) {
        if let profileImage = cachedUserProfileImage[Int(wbUser.userID!)] {
            if cell.wbUserID == Int(wbUser.userID!) {
                // has been cached
                cell.profileImage.image = profileImage
                // print("get profile image from cache")
                return
            }
        }
        if let avatarHD = wbUser.avatarHD {
            //has been download
            if cell.wbUserID == Int(wbUser.userID!) {
                let image = cutToSquareImage(UIImage(data: avatarHD)!)
                cell.profileImage.image = image
                cachedUserProfileImage[Int(wbUser.userID!)] = image
            }else{
                print("~~~wrong profile image!!!!!!!!!!")
            }
        }else{
            //need download
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                if let imageData = NSData(contentsOfURL: NSURL(string: wbUser.avatarHDURL!)!){
                    //store the image
                    wbUser.avatarHD = imageData
                    let image = self.cutToSquareImage(UIImage(data: imageData)!)
                    self.cachedUserProfileImage[Int(wbUser.userID!)] = image
                    dispatch_async(dispatch_get_main_queue()){
                        //try to display the image
                        if cell.wbUserID == Int(wbUser.userID!) {
                            cell.profileImage.image = image
                            print("downloaded profile image for usr: \(wbUser.userID!)")
                        }else{
                            print("~~~wrong profile image~~~")
                        }
                    }
                }
            }
        }
    }
    
    func getCachedWeiboImgae(weiboID: Int, imageIndex: Int) -> UIImage? {
        if let cachedWeiboImageCollection = self.cachedWeiboImage[weiboID] {
            if let cachedWeiboImage = cachedWeiboImageCollection[imageIndex] {
                //has been cached
                return cachedWeiboImage
            }
        }
        return nil
    }
    
    func cacheWeiboImgae(weiboID: Int, imageIndex: Int, image: UIImage) {
        //cache
        if var cachedWeiboImageCollection = self.cachedWeiboImage[weiboID] {
            cachedWeiboImageCollection[imageIndex] = image
            self.cachedWeiboImage[weiboID] = cachedWeiboImageCollection
        }else{
            self.cachedWeiboImage[weiboID] = [imageIndex: image]
        }
    }
    
    func getWeiboImgaeFromDisk(picModel: WBPictureModel) -> UIImage? {
        if let picture = picModel.pictureHigh {
            return  UIImage(data: picture)!
        }
        if let picture = picModel.pictureMedium {
            return  UIImage(data: picture)!
        }
        if let picture = picModel.pictureLow {
            return  UIImage(data: picture)!
        }
        return nil
    }
    
    func downloadWeiboImgae(picModel: WBPictureModel) -> UIImage? {
        if let imageData = NSData(contentsOfURL: NSURL(string: picModel.picURLMedium!)!){
            //store the image
            picModel.pictureMedium = imageData
            
            return UIImage(data: imageData)!
        }
        return nil
    }
    
    
    func loadWeiboImage(picModel: WBPictureModel, picWeiboID: Int, weiboIDMain comparition: Int, forCell cell: TimeLineTypeCell) {
        
        var updateWeiboImage :UIImage! {
            willSet{
                if cell.weiboIDMain == comparition {
                    dispatch_async(dispatch_get_main_queue()){
                        cell.originalImageCollection[Int(picModel.index!)].image = newValue
                    }
                }
            }
        }
        
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            //cached
            if let cachedWeiboImage = self.getCachedWeiboImgae(picWeiboID, imageIndex: Int(picModel.index!)) {
                updateWeiboImage = cachedWeiboImage
                return
            }
            //get from disk
            if let image = self.getWeiboImgaeFromDisk(picModel) {
                //cache
                self.cacheWeiboImgae(picWeiboID, imageIndex: Int(picModel.index!), image: image)
                //has been downloaded
                updateWeiboImage = image
                return
            }
            //need download
            if let image = self.downloadWeiboImgae(picModel) {
                //cache
                self.cacheWeiboImgae(picWeiboID, imageIndex: Int(picModel.index!), image: image)
                //has been downloaded
                updateWeiboImage = image
            }
        }
    }
    
    
    // run not in the main queue
    func getWeiboOriginalImage(weiboID: Int) -> [WBPictureModel]? {
        let request  = NSFetchRequest(entityName: "WBContentModel")
        request.predicate = NSPredicate(format: "wbID = %ld", weiboID)
        var weibos: [WBContentModel]!
        do{
            weibos = try managedObjectContext.executeFetchRequest(request) as! [WBContentModel]
        }catch{
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        //to do sort the weiboContent
        
        let weibo = weibos[0]
        
        if var pics = weibo.pictures?.allObjects as? [WBPictureModel] {
            //            var images = [UIImage]()
            pics = pics.sort(){
                if Int($0.index!) < Int($1.index!){
                    return true
                }
                return false
            }
            return pics
        }
        return nil
    }
    
    func hasCacheImageAt(weiboID: Int, imgaeIndex: Int) -> Bool {
        if let cachedWeiboImageCollection = cachedWeiboImage[weiboID] {
            if let _ = cachedWeiboImageCollection[imgaeIndex] {
                //has been cached
                return true
            }
        }
        return false
    }
    
    func cutToSquareImage(image: UIImage) -> UIImage {
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var tempLength: CGFloat = 0.0
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            tempLength = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            tempLength = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, tempLength, tempLength)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cuttedImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        return cuttedImage
    }

}