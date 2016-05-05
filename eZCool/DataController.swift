//
//  DataController.swift
//  eZCool
//
//  Created by BinWu on 5/1/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import Foundation
import CoreData
//
//struct Constant {
//    static let ProfileImageUpdateInterval = 3600
//    
//}

class DataController {
//    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
//    
//    
//    func downloadProfileImage(link: String, userID: Int, forCell cell: BaseTypeTableViewCell) {
//        let url = NSURL(string: link)!
//        cell.profileURL = url
//        
//        if let imageData = searchUserProfileImage(userID)?.pic {
//            if url == cell.profileURL {
//                cell.profileImage.setCutImage(UIImage(data: imageData)!)
////                print("Has profile image for user \(userID)")
//                return
//            }else{
//                print("~~~wrong profile image!!!~~~")
//            }
//        }
////        print("No  profile image for user \(userID)")
//        
//        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
//        dispatch_async(dispatch_get_global_queue(qos, 0)) {
//            let imageData = NSData(contentsOfURL: url)
//            dispatch_async(dispatch_get_main_queue()){
//                if imageData != nil {
//                    //store the image
//                    self.storeProfileImage(imageData!, link: link, forUserID: userID)
//                    //try to display the image
//                    if url == cell.profileURL {
//                        cell.profileImage.setCutImage(UIImage(data: imageData!)!)
//                    }else{
//                        print("~~~wrong profile image~~~")
//                    }
//                }
//            }
//        }
//    }
//    
//    func storeProfileImage(image: NSData, link: String,forUserID userID: Int) {
//        if let wbUser = searchUser(userID) {
//            if let pic = wbUser.usersPic {
//                pic.pic = image
//                pic.url = link
//                print("Update image for user \(userID)")
//            }else{
//                let picEntity = NSEntityDescription.entityForName("Picture",inManagedObjectContext: managedObjectContext)
//                let pic = Picture(entity: picEntity!, insertIntoManagedObjectContext: managedObjectContext)
//                pic.pic = image
//                pic.url = link
//                pic.updateTime = NSDate()
//                pic.belongToWBUser = wbUser
//                wbUser.usersPic = pic
//                print("Create image for user \(userID)")
//            }
//        }else{
//            let picEntity = NSEntityDescription.entityForName("Picture",inManagedObjectContext: managedObjectContext)
//            let pic = Picture(entity: picEntity!, insertIntoManagedObjectContext: managedObjectContext)
//            let wbUserEntity = NSEntityDescription.entityForName("WBUserInfo",inManagedObjectContext: managedObjectContext)
//            let wbUser = WBUserInfo(entity: wbUserEntity!, insertIntoManagedObjectContext: managedObjectContext)
//            
//            pic.pic = image
//            pic.url = link
//            pic.updateTime = NSDate()
//            pic.belongToWBUser = wbUser
//            wbUser.usersPic = pic
//            wbUser.userID = userID
//            print("Create user and image \(userID)")
//        }
//        saveData()
//    }
//    
//    func searchUser(userID: Int) -> WBUserInfo? {
//        let request  = NSFetchRequest(entityName: "WBUserInfo")
//        request.predicate = NSPredicate(format: "userID = %ld", userID)
//        
//        var wbUser = [WBUserInfo]()
//        do{
//            wbUser = try managedObjectContext.executeFetchRequest(request) as! [WBUserInfo]
//        }catch{
//            let nserror = error as NSError
//            print("Unresolved error \(nserror), \(nserror.userInfo)")
//            abort()
//        }
//        if wbUser.count > 0{
//            return wbUser[0]
//        }
//        return nil
//    }
//    
//    func searchUserProfileImage(userID: Int) -> Picture? {
//        if let wbUser = searchUser(userID) {
//            if let pic = wbUser.usersPic {
//                if let oldDate = pic.updateTime {
//                    if Int(NSDate().timeIntervalSinceDate(oldDate)) <= Constant.ProfileImageUpdateInterval {
//                        return pic
//                    }
//                }
//            }
//        }
//        return nil
//    }
//    
//    
//    
//    func downloadWeiboImage(link: String, weiboID: Int, imageIndex: Int, forCell cell: BaseTypeTableViewCell) {
//        let url = NSURL(string: link)!
//        cell.wbImageURL[imageIndex] = url
//        
//        if let imageData = searchWeiboImage(weiboID, imageIndex: imageIndex)?.pic {
//            if url == cell.wbImageURL[imageIndex] {
//                cell.originalImageCollection[imageIndex].setCutImage(UIImage(data: imageData)!)
//                print("Has weibo image for weibo \(weiboID) index: \(imageIndex)")
//                return
//            }else{
//                print("~~~wrong weibo image!!!~~~")
//            }
//        }
//        print("No  weibo image for weibo \(weiboID) index: \(imageIndex)")
//        
//        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
//        dispatch_async(dispatch_get_global_queue(qos, 0)) {
//            let imageData = NSData(contentsOfURL: url)
//            dispatch_async(dispatch_get_main_queue()){
//                if imageData != nil {
//                    //store the image
//                    self.storeWeiboImage(imageData!, link: link, weiboID: weiboID, imageIndex: imageIndex)
//                    //try to display the image
//                    if url == cell.wbImageURL[imageIndex] {
//                        cell.originalImageCollection[imageIndex].setCutImage(UIImage(data: imageData!)!)
//                    }else{
//                        print("~~~wrong profile image~~~")
//                    }
//                }
//            }
//        }
//    }
//    
//    
//    func searchWeiboImage(weiboID: Int, imageIndex: Int) -> Picture? {
//        if let wbDetail = searchWeibo(weiboID) {
//            if let pics = wbDetail.hasPics {
//                if imageIndex < pics.count {
//                    return pics.allObjects[imageIndex] as? Picture
//                }
//            }
//        }
//        return nil
//    }
//    
//    func storeWeiboImage(imageData: NSData, link: String, weiboID: Int, imageIndex: Int) {
//        if let wbDetail = searchWeibo(weiboID) {
//            if let pics = wbDetail.hasPics {
////                
////                pic.pic = image
////                pic.url = link
////                print("Update image for user \(userID)")
//            }else{
//                let picEntity = NSEntityDescription.entityForName("Picture",inManagedObjectContext: managedObjectContext)
//                let pic = Picture(entity: picEntity!, insertIntoManagedObjectContext: managedObjectContext)
//                pic.pic = imageData
//                pic.url = link
//                pic.updateTime = NSDate()
//                pic.belongToWB = wbDetail
//                wbDetail.addHasPicsObject(pic)
//                print("Create image for weibo \(weiboID) index \(imageIndex)")
//            }
//        }else{
//            let picEntity = NSEntityDescription.entityForName("Picture",inManagedObjectContext: managedObjectContext)
//            let pic = Picture(entity: picEntity!, insertIntoManagedObjectContext: managedObjectContext)
//            let wbDetailEntity = NSEntityDescription.entityForName("WBDetail",inManagedObjectContext: managedObjectContext)
//            let wbDetail = WBDetail(entity: wbDetailEntity!, insertIntoManagedObjectContext: managedObjectContext)
//            
//            pic.pic = imageData
//            pic.url = link
//            pic.updateTime = NSDate()
//            pic.belongToWB = wbDetail
//            wbDetail.addHasPicsObject(pic)
//            wbDetail.wbID = weiboID
//            print("Create image \(weiboID) index \(imageIndex)")
//        }
//        saveData()
//        
//    }
//    
//    func searchWeibo(weiboID: Int) -> WBDetail? {
//        let request  = NSFetchRequest(entityName: "WBDetail")
//        request.predicate = NSPredicate(format: "wbID = %ld", weiboID)
//        
//        var wbDetail = [WBDetail]()
//        do{
//            wbDetail = try managedObjectContext.executeFetchRequest(request) as! [WBDetail]
//        }catch{
//            let nserror = error as NSError
//            print("Unresolved error \(nserror), \(nserror.userInfo)")
//            abort()
//        }
//        if wbDetail.count > 0{
//            return wbDetail[0]
//        }
//        return nil
//    }
//    
//    
//    func saveData(){
//        if managedObjectContext.hasChanges {
//            do {
//                try managedObjectContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
//                abort()
//            }
//        }
//    }
    
}