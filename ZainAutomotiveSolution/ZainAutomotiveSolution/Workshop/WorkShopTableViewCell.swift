//
//  WorkShopTableViewCell.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 10/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import UIKit
import Cosmos

class WorkShopTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
