//
//  DatProcessCenter.swift
//  eZCool
//
//  Created by BinWu on 5/2/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import Foundation
import CoreData

struct Constant {
    static let ProfileImageUpdateInterval = 3600
    static let LowPicQuality = "thumbnail"
    static let MidPicQuality = "bmiddle"
    static let HigPicQuality = "large"
}

class DataProcessCenter :NSObject{
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var weiboContent = [WBContentModel]()
    
    let dateFormatterFromJSON = NSDateFormatter()
    
    var cachedUserProfileImage = [Int: UIImage]()
    
    var cachedWeiboImage = [Int:[Int: UIImage]]()
    
    override init() {
        dateFormatterFromJSON.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        dateFormatterFromJSON.locale = NSLocale(localeIdentifier: "en_US")
    }
    
    func parseJSON(jsonResult: NSDictionary) {
        //        print(jsonResult)
        
        print("has_unread: \(jsonResult["has_unread"])")
        print("hasvisible: \(jsonResult["hasvisible"])")
        print("interval: \(jsonResult["interval"])")
        print("max_id: \(jsonResult["max_id"])")
        print("next_cursor: \(jsonResult["next_cursor"])")
        print("previous_cursor: \(jsonResult["previous_cursor"])")
        print("since_id: \(jsonResult["since_id"])")
        
        
        if let statuses = jsonResult["statuses"] as? [[String: AnyObject]]{
            for statuse in statuses {
                if let wbContent = ParseWBContent().parseOneWBContent(statuse) {
                    parseOneWeiboRecord(wbContent, isInTimeline: true)
                }
            }
            print("Parse finished")
            saveData()
        }
    }
    
    func parseOneWeiboRecord(wbContent: WBContent, isInTimeline: Bool) -> WBContentModel?{
        //search in core data first
        if let wbContentMidel = isWeiboHasBeenStored(wbContent.id) {
            return wbContentMidel
        }
        //create one
        let wbContentModelEntity = NSEntityDescription.entityForName("WBContentModel",inManagedObjectContext: managedObjectContext)
        let wbContentModel = WBContentModel(entity: wbContentModelEntity!, insertIntoManagedObjectContext: managedObjectContext)
        
        wbContentModel.wbID = wbContent.id
        wbContentModel.createdDate = dateFormatterFromJSON.dateFromString( wbContent.created_at)
        wbContentModel.text = wbContent.text
        wbContentModel.source = wbContent.source
        wbContentModel.repostCount = wbContent.reposts_count
        wbContentModel.commentCount = wbContent.comments_count
        wbContentModel.attitudeCount = wbContent.attitudes_count
        if isInTimeline { wbContentModel.isInTimeline = true}
        
        if let retweetedWBContent = wbContent.retweeted_status {
            if let reposted = parseOneWeiboRecord(retweetedWBContent, isInTimeline: false) {
                wbContentModel.repostContent =  reposted
                reposted.addBeRepostedObject(wbContentModel)
            }
        }
        
        for i in 0 ..< wbContent.pic_urls.count {
            let picEntity = NSEntityDescription.entityForName("WBPictureModel",inManagedObjectContext: managedObjectContext)
            let picModel = WBPictureModel(entity: picEntity!, insertIntoManagedObjectContext: managedObjectContext)
            
            var url = wbContent.pic_urls[i]
            picModel.picURLLow = url
            url.replaceRange(url.rangeOfString(Constant.LowPicQuality)!, with: Constant.MidPicQuality)
            picModel.picURLMedium = url
            url.replaceRange(url.rangeOfString(Constant.MidPicQuality)!, with: Constant.HigPicQuality)
            picModel.picURLHigh = url
            picModel.index = i
            picModel.belongToWBContent = wbContentModel
            wbContentModel.addPicturesObject(picModel)
        }
        
        if let wbUserModel = getWBUserCreateIfNone(wbContent.user) {
            wbContentModel.belongToWBUser =  wbUserModel
            wbUserModel.addWbContentsObject(wbContentModel)
        }
        return wbContentModel
    }
    
    func isWeiboHasBeenStored(weiboID: Int) -> WBContentModel? {
        let request  = NSFetchRequest(entityName: "WBContentModel")
        request.predicate = NSPredicate(format: "wbID = %ld", weiboID)
        var wbContentModel = [WBContentModel]()
        
        do{
            wbContentModel = try managedObjectContext.executeFetchRequest(request) as! [WBContentModel]
        }catch{
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        if wbContentModel.count > 0 {
            return wbContentModel[0]
        }
        return nil
    }
    
    func getWBUserCreateIfNone(wbUser: WBUser?) -> WBUserModel? {
        if let weiboUser = wbUser {
            let request  = NSFetchRequest(entityName: "WBUserModel")
            request.predicate = NSPredicate(format: "userID = %ld", weiboUser.id)
            var wbUserModel = [WBUserModel]()
            
            do{
                wbUserModel = try managedObjectContext.executeFetchRequest(request) as! [WBUserModel]
            }catch{
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
            if wbUserModel.count > 0 {
                return wbUserModel[0]
            }else{
                return storeWBUser(weiboUser)
            }
        }
        return nil
    }
    
    func storeWBUser(wbUser: WBUser) -> WBUserModel{
        //create one
        let wbUserModelEntity = NSEntityDescription.entityForName("WBUserModel",inManagedObjectContext: managedObjectContext)
        let wbUserModel = WBUserModel(entity: wbUserModelEntity!, insertIntoManagedObjectContext: managedObjectContext)
        
        wbUserModel.userID = wbUser.id
        wbUserModel.profileURL = wbUser.profile_url
        wbUserModel.createdDate = dateFormatterFromJSON.dateFromString( wbUser.created_at)
        wbUserModel.avatarHDURL = wbUser.avatar_hd
        wbUserModel.isVerified = wbUser.verified
        wbUserModel.name = wbUser.name
        wbUserModel.screenName = wbUser.screen_name
        wbUserModel.verifiedReason = wbUser.verified_reason
        wbUserModel.lastUpdateDate = NSDate()
        
        return wbUserModel
    }
    
    func getWeiboCount() -> Int {
        let request  = NSFetchRequest(entityName: "WBContentModel")
        request.predicate = NSPredicate(format: "isInTimeline = %d", 1)
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
        
        do{
            weiboContent = try managedObjectContext.executeFetchRequest(request) as! [WBContentModel]
        }catch{
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return weiboContent.count
    }

    func makeAttributedString(string: String) -> NSAttributedString {
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(string:string)
        let textRange = NSRange(location: 0, length: string.characters.count)
        
        //规则检查
        var ranges:[NSRange] = []
        
        let kRegexPattern = "@[\\w-_]+|#[\\w]+#|\\[\\w+\\]|(https?)://(?:(\\S+?)(?::(\\S+?))?@)?([a-zA-Z0-9\\-.]+)(?::(\\d+))?((?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?"
        
        let reg = try? NSRegularExpression(pattern: kRegexPattern, options: [])
        reg?.enumerateMatchesInString(string, options: [], range: textRange, usingBlock: {result, flags, ptr in
            if let result = result
            {
                ranges.append(result.range)
            }
        })
        
        let specialColorAttribute = [ NSForegroundColorAttributeName: UIColor.colorWithHex("EB7350", alpha: 1.0) ]
        
        for range in ranges {
            attributedString.addAttributes(specialColorAttribute, range: range)
        }    
        return attributedString
    }
    
    
    func configureCell(cell: BaseTypeTableViewCell, cellForRowAtIndexPath indexPath: NSIndexPath) {
        let wbContent = weiboContent[indexPath.row]
        let wbUser = wbContent.belongToWBUser!
        var wbPics = wbContent.pictures
        
        cell.wbUserID = 0
        cell.weiboID = 0
        
        cell.name.text = wbUser.name
        cell.time.text = wbContent.createdDate?.getRelativeTime()
        
        cell.profileImage.image = nil
        
        cell.repostButton.setTitle(wbContent.repostCount != 0 ? " \(wbContent.repostCount!)" : " Repost", forState: UIControlState.Normal)
        cell.commentButton.setTitle(wbContent.commentCount != 0 ? " \(wbContent.commentCount!)" : " Comments", forState: UIControlState.Normal)
        cell.attitudeButton.setTitle(wbContent.attitudeCount != 0 ? " \(wbContent.attitudeCount!)" : "", forState: UIControlState.Normal)
        
        for imageView in cell.originalImageCollection {
            imageView.image = nil
        }
        
        var reposted = false
        
        if let repostedWBContent = wbContent.repostContent{
            //
            cell.repostText.attributedText = makeAttributedString(wbContent.text ?? "")
            let repostedWBUser = repostedWBContent.belongToWBUser
            
            let userName = (repostedWBUser?.name != nil) ? "@\(repostedWBUser!.name!):"  : ""
            //
            cell.originalText.attributedText = makeAttributedString("\(userName)\(repostedWBContent.text!)")
            
            wbPics = repostedWBContent.pictures
            reposted = true
        }else{
            //
            cell.originalText.attributedText = makeAttributedString(wbContent.text ?? "")
            wbPics = wbContent.pictures
        }
        
        if let picModels =  wbPics?.allObjects as? [WBPictureModel]{
            
            switch picModels.count {
            case 0:
                cell.setOriginalTextStyle(OriginalViewStyle.textOnly, reposted: reposted)
            case 1 ... 3:
                cell.setOriginalTextStyle(OriginalViewStyle.textWithOneLineImages, reposted: reposted)
            case 4 ... 6:
                cell.setOriginalTextStyle(OriginalViewStyle.textWithTwoLineImages, reposted: reposted)
            case 7 ... 9:
                cell.setOriginalTextStyle(OriginalViewStyle.textWithThreeLineImages, reposted: reposted)
            default:
                break
            }
            cell.addTapGestureToImages(picModels.count)
        }
    }
    
    func loadImageFor(cell: BaseTypeTableViewCell, cellForRowAtIndexPath indexPath: NSIndexPath) {
        let wbContent = weiboContent[indexPath.row]
        let wbUser = wbContent.belongToWBUser!
        var wbPics = wbContent.pictures
        var cellWeibID :Int!
        
        cell.name.text = wbUser.name
        cell.time.text = wbContent.createdDate?.getRelativeTime()
        
        cell.profileImage.image = nil
        
        cell.wbUserID = Int(wbUser.userID!)
//        cell.weiboID = 0
        loadProfileImage(wbUser, forCell: cell)
        
        if let repostedWBContent = wbContent.repostContent{
            wbPics = repostedWBContent.pictures
            cellWeibID = Int(repostedWBContent.wbID!)
        }else{
            cell.originalText.text = wbContent.text
            wbPics = wbContent.pictures
            cellWeibID = Int(wbContent.wbID!)
        }
        cell.weiboID = cellWeibID
        for picModel in (wbPics?.allObjects as? [WBPictureModel])! {
            cell.originalImageCollection[Int(picModel.index!)].image = UIImage(named: "timeline_icon_photo")
            loadWeiboImage(picModel, weiboID: cellWeibID, forCell: cell)
        }
    }
    
    
    func estimateCellHeight(framWidth: CGFloat,cell: BaseTypeTableViewCell, atIndex index: NSIndexPath) -> CGFloat {
        
        let wbContent = weiboContent[index.row]
        
        if let cellHeight = wbContent.cellHeight {
            return CGFloat.init(cellHeight)
        }else{
            
            configureCell(cell, cellForRowAtIndexPath: index)
            
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            
            cell.bounds = CGRectMake(0, 0,framWidth, cell.bounds.height)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            var fittingSize = UILayoutFittingCompressedSize
            fittingSize.width = cell.bounds.width
            
            let size = cell.contentView.systemLayoutSizeFittingSize(fittingSize, withHorizontalFittingPriority: 1000, verticalFittingPriority: 250)
            
            wbContent.cellHeight = size.height
            
            print("Row: \(index.row) width: \(size.width) height: \(size.height)")
            
            return size.height
        }
    }
    
    func loadProfileImage(wbUser: WBUserModel, forCell cell: BaseTypeTableViewCell) {
        if let profileImage = cachedUserProfileImage[Int(wbUser.userID!)] {
            if cell.wbUserID == Int(wbUser.userID!) {
                // has been cached
                cell.profileImage.image = profileImage
                //                print("get profile image from cahce")
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
    
    func loadWeiboImage(picModel: WBPictureModel, weiboID: Int, forCell cell: BaseTypeTableViewCell) {
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            if let cachedWeiboImageCollection = self.cachedWeiboImage[weiboID] {
                if let cachedWeiboImage = cachedWeiboImageCollection[Int(picModel.index!)] {
                    //has been cached
                    dispatch_async(dispatch_get_main_queue()){
                        cell.originalImageCollection[Int(picModel.index!)].image = cachedWeiboImage
                        // print("get weibo image from cahce. size: \(cachedWeiboImage.size)")
                    }
                    return
                }
            }
            if let picture = picModel.pictureHigh {
                //has been downloaded
                if cell.weiboID == weiboID {
//                    let image = self.cutToSquareImage(UIImage(data: picture)!)
                    let image = UIImage(data: picture)!
                    
                    dispatch_async(dispatch_get_main_queue()){
                        cell.originalImageCollection[Int(picModel.index!)].image = image
                        print("get weibo image from disk")
                    }
                    //cache
                    if var cachedWeiboImageCollection = self.cachedWeiboImage[weiboID] {
                        cachedWeiboImageCollection[Int(picModel.index!)] = image
                        self.cachedWeiboImage[weiboID] = cachedWeiboImageCollection
                    }else{
                        self.cachedWeiboImage[weiboID] =  [Int(picModel.index!): image]
                    }
                }else{
                    print("~~~wrong weibo image!!!!!!!!!! weibo: \(weiboID) index: \(picModel.index!)")
                }
            }else{
                //need download
                
                if let imageData = NSData(contentsOfURL: NSURL(string: picModel.picURLHigh!)!){
                    //store the image
                    picModel.pictureHigh = imageData
                    //to do. extral picture from high
//                    let image = self.cutToSquareImage(UIImage(data: imageData)!)
                    let image = UIImage(data: imageData)!
                    //cache
                    if var cachedWeiboImageCollection = self.cachedWeiboImage[weiboID] {
                        cachedWeiboImageCollection[Int(picModel.index!)] = image
                        self.cachedWeiboImage[weiboID] = cachedWeiboImageCollection
                    }else{
                        self.cachedWeiboImage[weiboID] =  [Int(picModel.index!): image]
                    }
                    dispatch_async(dispatch_get_main_queue()){
                        //try to display the image
                        if cell.weiboID == weiboID {
                            cell.originalImageCollection[Int(picModel.index!)].image = image
                            print("download weibo image for weibo: \(weiboID) index: \(picModel.index!)")
                        }else{
                            print("~~~wrong weibo image~~~")
                        }
                    }
                }
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
//            for pic in pics {
//                if let highPic = pic.pictureHigh {
//                    let formatedURLString = pic.picURLHigh?.lowercaseString
//                    if let range = formatedURLString?.rangeOfString(".gif"){
//                        if range.endIndex == formatedURLString?.endIndex{
//                            // gif file
//                            images.append(UIImage.gifWithData(highPic)!)
//                            continue
//                        }
//                    }
//                    images.append(UIImage(data: highPic)!)
//                }else{
//                    // this is dangerous
//                    images.append(UIImage(data: NSData(contentsOfURL: NSURL(string: pic.picURLHigh!)!)!)!)
//                }
//            }
//            return images
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
    
    
    func saveData(){
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

extension NSDate {
    func getRelativeTime() -> String {
        let interval = Int(NSDate().timeIntervalSinceDate(self))
        switch interval{
        case 0 ... 60:
            return "Just Now"
        case 61 ... 119:
            return "1 minuste ago"
        case 120 ... 3599:
            return "\(interval/60) minustes ago"
        case 3600 ... 7199:
            return "1 hour ago"
        case 7200 ... 86399:
            return "\(interval/3600) hours ago"
        case 86400 ... 172799:
            return "1 day ago"
        case 172800 ... 259200:
            return "\(interval/86400) days ago"
        default:
            let dateFormatterForShow = NSDateFormatter()
            dateFormatterForShow.dateFormat = "yyyy/MM/dd HH:mm::ss"
            return dateFormatterForShow.stringFromDate(self)
        }
    }
}

extension UIColor{
    
    class func colorWithHex(hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var rgb: CUnsignedInt = 0;
        let scanner = NSScanner(string: hex)
        
        if hex.hasPrefix("#") {
            // skip '#' character
            scanner.scanLocation = 1
        }
        scanner.scanHexInt(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0xFF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}