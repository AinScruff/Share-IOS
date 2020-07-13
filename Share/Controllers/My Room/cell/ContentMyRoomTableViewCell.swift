//
//  ContentMyRoomTableViewCell.swift
//  Share
//
//  Created by Dominique Michael Abejar on 16/02/2019.
//  Copyright © 2019 Caryl Rabanos. All rights reserved.
//

import UIKit

class ContentMyRoomTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var noOfUserLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
