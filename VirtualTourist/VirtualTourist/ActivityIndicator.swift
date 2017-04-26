//
//  ActivityIndicator.swift
//  VirtualTourist
//
//  Created by Aniket Ghode on 4/26/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import UIKit

class ActivityIndicator: NSObject {
    private var container = UIView()
    private var loadingView = UIView()
    private var activityIndicator = UIActivityIndicatorView()
    
    func startActivityIndicator(_ hostViewController: UIViewController) {
        
        container.tag = 100
        container.frame = hostViewController.view.frame
        container.center = hostViewController.view.center
        container.backgroundColor = UIColor(red: 0.77, green: 0.75, blue: 0.75, alpha: 0.6)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = hostViewController.view.center
        loadingView.backgroundColor = UIColor(red: 0.77, green: 0.75, blue: 0.75, alpha: 0.9)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        activityIndicator.startAnimating()
        hostViewController.view.addSubview(container)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopActivityIndicator(_ hostViewController: UIViewController) {
        activityIndicator.stopAnimating()
        hostViewController.view.viewWithTag(100)?.removeFromSuperview()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> ActivityIndicator {
        struct Singleton {
            static var sharedInstance = ActivityIndicator()
        }
        return Singleton.sharedInstance
    }

}
