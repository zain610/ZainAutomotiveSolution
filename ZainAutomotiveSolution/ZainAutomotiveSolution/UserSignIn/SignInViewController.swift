//
//  SignInViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 16/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class SignInViewController: UIViewController, GIDSignInUIDelegate {
    var globalUser: User?
    var handle: AuthStateDidChangeListenerHandle? = nil
    
    var googleSignInBtn: GIDSignInButton!
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.uiDelegate = self
        //Creating the iconic google button and styling
        googleSignInBtn = GIDSignInButton(frame: CGRect(x: 16, y: 599, width: 188, height: 48) )
        googleSignInBtn.style = GIDSignInButtonStyle.standard
        view.addSubview(googleSignInBtn)
        //attach onclick listener to the button to handle signin
        googleSignInBtn.addTarget(self, action: #selector(handleGoogleSignin), for: .touchUpInside)
        
        
    }
    
    //for each of the views that need info on the signed in user, attach a listener to Auth object.
    //THis listener is called when user sign in changes.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.globalUser = user
                print(user.displayName)
                //
            }
            else {
                print("error, No user found!")
            }
            
        })
    }
    //handle removing of baggage and unwanted listeners and dependencies when the before the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @objc func handleGoogleSignin() {
        /*
         - This method calls the sign in method from app delegate. so that the user can sign in
         - After that we need to have the user go to the ViewCarsTVC. I do this programmatically by
            1. searching for the view in the storyboard
            2. push the view on the navigation view controller
         */
        
        GIDSignIn.sharedInstance()?.signIn()
        print("yoink success bithces")
        
        //initiate the next view controller by finign the view on storyboard
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "viewCars") as? ViewCarsTableViewController {
//            viewController.obj = newsObj
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "viewCarsSegue" {
//            let destination = segue.destination as! ViewCarsTableViewController
//            self.navigationController?.pushViewController(destination, animated: true)
//            print(globalUser!.email)
//            print("going to view cars table view \(String(describing: globalUser?.displayName))")
//
//
//        }
//    }
    

    

}
