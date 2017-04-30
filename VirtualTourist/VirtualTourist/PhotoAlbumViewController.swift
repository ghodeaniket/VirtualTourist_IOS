//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Aniket Ghode on 4/26/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    var pin: Pin!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImagesFoundLabel: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMapOnLocation(locationPin: pin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create custom Flow Layout
        let space: CGFloat = 3.0
        let wDimension = (view.frame.size.width - (2*space)) / 3.0
        let hDimension = (view.frame.size.height - (2*space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: wDimension, height: hDimension)
    }
    
    func centerMapOnLocation(locationPin: Pin) {
        let regionRadius: CLLocationDistance = 1000
        
        let locationCoordinate = CLLocationCoordinate2DMake(locationPin.latitude, locationPin.longitude)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(locationCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        
        mapView.addAnnotation(annotation)
        
    }
    @IBAction func removePhotosFromCollection(_ sender: Any) {
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! PhotoCollectionViewCell
        return cell
    }
}
