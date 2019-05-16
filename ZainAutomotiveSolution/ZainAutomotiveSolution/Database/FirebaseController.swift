//
//  FirebaseController.swift
//  2019S1 Lab 3
//
//  Created by Zain Shroff on 25/04/19.
//  Copyright © 2019 Michael Wybrow. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

import GoogleSignIn

class FirebaseController: NSObject, DatabaseProtocol {
    
//    var defaultCarList: Car
    
    func updateCar(car: Car, brand: String, model: String, series: String, year: String, registration: String) {
        return
    }
    

    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var carsRef: CollectionReference?
    var workshopsRef: CollectionReference?
    
    var carList: [Car]
    var workshopList: [Workshop]
    
    
    var provider = GoogleAuthSignInMethod
//    var defaultTeam: Team
    
    
    override init() {
        //Run the FirebaseApp configure method.
        FirebaseApp.configure()
        //call auth and firestore
        authController = Auth.auth()
        database = Firestore.firestore()
        carList = [Car]()
        workshopList = [Workshop]()
        
        
        super.init()
        
//        authController.google

        
    }
    func signInAnon() {
        //START THE PROCESS of signing in    with an anonymous account
        authController.signInAnonymously { (authResult, error) in
            guard authResult != nil else{
                fatalError("firebase authentication failed!")
            }
            self.setUpListeners()
        }
    }
    
    func setUpListeners() {
        carsRef = database.collection("Car")
        carsRef?.addSnapshotListener{ (querySnapshot, error) in
            guard (querySnapshot?.documents) != nil else {
                print("error fetching documents \(error!)")
                return
            }
            self.parseCarSnapshot(snapshot: querySnapshot!)
        }
        
        workshopsRef = database.collection("Workshops")
        workshopsRef?.addSnapshotListener{ (querySnapshot, error) in
            guard (querySnapshot?.documents) != nil else {
                print("error fetching Workshops \(error!)")
                return
            }
            self.parseWorkshopSnapshot(snapshot: querySnapshot!)
        }
    }
    func parseCarSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            let documentRef = change.document.documentID
            let brand = change.document.data()["Brand"] as! String
            let model = change.document.data()["Model"] as! String
            let series = change.document.data()["Series"] as! String
            let year = change.document.data()["Year"] as! String
            let registration = change.document.data()["Registration"] as! String
//            let status = change.document.data()["Status"] as! Bool
            print("Document ID \(documentRef)")
            
            if change.type == .added {
                print("New Car: \(change.document.data())")
                let newCar = Car()
                newCar.brand = brand
                newCar.model = model
                newCar.series = series
                newCar.year = year
                newCar.registration = registration
                newCar.id = documentRef
//                newCar.status = status
                
                carList.append(newCar)
            }
            if change.type == .removed {
                print("Removed Hero: \(change.document.data())")
                if let index = getCarByIndex(reference: documentRef){
                    carList.remove(at: index)
                }
            }

            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.cars || listener.listenerType == ListenerType.all {
                    listener.onCarListChange(change: .update, cars: carList)
                }
            }
//            if change.type == .modified {
//                print("Updated Hero: \(change.document.data())")
//                let index = getHeroIndexByID(reference: documentRef)!
//                heroList[index].name = name
//                heroList[index].abilities = abilities
//                heroList[index].id = documentRef
//            }
        
        }
            
    }
    func parseWorkshopSnapshot(snapshot: QuerySnapshot){
        //converts workshop from a firestore collection/snapshot to readable
        snapshot.documentChanges.forEach { (change) in
            let documentRef = change.document.documentID
            let name = change.document.data()["Name"] as! String
            let address = change.document.data()["Address"] as! String
            let location = change.document.data()["Location"] as! GeoPoint
            let lat = location.latitude
            let long = location.longitude
            
            print("Document ID \(documentRef)")
            
            if change.type == .added {
                print("New Workshop: \(change.document.data())")
                let newWorkshop = Workshop()
                newWorkshop.name = name
                newWorkshop.address = address
                newWorkshop.lat = lat
                newWorkshop.long = long
                newWorkshop.id = documentRef
                
                workshopList.append(newWorkshop)
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.workshops || listener.listenerType == ListenerType.all {
                    listener.onWorkshopListChange(change: .update, workshops: workshopList)
                }
            }
            
        }
        
    }
    
    func getCarByIndex(reference: String) -> Int? {
        for car in carList {
            if(car.registration == reference) {
                return carList.firstIndex(of: car)
            }
        }
        return nil
    }
    
    func getCarByRegistration(reference: String) -> Car? {
        for car in carList{
            if(car.registration == reference){
                return car
            }
        }
        return nil
    }
    
    func addCar(brand: String, model: String, series: String, year: String, registration: String) -> Car {
        //Add car details. By default car status will be false
        let car = Car()
        let id = carsRef?.addDocument(data: ["Brand": brand, "Model": model, "Series": series, "Year": year, "Registration": registration])
        car.brand = brand
        car.model = model
        car.id = id!.documentID
        return car
    }
    func deleteCar(car: Car) {
        //delete the car from the collection of Cars stored in Firestore
        carsRef?.document(car.id).delete() { err in
            if err != nil {
                print("error deleting \(String(describing: err))")
            } else {
                print("Item deleted!")
            }
        }
        print("\(carList)")
    }

//    func removeHeroFromTeam(hero: SuperHero, team: Team) {
//        let index = team.heroes.index(of: hero)
//        let removedHero = team.heroes.remove(at: index!)
//        let removedRef = heroesRef?.document(removedHero.id)
//
//        teamsRef?.document(team.id).updateData(["heroes": FieldValue.arrayRemove([removedRef!])])
//    }
//
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == ListenerType.cars || listener.listenerType == ListenerType.all {
            listener.onCarListChange(change: .update, cars: carList)
        }
        if listener.listenerType == ListenerType.workshops || listener.listenerType == ListenerType.all {
            listener.onWorkshopListChange(change: .update, workshops: workshopList)
        }
        
        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
}
