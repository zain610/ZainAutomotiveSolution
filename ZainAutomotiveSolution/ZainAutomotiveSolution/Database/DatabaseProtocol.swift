//
//  DatabaseProtocol.swift
//  2019S1 Lab 3
//
//  Created by Michael Wybrow on 22/3/19.
//  Copyright © 2019 Michael Wybrow. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case cars
    case workshops
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onCarListChange(change: DatabaseChange, cars: [Car])
    func onWorkshopListChange(change: DatabaseChange, workshops: [Workshop])
}

protocol DatabaseProtocol: AnyObject {
//    var defaultCarList: Car {get}
    func addCar(brand: String, model: String, series: String, year: String, registration: String) -> Car
    func deleteCar(car: Car)
    func updateCar(car: Car, brand: String, model: String, series: String, year: String, registration: String)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}

