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
    
    private let _managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    private var managedObjectContext: NSManagedObjectContext {
        get {
//            print(NSThread.isMainThread())
            return _managedObjectContext
        }
    }
    
    private let dateFormatterFromJSON = NSDateFormatter()
    
    override init() {
        dateFormatterFromJSON.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        dateFormatterFromJSON.locale = NSLocale(localeIdentifier: "en_US")
    }
    
    
    func printuser() {
        let request  = NSFetchRequest(entityName: "WBUserModel")
        
        var wbUserModels = [WBUserModel]()
        
        do{
            wbUserModels = try managedObjectContext.executeFetchRequest(request) as! [WBUserModel]
        }catch{
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        for wbUserModel in wbUserModels {
            print("user: \(wbUserModel.name!), counts:\(wbUserModel.wbContents!.count)")
        }

    }
    
    //not in main thread
    func clearWeiboHistory() {
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateMOC.parentContext = managedObjectContext
        
        privateMOC.performBlockAndWait {
            
            let request  = NSFetchRequest(entityName: "WBContentModel")
            
            var wbContentModels = [WBContentModel]()
            
            do{
                wbContentModels = try privateMOC.executeFetchRequest(request) as! [WBContentModel]
            }catch{
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
            
            var i = 0
            
            for wbContentModel in wbContentModels {
                i += 1
                privateMOC.deleteObject(wbContentModel)
            }
            print("\(i) deleted \n")
            
            do {
                try privateMOC.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
        
        printuser()
        
    }
    
    func analyseOneWeiboRecord(wbContent: WBContent, isInTimeline: Bool) -> WBContentModel?{
        let privateMOC = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateMOC.parentContext = managedObjectContext
        
        var wbContentModel: WBContentModel? = nil
        
        privateMOC.performBlockAndWait {
            
            wbContentModel = self.analyseOneWeiboRecordInPivateThread(wbContent, isInTimeline: isInTimeline, privateMOC: privateMOC)
            
            do {
                try privateMOC.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
        }
        
        return wbContentModel
    }
    
    func analyseOneWeiboRecordInPivateThread(wbContent: WBContent, isInTimeline: Bool, privateMOC: NSManagedObjectContext) -> WBContentModel?{
        //search in core data first
        if let wbContentModel = isWeiboHasBeenCreatedInPivateThread(wbContent.id, privateMOC: privateMOC) {
            
            wbContentModel.repostCount = wbContent.reposts_count
            wbContentModel.commentCount = wbContent.comments_count
            wbContentModel.attitudeCount = wbContent.attitudes_count
            
            return wbContentModel
        }
        //create one
        let wbContentModelEntity = NSEntityDescription.entityForName("WBContentModel",inManagedObjectContext: privateMOC)
        let wbContentModel = WBContentModel(entity: wbContentModelEntity!, insertIntoManagedObjectContext: privateMOC)
        
        wbContentModel.wbID = wbContent.id
        wbContentModel.createdDate = dateFormatterFromJSON.dateFromString( wbContent.created_at)
        wbContentModel.text = wbContent.text
        wbContentModel.source = wbContent.source
        wbContentModel.repostCount = wbContent.reposts_count
        wbContentModel.commentCount = wbContent.comments_count
        wbContentModel.attitudeCount = wbContent.attitudes_count
        if isInTimeline { wbContentModel.isInTimeline = true}
        
        if let retweetedWBContent = wbContent.retweeted_status {
            if let reposted = analyseOneWeiboRecordInPivateThread(retweetedWBContent, isInTimeline: false, privateMOC: privateMOC) {
                wbContentModel.repostContent =  reposted
                reposted.addBeRepostedObject(wbContentModel)
            }
        }
        
        for i in 0 ..< wbContent.pic_urls.count {
            let picEntity = NSEntityDescription.entityForName("WBPictureModel",inManagedObjectContext: privateMOC)
            let picModel = WBPictureModel(entity: picEntity!, insertIntoManagedObjectContext: privateMOC)
            
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
        
        if let wbUserModel = getWBUserCreateIfNoneInPivateThread(wbContent.user, privateMOC: privateMOC) {
            wbContentModel.belongToWBUser =  wbUserModel
            wbUserModel.addWbContentsObject(wbContentModel)
        }
        return wbContentModel
    }
    
    func isWeiboHasBeenCreatedInPivateThread(weiboID: Int, privateMOC: NSManagedObjectContext) -> WBContentModel? {
        let request  = NSFetchRequest(entityName: "WBContentModel")
        request.predicate = NSPredicate(format: "wbID = %ld", weiboID)
        var wbContentModel = [WBContentModel]()
        
        do{
            wbContentModel = try privateMOC.executeFetchRequest(request) as! [WBContentModel]
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

    func isWeiboHasBeenCreated(weiboID: Int) -> WBContentModel? {
        let privateMOC = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateMOC.parentContext = managedObjectContext
        var wbContentModel: WBContentModel? = nil
        
        privateMOC.performBlockAndWait {
            
            wbContentModel = self.isWeiboHasBeenCreatedInPivateThread(weiboID, privateMOC: privateMOC)
            
            do {
                try privateMOC.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
        return wbContentModel
    }

    func getWBUserCreateIfNoneInPivateThread(wbUser: WBUser?, privateMOC: NSManagedObjectContext) -> WBUserModel? {
        if let weiboUser = wbUser {
            let request  = NSFetchRequest(entityName: "WBUserModel")
            request.predicate = NSPredicate(format: "userID = %ld", weiboUser.id)
            var wbUserModel = [WBUserModel]()
            
            do{
                wbUserModel = try privateMOC.executeFetchRequest(request) as! [WBUserModel]
            }catch{
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
            if wbUserModel.count > 0 {
                //TODO check user information last update time
                
                return wbUserModel[0]
            }else{
                return createWBUserInPivateThread(weiboUser, privateMOC: privateMOC)
            }
        }
        return nil
    }
    
    func createWBUserInPivateThread(wbUser: WBUser, privateMOC: NSManagedObjectContext) -> WBUserModel{
        //create one
        let wbUserModelEntity = NSEntityDescription.entityForName("WBUserModel",inManagedObjectContext: privateMOC)
        let wbUserModel = WBUserModel(entity: wbUserModelEntity!, insertIntoManagedObjectContext: privateMOC)
        
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

    
    func getWeiboContentWith(weiboID id: Int) -> WBContentModel? {
        let request  = NSFetchRequest(entityName: "WBContentModel")
        request.predicate = NSPredicate(format: "wbID = %ld", id)
        var weibos: [WBContentModel]!
        do{
            weibos = try managedObjectContext.executeFetchRequest(request) as! [WBContentModel]
        }catch{
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if weibos.count > 0 {
            return weibos[0]
        }
        return nil
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