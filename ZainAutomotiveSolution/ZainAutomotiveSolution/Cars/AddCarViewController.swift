//
//  AddCarViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 05/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit
import FirebaseAuth

class AddCarViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    
    
    var brandData: [String] = [String]()
    var selectedBrand: String = ""
    
    @IBOutlet weak var brandPickerView: UIPickerView!
    @IBOutlet weak var modelInput: UITextField!
    @IBOutlet weak var seriesInput: UITextField!
    @IBOutlet weak var yearInput: UITextField!
    @IBOutlet weak var registrationInput: UITextField!
    
    var modelPickerView: UIPickerView! = UIPickerView()
    
    weak var databaseController: DatabaseProtocol?
    
    weak var editCar: Car?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        //ConnectData
        self.brandPickerView.delegate = self
        self.brandPickerView.dataSource = self

        //brand Data
        brandData = ["Jeep", "Dodge", "Chrysler", "Toyota", "Honda"]
        // Do any additional setup after loading the view.
        
        
        if editCar != nil {
            let brandIndex = brandData.firstIndex(of: (editCar?.brand)!)
            brandPickerView.selectRow(brandIndex!, inComponent: 0, animated: true)
            
            modelInput.text = editCar?.model
            seriesInput.text = editCar?.series
            yearInput.text = editCar?.year
            registrationInput.text = editCar?.registration
            
        }
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return brandData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return brandData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedBrand = brandData[brandPickerView.selectedRow(inComponent: component)]
        print(selectedBrand)
    }
    
    
    @IBAction func handleAddCarBtn(_ sender: Any) {
        let brand = selectedBrand
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
//        brandInput.text! = ""
        modelInput.text! = ""
        seriesInput.text! = ""
        yearInput.text! = ""
        registrationInput.text! = ""
    }
    

}
