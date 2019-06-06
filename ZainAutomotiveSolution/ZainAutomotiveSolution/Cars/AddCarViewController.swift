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
    
    weak var editCar: Car?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        //get brand Data from firestore
        let db = Firestore.firestore()
        let serverDataRef = db.collectionGroup("ServerData")
        serverDataRef.addSnapshotListener { (querySnapshot, error) in
            guard (querySnapshot?.documents) != nil else {
                print("error fetching documents \(error!)")
                return
            }
            self.parseCarSnapshot(snapshot: querySnapshot!)
            self.form.rowBy(tag: "Brand")?.updateCell()
        }
        
       
        // Do any additional setup after loading the view.
        
//
//        if editCar != nil {
//            let brandIndex = brandData.firstIndex(of: (editCar?.brand)!)
//            brandPickerView.selectRow(brandIndex!, inComponent: 0, animated: true)
//
//            modelInput.text = editCar?.model
//            seriesInput.text = editCar?.series
//            yearInput.text = editCar?.year
//            registrationInput.text = editCar?.registration
        form +++ Section("Section1")
            <<< ActionSheetRow<String>("Brand"){ row in
                row.tag = "Brand"
                row.title = "Brand"
                row.selectorTitle = "Pick a Brand Name"
                row.options = ["Any"]
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
                        if row.tag == "Model" {
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
                    }
                    return seriesEmpty
                })
                row.tag = "Year"
                row.title = "Model Year"
                row.value = row.options.first
                //calback fro when teh cell is updated
                row.cellUpdate({ (cell, row) in
                    self.carYear = (self.carSeries[self.seriesValue] as! [String])
                    let data = self.carYear
                    row.options = data
                    print(data)
                })
                row.onChange({ (input) in
                    self.yearValue = input.value!
                })

        }
        +++ Section("Picture Upload")
        <<< ImageRow() {
            $0.title = "Attach a Photo"
            $0.sourceTypes = .Camera
            $0.clearAction = .yes(style: .destructive)
            $0.value = self.imageValue
            $0.onChange({ (row) in
                self.imageValue = row.value!
            })
            
        }
        let createCarButton = UIButton()
        createCarButton.setTitle("Create Car", for: .normal)
        createCarButton.setTitleColor(UIColor.blue, for: .normal)
        createCarButton.frame = CGRect(x: 8, y: view.frame.maxY - 16, width: 300, height: 500)
        createCarButton.addTarget(self, action: #selector(handleAddCarBtn(_:)), for: .touchUpInside)
        self.view.addSubview(createCarButton)
        
        }

    @IBAction func handleAddCarBtn(_ sender: Any) {
        
//        let brand = selectedBrand
//        let model = modelInput.text!
//        let series = seriesInput.text!
//        let year = yearInput.text!
//        let registration = registrationInput.text!
//
//        if dataValidation(brand: brand, model: model, series: series, year: year, registration: registration) {
//            let car = databaseController?.addCar(brand: brand, model: model, series: series, year: year, registration: registration)
//            print("New Car added: \(car?.brand ?? "NO NEW CAR")) ")
//            resetForm()
//
//        }
//        _ = navigationController?.popViewController(animated: true)
    }

//    func dataValidation(brand: String, model: String, series: String, year: String, registration: String) -> Bool {
//
//
//        if (brand.isEmpty || model.isEmpty || series.isEmpty || year.isEmpty || registration.isEmpty) {
//            let alert = UIAlertController(title: "Error in Submitting Data", message: "Please fill in all the fields in the form", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
//                NSLog("The \"OK\" alert occured.")
//            }))
//            self.present(alert, animated: true, completion: nil)
//            return false
//        }
//
//        return true
//    }
//    func resetForm() {
////        brandInput.text! = ""
//        modelInput.text! = ""
//        seriesInput.text! = ""
//        yearInput.text! = ""
//        registrationInput.text! = ""
//    }
    func parseCarSnapshot(snapshot: QuerySnapshot){
        /*
         We have to extract all the data from the firestore. We do not disect it further cos the data we need is dynamic in nature
         That means we need data based on user's descision. So extract Honda Models only if honda is picked, etc
         */
        snapshot.documentChanges.forEach { (change) in
            let documentRef = change.document.documentID
            self.allCars = change.document.data()
        }
    }
}
