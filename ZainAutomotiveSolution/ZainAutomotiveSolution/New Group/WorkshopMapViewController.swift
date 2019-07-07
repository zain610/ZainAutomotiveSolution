//
//  WorkshopMapViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 08/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Cluster


class WorkshopMapViewController: UIViewController, DatabaseListener {
    
    @IBOutlet weak var mapView: MKMapView!
    
    final let LIST_SEGUE = "displayWorkshopTableSegue"
    
    var allWorkshops: [Workshop] = []
    
    weak var databaseController: DatabaseProtocol?

    let locationManager = CLLocationManager()
    
    var selectedCar: Car?
    
    //not used
    let clusterManager: ClusterManager = ClusterManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        checkLocationService()
        
        mapView.delegate = self
        
        let rightNavigationItem = UIBarButtonItem(image: UIImage(named: "listIcon"), style: .plain, target: self, action: #selector(switchToListView))
        self.navigationItem.rightBarButtonItem = rightNavigationItem
        self.navigationItem.hidesBackButton = true
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    var listenerType = ListenerType.workshops
    func onCarListChange(change: DatabaseChange, cars: [Car]) {
        //This will never be called
        return
    }
    func onWorkshopListChange(change: DatabaseChange, workshops: [Workshop]) {
        allWorkshops = workshops
        //add markers to the map after fetching all workshop data
        addAnnotation()
        
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func centerViewOnLocation() {
        //get user location - currently it will simulate a value instead of the actual user's value
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
            
        }
    }
    func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            //setup location manager
            setUpLocationManager()
            checkLocationAuthorization()
        }
        else {
            //show alert telling the user to go switch on location services
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnLocation()
            locationManager.startUpdatingLocation()
            
            break
        case .authorizedAlways:
            break
        case .denied:
            //show alert asking them to manually switch on navigation services
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        }
    }
    private func addAnnotation() {
        //add important information to marker. so when user selects the marker we can easily identify the workshop.
        
        print("All workshops = \(self.allWorkshops)")
        allWorkshops.forEach { (workshop) in
            print("id = \(workshop.id)")
            print("name = \(workshop.name)")
            print("Lat and long = \(workshop.lat), \(workshop.long)")
            let annotation = Annotation()
            annotation.title = "\(workshop.name)"
            annotation.coordinate = CLLocationCoordinate2DMake(workshop.lat, workshop.long)
            
            clusterManager.add(annotation)
            mapView.addAnnotation(annotation)
        }
    }
    @objc func switchToListView() {
        print("Go to table view")
        self.navigationController?.popViewController(animated: true)
    }
}

extension WorkshopMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //called when user moves, so update the pointer whne the user moves
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //check if the location permissions gives to us is the same or changed.
        checkLocationAuthorization()
    }
}
extension WorkshopMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
            let rightButton = UIButton(type: .detailDisclosure)
            annotationView!.rightCalloutAccessoryView = rightButton
        }
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
        else {
            annotationView?.image = UIImage(named: "workshopMarker")
        }
        annotationView?.canShowCallout = true

        return annotationView
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let workshopSelectedCoordinate = view.annotation?.coordinate
        var workshopSelected: Workshop = getWorkshopByCoordinates(workshopCoordinates: workshopSelectedCoordinate!)
        
        
        
    }
    private func getWorkshopByCoordinates(workshopCoordinates: CLLocationCoordinate2D) -> Workshop {
        var foundWorkshop: Workshop = Workshop()
        self.allWorkshops.forEach { (workshop) in
            if workshop.lat == workshopCoordinates.latitude && workshop.long == workshopCoordinates.longitude {
                foundWorkshop = workshop
                return
            }
        }
        return foundWorkshop
    }
}
