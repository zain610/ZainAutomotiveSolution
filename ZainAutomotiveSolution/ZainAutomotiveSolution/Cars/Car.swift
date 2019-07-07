//
//  Car.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 04/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit

class Car: NSObject {
    var id: String = "" //id provided by firebase
    var userID: String = "" //id of the user the car belongs to
    var brand: String = "" //brand of the car
    var model: String = "" //car model
    var series: String = "" //series of the car
    var year: String = "" //year of manufacture
    var registration: String = "" //a valid car rego
    var status: Bool = false //False means that car is not under repairs at a workshop
    var image: UIImage = UIImage() //download url of the image
    
    

}
