                //
//  EditProfileTableViewCell.swift
//  Share
//
//  Created by Dominique Michael Abejar on 20/10/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit

class EditProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var uploadImage: UIButton!
    
    @IBOutlet weak var imageDisplay: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
