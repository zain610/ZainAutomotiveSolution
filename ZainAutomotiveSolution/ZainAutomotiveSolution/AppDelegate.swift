//
//  AppDelegate.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 03/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var newUser: Person? = Person()
    var window: UIWindow?
    var databaseController: DatabaseProtocol?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        databaseController = FirebaseController()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        
        return true
    }
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    func applicationDidFinishLaunching(_ application: UIApplication) {
//        /*
//         After the application is finished launching we get the storyboard and set the destination as Signin
//         We then use segue to pass user data to the next view controller 
//        */
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let destination = storyboard.instantiateViewController(withIdentifier: "initialSegue") as! SignInViewController
////        destination.user = self.newUser
//        let navigationController = self.window?.rootViewController as! UINavigationController
//        navigationController.pushViewController(destination, animated: false)
//    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("Error \(error)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        guard let idToken = authentication.idToken else { return }
        guard let accessToken = authentication.accessToken else {return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: accessToken)
        print("Successfully signed into google with user: \(credential)")
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print("Failed to create a Firebase User with Google account \(error)")
                return
            }
            //User is logged in
            self.newUser?.id = user.userID                // For client-side use only!
            self.newUser?.idToken = user.authentication.idToken // Safe to send to the server
            self.newUser?.fullName = user.profile.name
            self.newUser?.email = user.profile.email
            print(self.newUser)
            
            print("Successfully logged into Firebase with Google: \(String(describing: self.newUser?.fullName))")
            
        }
        
        
    }
    
    //    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    //        // Perform any operations when the user disconnects from app here.
    //        // ...
    //    }
    
    
    
    
    

}

