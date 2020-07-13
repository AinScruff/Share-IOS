//
//  SharerTableViewCell.swift
//  Share
//
//  Created by Dominique Michael Abejar on 31/03/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit

class SharerTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leaderLabel: UIView!
    
    @IBOutlet weak var addedByLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
