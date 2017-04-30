//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Aniket Ghode on 30/04/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var name: String?
    @NSManaged public var pin: Pin?

}
