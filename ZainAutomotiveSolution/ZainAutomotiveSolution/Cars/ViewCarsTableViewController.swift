//
//  ViewCarsTableViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 04/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit


class ViewCarsTableViewController: UITableViewController, DatabaseListener {
    
    
    
    
    
    let SECTION_CARS = 0
    let CELL_CAR = "carCell"
    let SEGUE_IDENTIFIER = "selectWorkshopSegue"
    
    
    var allCars: [Car] = []
    var filteredCars: [Car] = []
    
//    var allWorkshops: [Workshop] = []
    
    weak var databaseController: DatabaseProtocol?
    
    weak var editCar: Car?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Cars"
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented.
        definesPresentationContext = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(), searchText.count > 0 {
            filteredCars = allCars.filter({(car: Car) -> Bool in
                return car.brand.lowercased().contains(searchText)
            })
        }
        else {
            filteredCars = allCars;
        }
        
        tableView.reloadData();
    }

    
    var listenerType = ListenerType.cars
    func onCarListChange(change: DatabaseChange, cars: [Car]) {
        allCars = cars
        //update search results here!
        updateSearchResults(for: navigationItem.searchController!)
    }
    //change listener type to workshop to fetch workshop data
    func onWorkshopListChange(change: DatabaseChange, workshops: [Workshop]) {
        //this will never be called!
        return
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == SECTION_CARS {
            return allCars.count
        }
        else {
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_CARS {
            let carCell = tableView.dequeueReusableCell(withIdentifier: CELL_CAR, for: indexPath) as! CarsTableViewCell
            let car = filteredCars[indexPath.row]
            
            carCell.carLabel.text = "\(car.brand) \(car.model)"
            carCell.regoLabel.text = "Registration: \(car.registration) Current Status:\(car.status)"
            
            return carCell
        }
        let carCell = tableView.dequeueReusableCell(withIdentifier: CELL_CAR, for: indexPath) as! CarsTableViewCell
        
        carCell.carLabel.text = "Please try again! Nothing Found!"
        return carCell
        
        
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            print(action)
            print(indexPath)
            let car = self.filteredCars[indexPath.row]
            self.databaseController?.deleteCar(car: car)
            self.filteredCars.remove(at: indexPath.row)
            //find the index of the car in allCars[]
            let allCarsIndex = self.allCars.firstIndex(of: car)
            //remove the car from allCars[]
            self.allCars.remove(at: (allCarsIndex)!)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
            
            
        }
//        let update = UITableViewRowAction(style: .normal, title: "Update") { (action, indexPath) in
//            print(action, indexPath)
//            self.performSegue(withIdentifier: "updateCarSegue", sender: self)
//        }
        return [delete]
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SEGUE_IDENTIFIER, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //This is for sending data while adding a car
        if segue.identifier == "addCarSegue" {
            let destination = segue.destination as! AddCarViewController
        }
//        //send data while updating the car. Send car details
        if segue.identifier == "updateCarSegue" {
            let destination = segue.destination as! AddCarViewController
            let indexPaths = self.tableView!.indexPathsForSelectedRows!
            let indexPath = indexPaths[0] as NSIndexPath
            destination.editCar = filteredCars[indexPath.row]
        }
        if segue.identifier == "selectWorkshopSegue" {
            let destination = segue.destination as! ViewWorkshopsTableViewController
            print("Going to View Workshops")
        }
    }
    

}
