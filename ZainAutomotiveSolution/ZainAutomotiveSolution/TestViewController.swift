//
//  TestViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 08/06/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    var isRunning = false
    @IBAction func btnStart(_ sender: Any) {
        
        updateProgressView()
    }
    @IBOutlet weak var progressView: UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        progressView.progress = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateProgressView(){
        progressView.progress += 0.2
        progressView.setProgress(progressView.progress, animated: true)
        if(progressView.progress == 1.0)
        {
            progressView.progress = 0.0
        }
    }
}
