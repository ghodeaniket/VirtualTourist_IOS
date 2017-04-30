//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Aniket Ghode on 30/04/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public class Pin: NSManagedObject {
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            print("Pin with lat \(latitude, longitude) is created ")
        } else {
            fatalError("Unabled to find entity name")
        }        
    }
    
    // MARK: Make Annotation Object
    
    func makeAnnotation() -> MKAnnotation {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
}
