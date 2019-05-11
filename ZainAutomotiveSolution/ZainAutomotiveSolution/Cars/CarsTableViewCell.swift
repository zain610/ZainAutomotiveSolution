//
//  CarsTableViewCell.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 04/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit

class CarsTableViewCell: UITableViewCell {

    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var regoLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
