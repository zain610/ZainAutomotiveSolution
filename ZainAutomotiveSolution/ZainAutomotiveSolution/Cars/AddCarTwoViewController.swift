//
//  AddCarTwoViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 01/06/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//
/*
 This file is adding car
 TODO:
 - Fetch data from firebase and update the brand names, model, etc
 -
 
 
 */
import Eureka

let sampleData: [String: [String: [String]]] = [
    "Jeep": [
        "Wrangler": ["2005", "2006", "2007"],
        "Grand Cherokee": ["2008", "2009", "2010", "2011", "2012"]],
    "Honda": [
        "City": ["1", "2", "3"]]
]

func getBrands() {
    let data: [String] = []
    for row in sampleData {
        print(row)
    }
}

class AddCarTwoViewController: FormViewController {
    //declare all form variables
    var brandValue: String = ""
    var modelValue: String = ""
    var seriesValue: String = ""
    var yearValue: String = ""
    var registrationValue: String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create Section 1: Picking Brand of the car
        
    }
}
