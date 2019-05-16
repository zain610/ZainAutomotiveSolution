//
//  SignInViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 16/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    
    @IBOutlet weak var googleButton: UIButton!
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        //configure 
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
        
        // Do any additional setup after loading the view.
        let anotherGoogleButton = GIDSignInButton()
        anotherGoogleButton.frame = CGRect(x: 16, y: googleButton.frame.origin.y + 64, width: view.frame.width-32, height: 50)
        
        view.addSubview(anotherGoogleButton)
        
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
