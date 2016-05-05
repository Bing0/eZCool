//
//  WBPictureModel+CoreDataProperties.swift
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

extension WBPictureModel {

    @NSManaged var index: NSNumber?
    @NSManaged var pictureHigh: NSData?
    @NSManaged var pictureLow: NSData?
    @NSManaged var pictureMedium: NSData?
    @NSManaged var picURLHigh: String?
    @NSManaged var picURLLow: String?
    @NSManaged var picURLMedium: String?
    @NSManaged var belongToWBContent: WBContentModel?

}
