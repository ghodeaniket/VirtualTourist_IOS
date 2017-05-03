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
    
    // Edit Mode to delete selected pins
    // or renew entire collection
    var editMode: Bool! {
        didSet {
            if editMode! {
                newCollectionButton.setTitle("Remove Selected Pictures", for: .normal)
            } else {
                newCollectionButton.setTitle("New Collection", for: .normal)
            }
        }
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
        
        // set edit mode to false until any image is selected
        editMode = false
        // Create the FetchedResultsController

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
    }
    
    func searchFlickrImages() {
        print("core data has no photos")
        
        // disable new collection button
        newCollectionButton.isEnabled = false
        
        FlickrClient.sharedInstance().getFlickerPages(for: pin) { (success, noImageFound, errorString) in
            if noImageFound {
                self.noImagesFoundLabel.isHidden = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create custom Flow Layout
        let space: CGFloat = 3.0
        let wDimension = (view.frame.size.width - (2*space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        // use same size for height and width
        flowLayout.itemSize = CGSize(width: wDimension, height: wDimension)
        
        // check if coredata has photos
        if pin.photos!.count > 0 {
            // no need to fetch fresh new photos
            print("photos from core data \(pin.photos!.count)")
        }
        else {
            // else fetch it from flickr
            searchFlickrImages()
        }
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

    @IBAction func toolBarButtonPressed(_ sender: Any) {
        if editMode {
            // remove photos
            
            if let context = fetchedResultsController?.managedObjectContext, selectedIndexes.count > 0 {
                
                for indexPath in selectedIndexes {
                    
                    let selectedPhoto = fetchedResultsController!.object(at: indexPath) as! Photo
                    context.delete(selectedPhoto)
                    
                }
                
                do {
                    try context.save()
                } catch {
                    print("error saving context.")
                }
                
                newCollectionButton.setTitle("New Collection", for: .normal)
                selectedIndexes = [IndexPath]()
            }
        } else {
            newCollectionButton.isEnabled = false
            if let context = fetchedResultsController?.managedObjectContext {
                //delete all images in core data
                for photo in fetchedResultsController!.fetchedObjects as! [Photo] {
                    context.delete(photo)
                }
                do{
                    try context.save()
                } catch {
                    print("error saving context.")
                }
            }
            
            // save context
            
            // load new photos
            searchFlickrImages()            
        }
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
        cell.activityIndicatorView.startAnimating()
        
        print(photo.imageUrl!)
        
        if let imageData = photo.imageData {
            cell.photoImageView.image = UIImage(data: imageData as Data)
            newCollectionButton.isEnabled = true
        } else {
            if let imageUrl = photo.imageUrl {
                FlickrClient.sharedInstance().getFlickrImage(for: imageUrl, completionHandler: { (success, imageData, errorString) in
                    if success {
                        DispatchQueue.main.async {
                            
                            cell.photoImageView.image = UIImage(data: imageData!)
                            cell.activityIndicatorView.stopAnimating()
                            cell.activityIndicatorView.isHidden = true
                            
                            photo.imageData = imageData! as NSData
                            // as soon as first photo is downloaded enable the new collection button
                            self.newCollectionButton.isEnabled = true
                        }
                    }
                })
            }
        }
        
        // check if the cell is selected and changed the transperency accordingly.
        
        if let _ = selectedIndexes.index(of: indexPath) {
            cell.alpha = 0.5
        } else {
            cell.alpha = 1
        }
        
        return cell
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        
        if let index = selectedIndexes.index(of: indexPath) {
            selectedIndexes.remove(at: index)
            cell.alpha = 1.0
        } else {
            selectedIndexes.append(indexPath)
            cell.alpha = 0.5
        }
        
        //Change UI
        editMode = selectedIndexes.count > 0 ? true : false
        
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

}
