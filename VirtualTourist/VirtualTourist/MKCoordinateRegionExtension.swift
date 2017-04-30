//
//  MKCoordinateRegionExtension.swift
//  VirtualTourist
//
//  Created by Aniket Ghode on 30/04/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import MapKit

extension MKCoordinateRegion {
    
    var encode:[String: AnyObject] {
        let centerDictionary = ["latitude": self.center.latitude,
                                "longitude": self.center.longitude]
        let spanDictionary = ["latitudeDelta": self.span.latitudeDelta,
                              "longitudeDelta": self.span.longitudeDelta]
        return ["center": centerDictionary as AnyObject,
                "span": spanDictionary as AnyObject]
    }
    
    init?(decode: [String: AnyObject]) {
        
        guard let center = decode["center"] as? [String: AnyObject],
            let latitude = center["latitude"] as? Double,
            let longitude = center["longitude"] as? Double,
            let span = decode["span"] as? [String: AnyObject],
            let latitudeDelta = span["latitudeDelta"] as? Double,
            let longitudeDelta = span["longitudeDelta"] as? Double
            else { return nil }
        
        
        self.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
}

