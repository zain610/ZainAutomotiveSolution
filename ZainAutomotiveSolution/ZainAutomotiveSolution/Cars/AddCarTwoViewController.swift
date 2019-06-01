//
//  AddCarTwoViewController.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 01/06/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import Eureka

class AddCarTwoViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Section1")
            <<< TextRow("Brand"){ row in
                row.title = "Text Row"
                row.placeholder = "Enter text here"
                row.value = ""
                }
            
//            <<< LabelRow() {
//                $0.hidden = Condition.function(["Brand"], { (form) -> Bool in
//                    let gg = (form.rowBy(tag: "Brand") as? TextRow)?.value
//                    let xxx = gg?.isEmpty
//                    return xxx!
//                })
//                $0.title = "Enter Model"
//            }
            +++ Section("Section2")
            <<< DateRow(){
                $0.title = "Date Row"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
        }
    }
}
