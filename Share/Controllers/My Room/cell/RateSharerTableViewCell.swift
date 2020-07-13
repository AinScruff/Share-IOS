//
//  RateSharerTableViewCell.swift
//  Share
//
//  Created by Dominique Michael Abejar on 26/04/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit
import Cosmos
class RateSharerTableViewCell: UITableViewCell {

    @IBOutlet weak var starView: CosmosView!
    @IBOutlet weak var commentText: UITextView!
    
    
    func update(_ rating: Double) {
        starView.rating = rating
    }
    
    override public func prepareForReuse() {
        // Ensures the reused cosmos view is as good as new
        starView.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
