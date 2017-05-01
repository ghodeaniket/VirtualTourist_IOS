//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Aniket Ghode on 4/27/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import Foundation

extension FlickrClient {
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey = "YOUR_API_KEY_HERE"
        
        // MARK: URLs
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        static let APISecret = "8434483b3de9a0ca"
        
    }
    
    struct Flickr {
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Account
        static let Account = "/account"
        static let AccountIDFavoriteMovies = "/account/{id}/favorite/movies"
        static let AccountIDFavorite = "/account/{id}/favorite"
        static let AccountIDWatchlistMovies = "/account/{id}/watchlist/movies"
        static let AccountIDWatchlist = "/account/{id}/watchlist"
        
        // MARK: Authentication
        static let AuthenticationTokenNew = "/authentication/token/new"
        static let AuthenticationSessionNew = "/authentication/session/new"
        
        // MARK: Search
        static let SearchMovie = "/search/movie"
        
        // MARK: Config
        static let Config = "/configuration"
        
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let UserID = "id"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "1125437769264a753fbc108aa9c30ffc"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let MediaType = "media_type"
        static let MediaID = "media_id"
        static let Favorite = "favorite"
        static let Watchlist = "watchlist"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {

        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Flickr API
        static let Photo = "photo"
        static let Photos = "photos"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
        
    }

}
