//
//  WorkshopMapViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 08/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit
import MapKit

class WorkshopMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let locationManager = CLLocation()
        
        let initialLocation = CLLocation(latitude:  -37.9105238, longitude: 145.1362182)
        centerMapOnLocation(location: initialLocation)
        
        
        // Do any additional setup after loading the view.
    }
    let regionRadius: CLLocationDistance = 1000
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,latitudinalMeters: regionRadius,longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
