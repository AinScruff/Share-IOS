//
//  RegisterTableViewCell.swift
//  Share
//
//  Created by Dominique Michael Abejar on 24/03/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit

class RegisterTableViewCell: UITableViewCell {

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var contactNumberTextField: UITextField!
    @IBOutlet weak var guardianContactNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var genderChoice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
