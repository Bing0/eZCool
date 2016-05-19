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

class DatabaseProcessCenter :NSObject{
    
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    private let dateFormatterFromJSON = NSDateFormatter()
    
    private var cachedUserProfileImage = [Int: UIImage]()
    
    private var cachedWeiboImage = [Int:[Int: UIImage]]()
    
    
    override init() {
        dateFormatterFromJSON.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        dateFormatterFromJSON.locale = NSLocale(localeIdentifier: "en_US")
    }
    
    func clearWeiboHistory() {
        let request  = NSFetchRequest(entityName: "WBContentModel")
        
        var wbContentModels = [WBContentModel]()
        
        do{
            wbContentModels = try managedObjectContext.executeFetchRequest(request) as! [WBContentModel]
        }catch{
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        for wbContentModel in wbContentModels {
            managedObjectContext.deleteObject(wbContentModel)
        }
    }
    
    func analyseOneWeiboRecord(wbContent: WBContent, isInTimeline: Bool) -> WBContentModel?{
        //search in core data first
        if let wbContentModel = isWeiboHasBeenCreated(wbContent.id) {
            
            wbContentModel.repostCount = wbContent.reposts_count
            wbContentModel.commentCount = wbContent.comments_count
            wbContentModel.attitudeCount = wbContent.attitudes_count
            
            return wbContentModel
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
            if let reposted = analyseOneWeiboRecord(retweetedWBContent, isInTimeline: false) {
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
    
    func isWeiboHasBeenCreated(weiboID: Int) -> WBContentModel? {
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
                //TODO check user information last update time
                
                return wbUserModel[0]
            }else{
                return createWBUser(weiboUser)
            }
        }
        return nil
    }
    
    func createWBUser(wbUser: WBUser) -> WBUserModel{
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
    
    func getTimelineWeiboContentInDisk() -> [WBContentModel] {
        let request  = NSFetchRequest(entityName: "WBContentModel")
        request.predicate = NSPredicate(format: "isInTimeline = %d", 1)
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
        
        do{
            let weiboContents = try managedObjectContext.executeFetchRequest(request) as! [WBContentModel]
            return weiboContents
        }catch{
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return [WBContentModel]()
    }

    
        
    func updateWeiboCountsOf(comments: Int, reposts: Int, indexInTimeLineCell: Int, weiboID: Int) {
        let wbContent = weiboContent[indexInTimeLineCell]
        if wbContent.wbID == weiboID {
            wbContent.commentCount = comments
            wbContent.repostCount = reposts
        }else if wbContent.repostContent?.wbID == weiboID {
            wbContent.repostContent!.commentCount = comments
            wbContent.repostContent!.repostCount = reposts
        }
    }
    
        
    func parseJSONRepostsIDs(jsonResult: NSDictionary) -> [String] {
        print(jsonResult)
        
        if let weiboIDs = jsonResult["statuses"] as? [String]{
            return weiboIDs
        }
        return [String]()
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
    func getAbsoluteTime() -> String {
        let dateFormatterForShow = NSDateFormatter()
        dateFormatterForShow.dateFormat = "yyyy/MM/dd HH:mm::ss"
        return dateFormatterForShow.stringFromDate(self)
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