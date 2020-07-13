//
//  TravelCameraTableViewCell.swift
//  Share
//
//  Created by Dominique Michael Abejar on 13/04/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit

class TravelCameraTableViewCell: UITableViewCell {

    @IBOutlet weak var travelCameraTextField: UITextField!
    @IBOutlet weak var travelCameraLabel: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
