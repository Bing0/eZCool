//
//  WBUserModel+CoreDataProperties.swift
//  eZCool
//
//  Created by BinWu on 5/2/16.
//  Copyright © 2016 BinWu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WBUserModel {

    @NSManaged var userID: NSNumber?
    @NSManaged var profileURL: String?
    @NSManaged var createdDate: NSDate?
    @NSManaged var avatarHD: NSData?
    @NSManaged var avatarHDUpdateDate: NSDate?
    @NSManaged var isVerified: NSNumber?
    @NSManaged var name: String?
    @NSManaged var screenName: String?
    @NSManaged var verifiedReason: String?
    @NSManaged var lastUpdateDate: NSDate?
    @NSManaged var avatarHDURL: String?
    @NSManaged var wbContents: NSSet?

    @NSManaged func addWbContentsObject(value:WBContentModel)
    @NSManaged func removeWbContentsObject(value:WBContentModel)
    @NSManaged func addWbContents(value:Set<WBContentModel>)
    @NSManaged func removeWbContents(value:Set<WBContentModel>)
}
