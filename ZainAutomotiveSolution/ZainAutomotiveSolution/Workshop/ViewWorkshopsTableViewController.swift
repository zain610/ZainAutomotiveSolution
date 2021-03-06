//
//  ViewWorkshopsTableViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 09/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit

class ViewWorkshopsTableViewController: UITableViewController, DatabaseListener {
    
    

    
    let SECTION_WORKSHOPS = 0
    let CELL_WORKSHOP = "workshopCell"
    final let SEGUE_IDENTIFIER = "selectDateAndTimeSegue"
    let MAP_SEGUE = "displayMapSegue"
    
    var allWorkshops: [Workshop] = []
    var filteredWorkshops: [Workshop] = []
    
    var selectedCar: Car?
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        
        
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Workshops"
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
        
        let rightSideOptionItem = UIBarButtonItem(image: UIImage(named: "mapIcon"), style: .plain, target: self, action: #selector(switchToMapView))
        self.navigationItem.rightBarButtonItem = rightSideOptionItem
        self.navigationItem.title = "Select a Workshop"
        
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
            filteredWorkshops = allWorkshops.filter({(workshop: Workshop) -> Bool in
                return workshop.name.lowercased().contains(searchText)
            })
        }
        else {
            filteredWorkshops = allWorkshops;
        }
        
        self.tableView.reloadData();
    }
    
    var listenerType = ListenerType.workshops
    func onCarListChange(change: DatabaseChange, cars: [Car]) {
        //This will never be called 
        return
    }
    func onWorkshopListChange(change: DatabaseChange, workshops: [Workshop]) {
        allWorkshops = workshops
        //update search items here
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == SECTION_WORKSHOPS {
            return allWorkshops.count
        }
        else {
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_WORKSHOPS {
            let workshop_cell = tableView.dequeueReusableCell(withIdentifier: CELL_WORKSHOP, for: indexPath) as! WorkShopTableViewCell
            let workshop = allWorkshops[indexPath.row]
            
            print("Name -> \(workshop.name)")
            print("Address -> \(workshop.address)")
            print("Location -> \(workshop.lat) , \(workshop.long)")
            
            workshop_cell.nameLabel.text = "\(workshop.name)"
            workshop_cell.addressLabel.text = "\(workshop.address)"
            workshop_cell.ratingLabel.rating = workshop.rating
            workshop_cell.accessoryType = .disclosureIndicator

            
            
            
            return workshop_cell
        }
        let workshopCell = tableView.dequeueReusableCell(withIdentifier: CELL_WORKSHOP, for: indexPath) as! WorkShopTableViewCell
        
        workshopCell.nameLabel.text = "Please try again! Nothing Found!"
        return workshopCell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SEGUE_IDENTIFIER, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_IDENTIFIER {
            let destination = segue.destination as! SelectDateAndTimeViewController
            print("Going to select date and time")
            destination.selectedCar = self.selectedCar
        }
        if segue.identifier == MAP_SEGUE {
            print("Going to map view ")
            let destination = segue.destination as! WorkshopMapViewController
            destination.selectedCar = self.selectedCar
        }
    }
    @objc func switchToMapView() {
        print("Go to map view")
        performSegue(withIdentifier: MAP_SEGUE, sender: self)
    }
    
}
