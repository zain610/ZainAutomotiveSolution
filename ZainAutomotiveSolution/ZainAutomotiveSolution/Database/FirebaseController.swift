//
//  FirebaseController.swift
//  2019S1 Lab 3
//
//  Created by Zain Shroff on 25/04/19.
//  Copyright © 2019 Michael Wybrow. All rights reserved.
//

/*
 
 Add car details and image logic
 1. Get details from addCarView
 2. add car to firestore
 3. get document id
 4. get image value from addCarView
 5. add to firebase storage
 6. get the path
 7. add path to firestore car value
 
 
 
 */

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

import GoogleSignIn

class FirebaseController: NSObject, DatabaseProtocol {
    
    
    
    
    
//    var defaultCarList: Car
    var globalUser: User?
    //update car method. FInd the car stored in firestore using car.id and then set the new values of the car
    func updateCar(car: Car, brand: String, model: String, series: String, year: String, registration: String) {
        return
    }
    

    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var carsRef: CollectionReference?
    var workshopsRef: CollectionReference?
    var serverDataRef: Query?
    var carImagesRef: StorageReference?
    var storageRef: StorageReference?
    
    
    var carList: [Car]
    var workshopList: [Workshop]
    var serverDataList: [String: Any]
    
    var downloadedImage: String = ""
    var carImage: UIImage = UIImage()
    
    
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
        serverDataList = [String: Any]()
        //Init firebase storage and get reference to it.
        storageRef = Storage.storage().reference()
        
        
        super.init()
        //check if user has been fetched. if the field is not nil then set up listeners and set up listeners
        Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.globalUser = user
                self.setUpListeners()
            }
            else {
                print("error getting user")
            }
        })
//        authController.google

        
    }
    
    //set up listeners for objects that are bound to change over time.
    func setUpListeners() {
        //get car data
        carsRef = database.collection("Car")
        carsRef?.addSnapshotListener{ (querySnapshot, error) in
            guard (querySnapshot?.documents) != nil else {
                print("error fetching documents \(error!)")
                return
            }
            self.parseCarSnapshot(snapshot: querySnapshot!)
        }
        //get workshop data
        workshopsRef = database.collection("Workshops")
        workshopsRef?.addSnapshotListener{ (querySnapshot, error) in
            guard (querySnapshot?.documents) != nil else {
                print("error fetching Workshops \(error!)")
                return
            }
            self.parseWorkshopSnapshot(snapshot: querySnapshot!)
        }
        //get serverData
        serverDataRef = database.collectionGroup("ServerData")
        serverDataRef?.addSnapshotListener { (querySnapshot, error) in
            guard (querySnapshot?.documents) != nil else {
                print("error fetching document \(error!)")
                return
            }
            self.parseServerData(snapshot: querySnapshot!)
        }
        //Firebase storage listeners
        carImagesRef = storageRef?.child("Cars")
        
        
    }
    func parseCarSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            let documentRef = change.document.documentID
            let brand = change.document.data()["Brand"] as! String
            let model = change.document.data()["Model"] as! String
            let series = change.document.data()["Series"] as! String
            let year = change.document.data()["Year"] as! String
            let registration = change.document.data()["Registration"] as! String
            let userId = change.document.data()["UserID"] as! String
            //download image
//            let status = change.document.data()["Status"] as! Bool
            print("Document ID \(documentRef)")
            
            if change.type == .added {
                print("New Car: \(change.document.data())")
                let newCar = Car()
                newCar.userID = userId
                newCar.brand = brand
                newCar.model = model
                newCar.series = series
                newCar.year = year
                newCar.registration = registration
                newCar.id = documentRef
//                newCar.status = status
                
                //check if the userId of the car is same as the id of the user logged in,
                //add the car to the carList, else pass
                if userId == Auth.auth().currentUser?.uid {
                    carList.append(newCar)
                }
                
            }
            if change.type == .removed {
                print("Removed Car: \(change.document.data())")
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
            var rating = change.document.data()["Rating"] as! Double
            
            print("Document ID \(documentRef)")
            
            if change.type == .added {
                print("New Workshop: \(change.document.data())")
                let newWorkshop = Workshop()
                newWorkshop.name = name
                newWorkshop.address = address
                newWorkshop.lat = lat
                newWorkshop.long = long
                newWorkshop.id = documentRef
                newWorkshop.rating = rating
                
                workshopList.append(newWorkshop)
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.workshops || listener.listenerType == ListenerType.all {
                    listener.onWorkshopListChange(change: .update, workshops: workshopList)
                }
            }
            
        }
        
    }
    func parseServerData(snapshot: QuerySnapshot) {
        /*
         We have to extract all the data from the firestore. We do not disect it further cos the data we need is dynamic in nature
         That means we need data based on user's descision. So extract Honda Models only if honda is picked, etc
         */
        snapshot.documentChanges.forEach { (change) in
            let serverData = change.document.data()
            serverDataList = serverData
            
        }
    }
    
    func getCarByIndex(reference: String) -> Int? {
        //search fro cars via its index of in the list.
        for car in carList {
            if(car.id == reference) {
                return carList.firstIndex(of: car)
            }
        }
        return nil
    }
    
    
    func getCarByRegistration(reference: String) -> Car? {
        //Can be used to search for car via its unique rego number
        for car in carList{
            if(car.registration == reference){
                return car
            }
        }
        return nil
    }
    func getServerData() -> [String : Any] {
        return serverDataList
    }
    
    func addCar(userID: String, brand: String, model: String, series: String, year: String, registration: String, imageData: Data) -> Car {
        //Add car details. By default car status will be false
        let car = Car()
        let id = carsRef?.addDocument(data: ["UserID": userID,"Brand": brand, "Model": model, "Series": series, "Year": year, "Registration": registration])
        car.brand = brand //Car Brand
        car.model = model //Car Model
        car.id = id!.documentID //Car's ID
        //add image to storage
        self.addCarImage(carId: car.id, image: imageData)
        return car
    }
    
    func addCarImage(carId: String, image: Data) {
        //get a new child off the root carImagesRef. Replace the newCarImage child with car's
        print(carId)
        //make a child node of the car id
        let myImageRef = self.carImagesRef?.child("\(carId).jpeg/")
        print(myImageRef?.fullPath as Any)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        //put data into the referene made
        myImageRef?.putData(image, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                print("unable to upload image")
            }
            myImageRef?.downloadURL(completion: { (url, error) in
                if let error = error {
                    print("Unable to retreive download url \(error)")
                }
                guard let url = url?.absoluteString else { return }
//                self.setImageForCar(carId: carId, imageUrl: url)
            })
        })
    }
    func getImageById(carId: String) -> UIImage {
        let downloadRef = carImagesRef?.child("\(carId).jpeg")
        downloadRef?.getData(maxSize: 15*1024*1024, completion: { (data, error) in
            if let error = error {
                print("There is no data available here \(error)")
            }
            else {
                print("success")
                let image = UIImage(data: data!)
                self.carImage = image!
                
            }
        })
        return self.carImage
    }

    
    func deleteCar(car: Car) {
        //delete the car from the collection of Cars stored in Firestore.
        //using the id of the car deleted, delete the image of the car with the help of id.jpeg
        carsRef?.document(car.id).delete() { err in
            if (err != nil) {
                print("\(String(describing: err))")
            }
            else {
                print("Successfully deleted: \(car.id)")
                //delete the image from storage
                self.carImagesRef?.child("\(car.id).jpeg").delete(completion: { (error) in
                    if let error = error {
                        print("There was an error deleting the image frm storage of the car \(car.id) and error \(error)")
                    }
                })
            }
        }
        
    }
    
    
    
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
