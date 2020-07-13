//
//  ProfileController.swift
//  Share
//
//  Created by Caryl Rabanos on 07/09/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class ProfileController: UITableViewController{
    
    var tableItems = ["First Name:", "Last Name:", "Gender:", "Contact Number:", "Guardian Contact Number:"
    ]
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    
    //User
    var fname = ""
    var lname = ""
    var gender = ""
    var contactNumber = ""
    var EcontactNumber = ""
    var profileURL: URL!
    var profileImage = UIImage()
    var rating = [Double]()
    
    override func viewDidLoad() {
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(hex: "#151515")
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        query()
    }
    
    func query(){
        ref.child("users").child(curUser!).observe(.value, with: {(snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            //Get User
            self.gender = value?["Gender"] as! String
            self.fname = value?["Fname"] as! String
            self.lname = value?["Lname"] as! String
            self.contactNumber = value?["ContactNumber"] as! String
            self.EcontactNumber = value?["EmergencyContact"] as! String
            
            
            if snapshot.hasChild("Rating"){
                for child in snapshot.childSnapshot(forPath: "Rating").children{
                    
                    let child = child as! DataSnapshot
                    let dict = child.value! as! [String:Any]
                   
                    let rating = dict["Rating"] as! NSNumber
                    self.rating.append(rating.doubleValue)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            }
            
            let sumArray = self.rating.reduce(0, +)
            	
            if sumArray != 0.0{
               
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AccountHeaderTableViewCell
                
                cell.starsRating.rating = Double(sumArray) / Double(self.rating.count)
                cell.starsRating.isUserInteractionEnabled = false
            }
            
            
        
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            let storageRef = Storage.storage().reference().child("profile/"+self.curUser!+".jpg")
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print(error)
                } else {
                    self.profileURL = url!
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ref.removeAllObservers()
        rating.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    @IBAction func editProfile(_ sender: Any) {
        self.performSegue(withIdentifier: "editProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editProfile"{
            let editVC = segue.destination as! EditProfileViewController
            
            editVC.fname = fname
            editVC.lname = lname
            editVC.gender = gender
            editVC.contactNumber = contactNumber
            editVC.EcontactNumber = EcontactNumber
            editVC.profileImage = profileImage
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let imageCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AccountHeaderTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellItems", for: indexPath) as! ProfileTableViewCell
        
        imageCell.isUserInteractionEnabled = false
        cell.isUserInteractionEnabled = false
        
        switch indexPath.row{
        case 0:
            if let url = self.profileURL {
                imageCell.imageDisplay.downloaded(from: url)
                if imageCell.imageDisplay.image != nil{
                    profileImage = imageCell.imageDisplay.image!
                }
                if self.rating.isEmpty == false{
                    imageCell.starsRating.isHidden = false
                }else{
                     imageCell.starsRating.isHidden = true
                }
            }
            

            imageCell.imageDisplay.setRound()
            
            return imageCell
        case 1:
            
            cell.titleLabel.text = tableItems[indexPath.row - 1]
            if fname != ""{
                cell.infoLabel.text = fname
            }

            return cell
        case 2:
            cell.titleLabel.text = tableItems[indexPath.row - 1]
            if lname != ""{
            cell.infoLabel.text = lname
            }
            return cell
        case 3:
            cell.titleLabel.text = tableItems[indexPath.row - 1]
            
            if gender != ""{
                cell.infoLabel.text = gender
            }
            return cell
        case 4:
            cell.titleLabel.text = tableItems[indexPath.row - 1]
            if contactNumber != ""{
               cell.infoLabel.text = contactNumber
            }
            return cell
        case 5:
            cell.titleLabel.text = tableItems[indexPath.row - 1]
            if EcontactNumber != "" {
              cell.infoLabel.text = EcontactNumber
            }
            return cell
        default:
            break
        }
        
        return cell
    }
    
}
