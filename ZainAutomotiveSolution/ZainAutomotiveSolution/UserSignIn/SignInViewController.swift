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
    
    @IBOutlet weak var googleButton: GIDSignInButton!
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        
        // Do any additional setup after loading the view.
        
        googleButton.addTarget(self, action: #selector(handleGoogleSignin), for: .touchUpInside)
        
        
    }
    
    //for each of the views that need info on the signed in user, attach a listener to Auth object.
    //THis listener is called when user sign in changes.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil {
                self.globalUser = user
                print("inside auth handler\(String(describing: user?.email))")
            }
            else {
                print("error, No user found!")
            }
            
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @objc func handleGoogleSignin() {
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
        print("yoink success bithces")
        performSegue(withIdentifier: "viewCarsSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewCarsSegue" {
            let destination = segue.destination as! ViewCarsTableViewController
            print(globalUser?.email)
            destination.user = globalUser
            print("going to view cars table view \(String(describing: globalUser?.displayName))")
            
            
        }
    }
    

    

}
