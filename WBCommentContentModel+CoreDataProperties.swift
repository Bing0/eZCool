//
//  WBCommentContentModel+CoreDataProperties.swift
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

extension WBCommentContentModel {

    @NSManaged var createdDate: NSDate?
    @NSManaged var source: String?
    @NSManaged var text: String?
    @NSManaged var wbCommentID: NSNumber?
    @NSManaged var replyTo: WBCommentContentModel?
    @NSManaged var beRepliedTo: NSSet?
    @NSManaged var belongToWBUser: WBUserModel?
    @NSManaged var belongToWBContent: WBContentModel?

}
