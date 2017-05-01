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
    
    
    
    func getFlickerPages(for pin: Pin, completionHandler: @escaping (_ success: Bool, _ imageNotFound: Bool, _ errorString: String?) -> Void) {
        
        let methodParameters = [
            ParameterKeys.Method: FlickrParameterValues.SearchMethod,
            ParameterKeys.BoundingBox: bboxString(pin.latitude, pin.longitude),
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
                self.getFlickrUrls(for: pin, with: self.getRandomPage(totalPages), methodParameters: methodParameters as [String : AnyObject], completionHandler: completionHandler)
            } else {
                completionHandler(false, true, "No Image found at current location")
            }
            
        })
    }
    
    func getFlickrUrls(for pin: Pin,with pageNumber: Int, methodParameters: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ imageNotFound: Bool, _ errorString: String?) -> Void) {
        
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
                return
            }
            
            // Images found for location?
            if photosArray.count == 0 {
//                completionHandler(.noImagesFound)
                return
            } else {
                
                self.stack.performBackgroundBatchOperation { (workerContext) in
                    // Create photo objects for each image in the flickr result
                    // Save the image url and link the photos to the pin
                    for photoDictionary in photosArray {
                        guard let imageURLString = photoDictionary[JSONResponseKeys.MediumURL] as? String else {
//                            completionHandler(.failure)
                            return
                        }
                        let photo = Photo(imageData: nil, imageUrl: imageURLString, context: workerContext)
                        photo.pin = pin
                    }
//                    completionHandler(.success)
                }
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
