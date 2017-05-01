//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Aniket Ghode on 01/05/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    convenience init(imageData: NSData?, imageUrl: String?, context: NSManagedObjectContext) {
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.imageData = imageData
            self.imageUrl = imageUrl
        } else {
            fatalError("Unable to find entity name!")
        }
    }
}
