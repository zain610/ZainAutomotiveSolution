//
//  AddCarViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 05/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import ImageRow
import Eureka


class AddCarViewController: FormViewController  {

    
    var progressView: UIProgressView?
    var shouldRemoveProgressView: Bool = true
    
    
    weak var databaseController: DatabaseProtocol?
    
    var allCars: [String: Any] = [String: Any]()
    var carBrands: [String] = [String]()
    var carModels: NSDictionary = NSDictionary()
    var carSeries: NSDictionary = NSDictionary()
    var carYear: [String] = [String]()
    
    var brandValue: String = ""
    var modelValue: String = ""
    var seriesValue: String = ""
    var yearValue: String = ""
    var registrationValue: String = ""
    var imageValue: UIImage = UIImage()
    
    var createCarButton: UIButton = UIButton()
    
    weak var editCar: Car?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationVC = self.navigationController {
            
            // create progress bar with .bar style and add it as subview
            self.progressView = UIProgressView(progressViewStyle: .bar)
            
            navigationVC.navigationBar.addSubview(self.progressView!)
            
            // create constraints
            // NOTE: bottom constraint has 1 as constant value instead of 0; this way the progress bar will look like the one in Safari
            let bottomConstraint = NSLayoutConstraint(item: navigationVC.navigationBar, attribute: .bottom, relatedBy: .equal, toItem: self.progressView!, attribute: .bottom, multiplier: 1, constant: 1)
            let leftConstraint = NSLayoutConstraint(item: navigationVC.navigationBar, attribute: .leading, relatedBy: .equal, toItem: self.progressView!, attribute: .leading, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: navigationVC.navigationBar, attribute: .trailing, relatedBy: .equal, toItem: self.progressView!, attribute: .trailing, multiplier: 1, constant: 0)
            
            // add constraints
            self.progressView!.translatesAutoresizingMaskIntoConstraints = false
            navigationVC.view.addConstraints([bottomConstraint, leftConstraint, rightConstraint])
        }
        progressView!.progress = 0.0
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        self.allCars = (databaseController?.getServerData())!
        self.form.rowBy(tag: "Brand")?.updateCell()
        
        if self.editCar != nil {
            //if editcar is not nil, then replace values of the existing car on the form
            self.form.rowBy(tag: "Brand")?.baseValue = self.editCar?.brand
        }
        
        form +++ Section("Section1")
            <<< ActionSheetRow<String>("Brand"){ row in
                row.tag = "Brand"
                row.title = "Brand"
                row.selectorTitle = "Pick a Brand Name"
                row.options = ["Any"]
                row.cellSetup({ (cell, row) in
//                    self.updateProgressBar()
                })
                row.cellUpdate({ (cell, row) in
                    //fill in here
                    self.carBrands = self.allCars.keys.map({ (key) -> String in
                        return key
                    })
                    row.options = self.carBrands
                })
                row.value = "Any"
                row.onChange({ (input) in
                    self.brandValue = input.value!
                    //loop through all rows or input fields -> find the tag of Model and trigger an update
                    for row in self.form.allRows {
                        if row.tag == "Model" {
                            row.updateCell()
                             self.progressView!.setProgress(0.2, animated: true)

                        }
                    }
                })
            }
            //Picking Model of the car. This will be presented after the model is picked
            <<< ActionSheetRow<String>("Model") { row in
                
                row.hidden = Condition.function(["Brand"], { (form) -> Bool in
                    let brandEmpty = ((self.brandValue).isEmpty)  ? true : false
                    if brandEmpty == false {
                        form.rowBy(tag: "Model")?.reload()
                        self.updateProgressBar()
                    }
                    return brandEmpty
                })
                row.tag = "Model"
                row.title = "Enter Model"
                row.selectorTitle = "Pick a Model for \(String(describing: self.brandValue ))"
                row.value = "Pick a Model"
                //callback for when the cell is updated.
                row.cellUpdate({ (cell, row) in
                    //Downcasting to NSDictionary helps to extract values
                    self.carModels = (self.allCars[self.brandValue] as! NSDictionary)
                    let data: [String] = self.carModels.allKeys as! [String]
                    row.options = data as? [String]
                })
                row.onChange({ (input) in
                    self.modelValue = input.value!
                    //loop through all rows or input fields -> find the Series Row and trigger an update
                    for row in self.form.allRows {
                        if row.tag == "Series" {
                            row.updateCell()
                            
                        }
                    }
                })
            }
            //Creating series row
            <<< ActionSheetRow<String>("Series") { row in
                
                row.hidden = Condition.function(["Model"], { (form) -> Bool in
                    let modelEmpty = ((self.modelValue).isEmpty)  ? true : false
                    if modelEmpty == false {
                        form.rowBy(tag: "Series")?.reload()
                        self.updateProgressBar()
                    }
                    return modelEmpty
                })
                row.tag = "Series"
                row.title = "Enter Series"
                row.selectorTitle = "Pick a Series for \(String(describing: self.modelValue ))"
                row.value = "Pick a Series"
                //callback for when the cell is updated.
                row.cellUpdate({ (cell, row) in
                    self.carSeries = (self.carModels[self.modelValue] as! NSDictionary)
                    let data = self.carSeries.allKeys as! [String]
                    row.options = data
                })
                row.onChange({ (input) in
                    self.seriesValue = input.value!
                    //loop through all rows or input fields -> find the Series Row and trigger an update
                    for row in self.form.allRows {
                        if row.tag == "Year" {
                            row.updateCell()
                            
                        }
                    }
                })
            }
            <<< PickerInlineRow<String>("Year"){ row in
                row.hidden = Condition.function(["Series"], { (form) -> Bool in
                    let seriesEmpty = ((self.seriesValue).isEmpty)  ? true : false
                    if seriesEmpty == false {
                        form.rowBy(tag: "Year")?.reload()
                        self.updateProgressBar()
                    }
                    return seriesEmpty
                })
                row.tag = "Year"
                row.title = "Model Year"
                row.value = "Select a Year"
                //calback fro when teh cell is updated
                row.cellUpdate({ (cell, row) in
                    self.carYear = (self.carSeries[self.seriesValue] as! [String])
                    let data = self.carYear
                    row.options = data
                    print(data)
                })
                row.onChange({ (input) in
                    self.yearValue = input.value!
                    self.view.addSubview(self.createCarButton)
                    
                    
                })

        }
        +++ Section("Picture Upload")
        <<< ImageRow() {
            $0.title = "Attach a Photo"
            $0.sourceTypes = .Camera
            $0.clearAction = .yes(style: .destructive)
            $0.value = self.imageValue
            $0.onCellSelection({ (cell, row) in
                self.shouldRemoveProgressView = false
            })
            $0.onChange({ (row) in
                self.imageValue = row.value!
                self.updateProgressBar()
                self.shouldRemoveProgressView = true
                
            })
            
        }
        

        createCarButton.setTitle("Create Car", for: .normal)
        createCarButton.setTitleColor(UIColor.blue, for: .normal)
        createCarButton.frame = CGRect(x: self.view.frame.midX - 100, y: self.view.frame.midY + 300, width: 200, height: 100)
        createCarButton.addTarget(self, action: #selector(handleAddCarBtn(_:)), for: .touchUpInside)
        
        
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        /* Lifecycle Method for when the view will be popped or removed from view
         Here I am going to remove the progress bar we added at the start so progress bar is not available everywhere
         */
        if animated == true {
            if self.shouldRemoveProgressView == true {
                print("View will now disappear, delete the form")
                
                progressView?.removeFromSuperview()
            }
            
        }
    }

    @objc func handleAddCarBtn(_ sender: Any) {
        /* This is an onlick action after the user clicks the create car button. THere is an intermediate step where the user has to add the rego of the car. So we present an Alert prompt for the user to fill in the rego
         
         TODO:-
         -Data validate the rego input
         
         */
        //create alert prompt
        let registrationInput = UIAlertController(title: "Enter Registration Number", message: "", preferredStyle: .alert)
        //add an action to the form to handle the data entered
        registrationInput.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak registrationInput] (_) in
            let textField = registrationInput!.textFields![0]
            self.registrationValue = textField.text!
            print(textField.text)
            self.addCar()
            
        }  ))
        //Cancel button for the user to exit the process
        registrationInput.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        registrationInput.addTextField { (textField: UITextField!) in
            textField.placeholder = "Please Enter Rego here"
        }
        
        self.present(registrationInput, animated: true, completion: nil)
        
    }
    func addCar() {
        /*
         This method is to trigger an addition of a new car from the firestore.
         This is done by
         -Grab all the data collected.
         - Call the addCar() method inside the firebaseController.
         
 
 */
        
        if dataValidation(brand: self.brandValue, model: self.modelValue, series: self.seriesValue, year: self.yearValue, registration: self.registrationValue) {
            let user = Auth.auth().currentUser
            //convert UIImage to NSData
            if let uploadData = self.imageValue.jpegData(compressionQuality: 0.2) {
                //upload image is not null
                //give all details to addCar()
                
                let car = databaseController?.addCar(userID: (user?.uid)!, brand: self.brandValue, model: self.modelValue, series: self.seriesValue, year: self.yearValue, registration: self.registrationValue, imageData: uploadData)
//                databaseController?.addCarImage(carId: (car?.id)!, image: (car?.image)!)
                print(car as Any)
                print("New Car added: \(car?.brand ?? "NO NEW CAR")) ")
            } else {
                let alert = UIAlertController(title: "Error in Submitting Data", message: "Please fill in all the fields in the form", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                return
                
            }

            
        }
        _ = navigationController?.popViewController(animated: true)
    }

    func dataValidation(brand: String, model: String, series: String, year: String, registration: String) -> Bool {
        /*
         Currently there is a basic form of data validation which checks if the user has entered the provided info.
         Since I am relying on the use of picker views and image picker view for the user to enter data into I am less reliant on the use of data validation to ensure if the user has entered the right pattern of data.
 
 */


        if (brand.isEmpty || model.isEmpty || series.isEmpty || year.isEmpty || registration.isEmpty) {
            let alert = UIAlertController(title: "Error in Submitting Data", message: "Please fill in all the fields in the form", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            return false
        }

        return true
    }
    func updateProgressBar() {
        //Update the progress bar as the user progresses through the form.
        let value: Float = (self.progressView?.progress)! + 0.2
        self.progressView!.setProgress(value, animated: true)
        print(self.progressView?.progress)
    }
    @objc func removeProgressView() {
        self.shouldRemoveProgressView = true
    }
}


