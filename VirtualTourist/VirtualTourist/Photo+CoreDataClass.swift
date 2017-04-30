//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Aniket Ghode on 30/04/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    convenience init(imageData: NSData, name: String, context: NSManagedObjectContext) {
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.imageData = imageData
            self.name = name
        } else {
            fatalError("Unable to find entity name!")
        }
    }
}
