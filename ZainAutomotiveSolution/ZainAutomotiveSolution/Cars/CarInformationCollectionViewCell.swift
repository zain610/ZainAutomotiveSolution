//
//  CarInformationCollectionViewCell.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 25/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit

class CarInformationCollectionViewCell: UICollectionViewCell {
    
    //Setup Outlets from the cell and set them as private
    @IBOutlet private weak var carTitle: UITextField!
    @IBOutlet private weak var carSubTitle: UITextField!
    @IBOutlet private weak var carStatus: UITextField!
    
    var car: Car = Car()
    
}
