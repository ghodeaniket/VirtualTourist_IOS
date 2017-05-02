//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Aniket Ghode on 4/27/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import UIKit

class FlickrClient: NSObject {
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // Number of photos per pin
    let photosPerPage = 21
    private let maxFlickrResults = 4000
    
    // Upper Limit of Pages
    private var maxFlickrPages: Int { return maxFlickrResults / photosPerPage }
    
    var stack: CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: GET
    
    func taskForGETMethod(parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {

        var parametersWithKeys = parameters
        
        /* 1. Set the parameters */
        parametersWithKeys[ParameterKeys.APIKey] = FlickrParameterValues.APIKey as AnyObject
        
        /* 2/3. Build the URL, Configure the request */
        let request = URLRequest(url: flickrURLFromParameters(parametersWithKeys as [String : AnyObject]))
        
        /* 4. Make the request */
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // task to download image from Url
    
    func taskForDownloadImage(_ urlString: String, competionHandler: @escaping (_ data: Data?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            
            if let error = downloadError {                
                competionHandler(nil, error)
            } else {
                competionHandler(data, nil)
            }
        })
        
        task.resume()
        
        return task
        
    }

    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.APIScheme
        components.host = Constants.APIHost
        components.path = Constants.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

    
    // given raw JSON, return a usable Flickr Photo array object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // Get a random page inside flickr results
    func getRandomPage(_ totalPages: Int) -> Int {
        // If there is more than one page, ignore the last page
        // the last page may contain less then 'photosPerPage' Images
        var pages = totalPages
        if totalPages > 1 {
            pages = totalPages - 1
        }
        // Limit Pages to match upper limit of flickr results
        let maxPage = min(pages, maxFlickrPages)
        let randomPage = Int(arc4random_uniform(UInt32(maxPage))) + 1
        return randomPage
    }
   
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}
