//
//  WBContentModel+CoreDataProperties.swift
//  eZCool
//
//  Created by Bin on 5/23/16.
//  Copyright © 2016 BinWu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WBContentModel {

    @NSManaged var attitudeCount: NSNumber?
    @NSManaged var cellHeight: NSNumber?
    @NSManaged var commentCount: NSNumber?
    @NSManaged var createdDate: NSDate?
    @NSManaged var isInTimeline: NSNumber?
    @NSManaged var repostCount: NSNumber?
    @NSManaged var source: String?
    @NSManaged var text: String?
    @NSManaged var wbID: NSNumber?
    @NSManaged var belongToWBUser: WBUserModel?
    @NSManaged var beReposted: NSSet?
    @NSManaged var pictures: NSSet?
    @NSManaged var repostContent: WBContentModel?
    @NSManaged var hasComment: NSSet?

    @NSManaged func addPicturesObject(value:WBPictureModel)
    @NSManaged func removePicturesObject(value:WBPictureModel)
    @NSManaged func addPictures(value:Set<WBPictureModel>)
    @NSManaged func removePictures(value:Set<WBPictureModel>)
    
    @NSManaged func addBeRepostedObject(value:WBContentModel)
    @NSManaged func removeBeRepostedObject(value:WBContentModel)
    @NSManaged func addBeReposted(value:Set<WBContentModel>)
    @NSManaged func removeBeReposted(value:Set<WBContentModel>)
    
}
