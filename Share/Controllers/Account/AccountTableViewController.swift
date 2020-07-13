//
//  ProfileController.swift
//  Share
//
//  Created by Caryl Rabanos on 07/09/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit
import Firebase
import Hex

class AccountTabViewController: UITableViewController{
    
    var tableItems = ["My Profile", "My Rating", "Settings", "About Us", "Sign Out"]
    var tableImage = ["userFilled", "starFilled", "settingsFilled", "aboutFilled", "logoutFilled"]
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    
    //User
    var fname = ""
    var lname = ""
    var gender = ""
    var contactNumber = ""
    var EcontactNumber = ""
    var pin = NSNumber()
    var profileImage: URL!
    
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
            self.pin = value?["Pin"] as! NSNumber
            self.fname = value?["Fname"] as! String
            self.lname = value?["Lname"] as! String
            
            let storageRef = Storage.storage().reference().child("profile/"+self.curUser!+".jpg")
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print(error)
                } else {
                    self.profileImage = url!
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ref.removeAllObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

//        if(segue.identifier == "InfoProfile"){
//            let profileVc = segue.destination as! ProfileController
//            profileVc.curUser = curUser
//            profileVc.fname = fname
//            profileVc.lname = lname
//            profileVc.gender = gender
//            profileVc.contactNumber = contactNumber
//            profileVc.profileImage = profileImage
//            profileVc.EcontactNumber = EcontactNumber
//        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 200.0
        }else{
            return 70.0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AccountHeaderTableViewCell
            
            cell.isUserInteractionEnabled = false
            
            if let url = self.profileImage {
                cell.imageDisplay.downloaded(from: url)
                cell.imageDisplay.setRound()
            }
           
            if fname != "" && lname != ""{
                cell.nameLabel.text = fname + " " + lname
            }
            return cell
        }else{
            let indexCell = indexPath.row - 1;
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellItems", for: indexPath) as! AccountViewTableViewCell
            
            cell.infoLabel?.text = tableItems[indexCell]
            cell.infoImage.image = UIImage(named: "\(tableImage[indexCell])")
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row{
        case 1:
            self.performSegue(withIdentifier: "InfoProfile", sender: self)
        case 2:
            self.performSegue(withIdentifier: "Rating", sender: self)
        case 3:
            self.performSegue(withIdentifier: "Setting", sender: self)
        case 4:
            self.performSegue(withIdentifier: "AboutUs", sender: self)
        case 5:
            
            let dialogMessage = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
            
            let ok = UIAlertAction(title: "Log Out", style: .default, handler: { (action) -> Void in
                self.logout()
            })
            
            ok.setValue(UIColor.red, forKey: "titleTextColor")
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            }
            
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            
            self.present(dialogMessage, animated: true, completion: nil)
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    

    func logout(){
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        } catch let err {
            print(err)
        }
    }
    
    
}
