//
//  AccountHeaderTableViewCell.swift
//  Share
//
//  Created by Dominique Michael Abejar on 20/10/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit
import Cosmos
class AccountHeaderTableViewCell: UITableViewCell {


    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starsRating: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        let sv = UIViewController.displaySpinner(onView: self.imageDisplay)
        self.imageDisplay.image = nil
        
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.imageDisplay.setRound()
                self.imageDisplay.image = UIImage(data: data)
                
                if self.imageDisplay.image != nil{
                    UIViewController.removeSpinner(spinner: sv)
                }
            }
        }
    }
}
