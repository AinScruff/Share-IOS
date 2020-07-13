//
//  SettingsViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 19/10/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var tableItems = ["Security", "Change Password", "Change Pin"]
    
    override func viewDidLoad() {
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(hex: "#151515")
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSection") as! SettingsSectionTableViewCell
            
            cell.isUserInteractionEnabled = false
            
            cell.sectionLabel.text = tableItems[indexPath.row]
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SettingsTableViewCell
            
            cell.settingsLabel.text = tableItems[indexPath.row]
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row{
        case 1:
            performSegue(withIdentifier: "ChangePass", sender: self)
        case 2:
            performSegue(withIdentifier: "ChangePin", sender: self)
        default:
            break
        }
    }
    
}
