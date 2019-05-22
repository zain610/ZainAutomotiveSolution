//
//  AddCarViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 05/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit
import FirebaseAuth

class AddCarViewController: UIViewController  {
    
    
    @IBOutlet weak var brandInput: UITextField!
    @IBOutlet weak var modelInput: UITextField!
    @IBOutlet weak var seriesInput: UITextField!
    @IBOutlet weak var yearInput: UITextField!
    
    @IBOutlet weak var registrationInput: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    weak var editCar: Car?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        // Do any additional setup after loading the view.
        
        
        if editCar != nil {
            brandInput.text = editCar?.brand
            modelInput.text = editCar?.model
            seriesInput.text = editCar?.series
            yearInput.text = editCar?.year
            registrationInput.text = editCar?.registration
            
        }
    }
    
    @IBAction func handleAddCarBtn(_ sender: Any) {
        let brand = brandInput.text!
        let model = modelInput.text!
        let series = seriesInput.text!
        let year = yearInput.text!
        let registration = registrationInput.text!
        
        if dataValidation(brand: brand, model: model, series: series, year: year, registration: registration) {
            let car = databaseController?.addCar(brand: brand, model: model, series: series, year: year, registration: registration)
            print("New Car added: \(car?.brand ?? "NO NEW CAR")) ")
            resetForm()
            
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func dataValidation(brand: String, model: String, series: String, year: String, registration: String) -> Bool {
        
        
        if (brand.isEmpty || model.isEmpty || series.isEmpty || year.isEmpty || registration.isEmpty) {
            return false
        }
        
        return true
    }
    func resetForm() {
        brandInput.text! = ""
        modelInput.text! = ""
        seriesInput.text! = ""
        yearInput.text! = ""
        registrationInput.text! = ""
    }
    

}
