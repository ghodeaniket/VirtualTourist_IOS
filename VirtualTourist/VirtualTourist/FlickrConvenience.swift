//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Aniket Ghode on 4/27/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import UIKit
import CoreData

extension FlickrClient {
    
    
    
    func getFlickerPages(forLocation latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool, _ imageNotFound: Bool, _ errorString: String?) -> Void) {
        
        let methodParameters = [
            ParameterKeys.Method: FlickrParameterValues.SearchMethod,
            ParameterKeys.BoundingBox: bboxString(latitude, longitude),
            ParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
            ParameterKeys.Extras: FlickrParameterValues.MediumURL,
            ParameterKeys.Format: FlickrParameterValues.ResponseFormat,
            ParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback,
            ParameterKeys.PerPage: String(photosPerPage)
        ]

        _ = taskForGETMethod(parameters: methodParameters as [String : AnyObject], completionHandlerForGET: { (results, error) in
            if let error = error {
                print(error)
                completionHandler(false, false, "Unknown error, Flickr API")
                return
            }
            guard let photosDictionary = results?[JSONResponseKeys.Photos] as? [String: AnyObject],
                let totalPages = photosDictionary[JSONResponseKeys.Pages] as? Int else {
                    print("\(JSONResponseKeys.Photos) not found in \(String(describing: results))")
                    completionHandler(false, false, "Unknown error, Flickr API")
                    return
            }
            
            if totalPages > 0 {
                self.getFlickrUrls(forLocation: latitude, longitude: longitude, with: self.getRandomPage(totalPages), methodParameters: methodParameters as [String : AnyObject], completionHandler: completionHandler)
                
            } else {
                completionHandler(false, true, "No Image found at current location")
            }
            
        })
    }
    
    func getFlickrUrls(forLocation latitude: Double, longitude: Double, with pageNumber: Int, methodParameters: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ imageNotFound: Bool, _ errorString: String?) -> Void) {
        
        var parametersWithPageNumber = methodParameters
        parametersWithPageNumber[ParameterKeys.Page] = String(pageNumber) as AnyObject
        
        _ = taskForGETMethod(parameters: parametersWithPageNumber, completionHandlerForGET: { (results, error) in
            if let error = error {
                print(error)
                completionHandler(false, false, "Unknown error, Flickr API")
                return
            }
            
            guard let photosDictionary = results?[JSONResponseKeys.Photos] as? [String: AnyObject],
                let photosArray = photosDictionary[JSONResponseKeys.Photo] as? [[String: AnyObject]] else {
                completionHandler(false, false, "Unknown error, Flickr API")
                return
            }
            
            // Images found for location?
            if photosArray.count == 0 {
                completionHandler(true, true, nil)
                return
            } else {
                self.stack.performBackgroundBatchOperation { (workerContext) in
                    
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
                    
                    let predicate = NSPredicate(format: "latitude = %@ && longitude = %@", argumentArray: [latitude, longitude])
                    fetchRequest.predicate = predicate
                    
                    // Get the Pin object in background context to form relationship between Photo and Pin objects
                    
                    if let pins = try? workerContext.fetch(fetchRequest) as! [Pin] {
                        if let pin = pins.first {
                            for photoDictionary in photosArray {
                                
                                // Create photo objects for each image in the flickr result
                                // Save the image url and link the photos to the pin
                                
                                guard let imageURLString = photoDictionary[JSONResponseKeys.MediumURL] as? String else {
                                    completionHandler(false, false, "Unknown error, Flickr API")
                                    return
                                }
                                let photo = Photo(imageData: nil, imageUrl: imageURLString, context: workerContext)
                                photo.pin = pin
                            }
                        }
                    }
                }
                completionHandler(true, false, nil)
            }

        })
        
    }
    
    func getFlickrImage(for url: String, completionHandler: @escaping (_ success: Bool, _ imageData: Data?, _ errorString: String?) -> Void){
        _ = taskForDownloadImage(url, competionHandler: { (data, error) in
            if let error = error {
                print(error)
                completionHandler(false, nil, "Error downloading image.")
                return
            } else {
                let imageData = NSData(data: data!) as Data
                print("taskForDownloadImage is invoked")
                completionHandler(true, imageData, nil)
            }
        })
    }
    
    private func bboxString(_ latitude: Double, _ longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    
}
