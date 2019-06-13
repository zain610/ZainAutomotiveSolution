//
//  ViewCarsTableViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 04/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseUI


class ViewCarsTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {
    
    //User variables
    var uid:String = ""
    var displayName: String = ""
    
    //Image Variable
    var image: UIImage = UIImage()
    
    
    let SECTION_CARS = 0
    let SECTION_NO_CARS = 1
    let CELL_CAR = "carCell"
    let SEGUE_IDENTIFIER = "selectWorkshopSegue"
    let CELL_NO_CAR = "noCarCell"
    
    
    var allCars: [Car] = []
    var filteredCars: [Car] = []
    
    
    //init storage
    var storageRef: StorageReference = Storage.storage().reference()
    var carImagesRef: StorageReference?
//    var allWorkshops: [Workshop] = []
    
    weak var databaseController: DatabaseProtocol?
    
    
    weak var editCar: Car?
    weak var selectedCar: Car?
    
    let searchController = UISearchController(searchResultsController: nil);
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true // hide the back button on next view controller
        let leftNavButton = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleGoogleSignOut))
        self.navigationItem.leftBarButtonItem = leftNavButton
        self.navigationController?.navigationBar.prefersLargeTitles = true

        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        
        let user = Auth.auth().currentUser
        if let user = user {
            self.uid = user.uid
            self.displayName = user.displayName!
        }
        
        
        //Use firstName so the title may say "Zain's garage than Zain Shroff's Garage
        let firstName = self.displayName.split(separator: " ", maxSplits: 10, omittingEmptySubsequences: false)[0]
        print(firstName)
        self.navigationItem.title = "\(String(describing: firstName.capitalized))'s Garage"
        
        
      
        
        //implement search in table view controller
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Cars"
        //attach the search controller to the views navigation controller
        navigationItem.searchController = searchController
        //reload table
        tableView.reloadData()
        
        // This view controller decides how the search controller is presented.
        definesPresentationContext = true
        //modify table view
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    func searchBarIsEmpty() -> Bool {
        //check if teh search bar is empty or not.
        //return true if the empty or null
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func isFiltering() -> Bool {
        /* check if the search bar is active and is not empty */
        return searchController.isActive && !searchBarIsEmpty()
    }
    @objc func handleGoogleSignOut() {

        
        do {
            try Auth.auth().signOut()
            print("sign out successfully!")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        /*
         Search algorithm for search bar.
         - first check if there is seach currently taking place, that is if teh searchbar is not empty and get the text
         - filter through allcars for each car brand and model checking if the searchtext has the keyword present.
         - If the search bar is active but no keyword, then give back all cars and lastly we reload the tableview.
 */
        if let searchText = searchController.searchBar.text?.lowercased(), searchBarIsEmpty() == false {
            filteredCars = allCars.filter({(car: Car) -> Bool in
                return (car.brand.lowercased().contains(searchText) || car.model.lowercased().contains(searchText))
            })
        }
        else {
            filteredCars = allCars; //return all cars
        }
        tableView.reloadData(); //reload data
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
        //1st section is to list the cars
        //2nd section acts as a default cell when there is no data in the system
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //if user is searching
        if isFiltering() {
            return filteredCars.count
        }
        //if the user is not filtering and should display all cars
        else if isFiltering() == false {
            if section == SECTION_NO_CARS {
                return 1
            }
            return allCars.count
        }
        //else return 1
        else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
         This is the main method we override inorder to display the data we want. So first we check if the section we want to render data for. So SECTION_CARS is for all the cars in the system owned by the user. Then by default the else implies that we are in the second section and thats where we render the default cell
         */
        
        if indexPath.section == SECTION_CARS {
            let carCell = tableView.dequeueReusableCell(withIdentifier: CELL_CAR, for: indexPath) as! CarsTableViewCell
            //        //removing left padding
            carCell.separatorInset = UIEdgeInsets.zero
            carCell.layoutMargins = UIEdgeInsets.init(top: 10, left: 50, bottom: 10, right: 50)
            carCell.layer.borderColor = UIColor.black.cgColor
            carCell.layer.borderWidth = CGFloat(2)
            carCell.layer.cornerRadius = 15
            carCell.layer.masksToBounds = false
            carCell.layer.shadowOffset = CGSize(width: 0, height: 0)
            carCell.layer.shadowColor = UIColor.black.cgColor
            let radius = carCell.contentView.layer.cornerRadius
            carCell.layer.shadowPath = UIBezierPath(roundedRect: carCell.bounds, cornerRadius: radius).cgPath
            carCell.accessoryType = .disclosureIndicator
        
//            carCell.layer.shadowOffset = CGRect(0,0)
            if !self.allCars.isEmpty {
                let car = filteredCars[indexPath.row]
                carCell.carLabel.text = "\(car.brand) \(car.model)"
                carCell.regoLabel.text = "Registration: \(car.registration)"
                
                //Fetch image
                let reference = Storage.storage().reference(withPath: "Cars/\(car.id).jpeg")
                print(reference)
//                let placeholder = UIImage(named: "Jeep.jpg")
                carCell.imageLabel.sd_setImage(with: reference)
                //
                
                print(car.image)
                if car.status == true {
                    carCell.statusLabel.text = "On Going"
                    carCell.statusLabel.textColor = UIColor(displayP3Red: 0.956, green: 0.42, blue: 0.55, alpha: 1.0)
                }
                else {
                    carCell.statusLabel.text = "Available"
                    carCell.statusLabel.textColor = UIColor(displayP3Red: 0.56, green: 1, blue: 0.58, alpha: 1.0)
                    //                carCell.statusLabel.text = "WOW"
                }
                return carCell
            }
            
            //if the there is no cars in the db. Give feedback to the user that there are no cars
            
        }
        if self.allCars.isEmpty {
            let noCarCell = tableView.dequeueReusableCell(withIdentifier: CELL_NO_CAR, for: indexPath) as! NoCarCellTableViewCell
            noCarCell.separatorInset = UIEdgeInsets.zero
            noCarCell.layoutMargins = UIEdgeInsets.zero
            noCarCell.layer.cornerRadius = 10
            noCarCell.layer.masksToBounds = true
            noCarCell.layer.shadowOffset = CGSize(width: 0, height: 0)
            noCarCell.layer.shadowColor = UIColor.black.cgColor
            let radius = noCarCell.contentView.layer.cornerRadius
            noCarCell.layer.shadowPath = UIBezierPath(roundedRect: noCarCell.bounds, cornerRadius: radius).cgPath
            return noCarCell
        }
        //this is to conform that if all else fails we return an empty cell.
        let emptyCell = UITableViewCell()
        return emptyCell
       
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_CARS {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_CARS && !self.allCars.isEmpty {
            /*
             -find the car
             - delete from db
             - find the index of car from allCars remove it
             - this triggers the .remove in firebasecontroller listener on carList
             - play delete animation on the row and reload the table*/
            let car = self.filteredCars[indexPath.row]
            self.databaseController?.deleteCar(car: car)
            //find the index of the car in allCars[]
            let allCarsIndex = self.allCars.firstIndex(of: car)
            //remove the car from allCars[]
            self.allCars.remove(at: (allCarsIndex)!)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
            self.updateSearchResults(for: self.navigationItem.searchController!)
            
        }
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get the section value from the indexpath and preven the defualt value from section 1 to perform the segue
        if indexPath.section == 0 {
            self.selectedCar = self.filteredCars[indexPath.row]
            performSegue(withIdentifier: SEGUE_IDENTIFIER, sender: self)
        }
        
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
            //pass the selected car to the next VC 
            destination.selectedCar = self.selectedCar
        }
    }
    
    //Important to remove the search controller. resolves this issue: Attempting to load the VC while its deallocating. 
    deinit {
        self.searchController.view.removeFromSuperview()
    }
    
    func fetchImage(carId: String) {
        
    }

}
