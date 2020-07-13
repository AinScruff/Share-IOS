//
//  RatingTableViewCell.swift
//  Share
//
//  Created by Dominique Michael Abejar on 17/04/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit
import Cosmos
class RatingTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewStar: CosmosView!
    @IBOutlet weak var commentText: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override public func prepareForReuse() {
        // Ensures the reused cosmos view is as good as new
        reviewStar.prepareForReuse()
    }

}
