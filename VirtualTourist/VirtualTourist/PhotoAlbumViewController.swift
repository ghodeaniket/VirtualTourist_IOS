//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Aniket Ghode on 4/26/17.
//  Copyright © 2017 Aniket Ghode. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    var pin: Pin!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImagesFoundLabel: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    // MARK: Properties
    
    var stack: CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            collectionView.reloadData()
        }
    }
    
    // MARK: Initializers
    
    
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMapOnLocation(locationPin: pin)
        
        // Create a fetchrequest
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let sortDescriptors = [NSSortDescriptor(key: "imageUrl", ascending: true)]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let pred = NSPredicate(format: "pin = %@", argumentArray: [pin!])
        
        fetchRequest.predicate = pred
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        FlickrClient.sharedInstance().getFlickerPages(for: pin) { (success, noImageFound, errorString) in
            if success {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create custom Flow Layout
        let space: CGFloat = 3.0
        let wDimension = (view.frame.size.width - (2*space)) / 3.0
        let hDimension = (view.frame.size.height - (2*space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: wDimension, height: wDimension)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let sections = self.fetchedResultsController?.sections?.count ?? 0
        
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController?.sections![section]
        print(sectionInfo!.numberOfObjects)
        return sectionInfo!.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! PhotoCollectionViewCell
        
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        cell.photoImageView.image = #imageLiteral(resourceName: "placeholder")
        print(photo.imageUrl!)
        return cell
    }
}

// MARK: - PhotoAlbumViewController (Fetches)

extension PhotoAlbumViewController {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
}


// MARK: - CoreDataTableViewController: NSFetchedResultsControllerDelegate

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        print("Did change section.")
        switch type {
        case .insert:
            
            self.collectionView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
            
        case .delete:
            self.collectionView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
            
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type{
            
        case .insert:
            print("Inserting an item")
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            print("Deleting an item")
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            print("Updating an item.")
            updatedIndexPaths.append(indexPath!)
            updatedIndexPaths.append(newIndexPath!)
            break
        case .move:
            print("Moving an item.")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                print("insertItem in controllerDidChangeContent")
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                print("deleteItem in controllerDidChangeContent")
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: { (success) -> Void in
            
            if (success) {
                print("success")
                self.insertedIndexPaths = [IndexPath]()
                self.deletedIndexPaths = [IndexPath]()
                self.updatedIndexPaths = [IndexPath]()
                
            }
            
        })

    }

}
