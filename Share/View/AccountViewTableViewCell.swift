//
//  ProfileViewTableViewCell.swift
//  Share
//
//  Created by Dominique Michael Abejar on 19/10/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit

class AccountViewTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var infoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
