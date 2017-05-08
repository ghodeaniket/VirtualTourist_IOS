//
//  MapPinsViewController.swift
//  VirtualTourist
//
//  Created by Aniket Ghode on 4/26/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapPinsViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletionHint: UILabel!
    @IBOutlet weak var deletionHintBottomConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    
    var stack: CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set intital editing behaviour and add editButton to Navigation Bar
        setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = editButtonItem
        
        // Hide the deletion hint label
        self.deletionHintBottomConstraint.constant -= (self.deletionHint.bounds.size.height)
        
        // Try to retrieve and add annotations to the map
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        if let pins = try? stack.context.fetch(fetchRequest) as! [Pin] {
            print("number of pins \(pins.count)")
            mapView.addAnnotations(pins.map({
                $0.makeAnnotation()
            }))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // restore
        if let dict = UserDefaults.standard.dictionary(forKey: "mapRegion01"),
            let myRegion = MKCoordinateRegion(decode: dict as [String : AnyObject]) {
            mapView.setRegion(myRegion, animated: true)
            // do something with myRegion
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Save
        UserDefaults.standard.set(mapView.region.encode, forKey: "mapRegion01")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        // Display deletion hint label when in editing mode
        UIView.animate(withDuration: 0.5) {
            self.deletionHintBottomConstraint.constant = editing ? 0 : -(self.deletionHint.bounds.size.height)
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: IBActions
    
    // Method invoked with long press gesture
    @IBAction func tappedOnMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            
            // Get the tapped location, which is a CGPoint
            let location = sender.location(in: mapView)
            // A CLLocationCoordinate2D is needed to set the coordinate for the annotation
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            // Save the pin in core data and add annotation to the map
            stack.performBackgroundBatchOperation { (workerContext) in
                _ = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: workerContext)
                
            }
            mapView.addAnnotation(annotation)
        }

    }
}

// MARK: MKMapViewDelegate
extension MapPinsViewController: MKMapViewDelegate {
    
    // Create pin views with animated pin drop
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            print("Annotation was just clicked and must be present on Map.")
            return
        }
        
        // deselect the selected annotation
        mapView.deselectAnnotation(annotation, animated: true)
        
        // get the pin object for selected annotation
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        let epsilon = 0.000000001;
        let coordinate = annotation.coordinate
        
        let fetchPredicate = NSPredicate(format: "latitude > %lf AND latitude < %lf AND longitude > %lf AND longitude < %lf",
                                         coordinate.latitude - epsilon,  coordinate.latitude + epsilon,
                                         coordinate.longitude - epsilon, coordinate.longitude + epsilon)
        
        fetchRequest.predicate = fetchPredicate
        
        if let pins = try? stack.context.fetch(fetchRequest) as! [NSManagedObject] {
            if let pin = pins.first {
                if isEditing {
                    // Delete pin from map and core data if in edit mode
                    stack.context.delete(pin)
                    mapView.removeAnnotation(annotation)
                } else {
                    
                    // transition to the photos view controller
                    let vc = storyboard?.instantiateViewController(withIdentifier: "photosViewController") as! PhotoAlbumViewController
                    vc.pin = pin as? Pin
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
    }
}
