//
//  HistorySharerViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 30/03/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit
import Firebase

class HistorySharerViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    var roomId = ""
    var numOfUser = 0
    var available = 0
    
    var leader = ""
    var member = [String]()

    var leaderFname = ""
    var leaderLname = ""
    var leaderGender = ""
    
    var memberFname = [String]()
    var memberLname = [String]()
    var memberGender = [String]()
    var memberShare = [String]()
    
    var guestName = [String]()
    var parentGuest = [String]()
    var parentName = [String]()
    
    var page: Int!
    
    var selectedId = ""
    var selectedName = ""
    
    override func viewDidLoad() {
        print(roomId)
        super.viewDidLoad()
        query()
        page = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(hex: "#151515")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func changeMemberGuest(_ sender: UISegmentedControl) {
        page = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    
    func query() {
        
        self.ref.child("users").child(self.leader).observeSingleEvent(of: .value, with: {(snapshot) in
    
            let value = snapshot.value as? NSDictionary
            
            self.leaderFname = value?["Fname"] as! String
            self.leaderLname = value?["Lname"] as! String
            self.leaderGender = value?["Gender"] as! String
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
          
        })
        
        for i in 0 ..< self.member.count{
            
            self.ref.child("users").child(self.member[i]).observeSingleEvent(of: .value, with: {(snapshot) in
                let value = snapshot.value as? NSDictionary
                
                self.memberShare.append(self.member[i])
                
                self.memberFname.append(value?["Fname"] as! String)
                self.memberLname.append(value?["Lname"] as! String)
                self.memberGender.append(value?["Gender"] as! String)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
            
            
        }
        
        for i in 0 ..< self.parentGuest.count{
            
            self.ref.child("users").child(self.parentGuest[i]).observeSingleEvent(of: .value, with: {(snapshot) in
                let value = snapshot.value as? NSDictionary
                
                let fname = value?["Fname"] as! String
                let lname = value?["Lname"] as! String
                
                self.parentName.append(fname + " " + lname)
            })
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}

extension HistorySharerViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if page == 0{
            return member.count + 2
        }else{
            return parentGuest.count + 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = 75.0
        
        if page == 0 && indexPath.row == 0 || page == 1 && indexPath.row == 0{
            height = 45.0
        }else if page == 0 && indexPath.row != 0{
            height = 65.0
        }
        
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SharerTableViewCell
        let guestCell = tableView.dequeueReusableCell(withIdentifier: "guestCell") as! SharerTableViewCell
        
        guestCell.selectionStyle = .none
        cell.leaderLabel.isHidden = true
    
        headerCell?.selectionStyle = .none
        
        if page == 0 {
            switch indexPath.row{
            case 0:
                return headerCell!
            case 1:
                cell.leaderLabel.isHidden = false
                print(leaderFname)
                if leaderFname != ""{
                    cell.profileImage.image = nil
                    self.downloadImage(id: self.leader, completion: { url in
                        cell.profileImage.image = nil
                        cell.profileImage.downloaded(from: url)
                        cell.profileImage.setRound()
                    })
                    cell.profileImage.setRound()
                    cell.nameLabel.text = leaderFname + " " + leaderLname
                }
                return cell
                
            case 2 ... member.count + 2:
                cell.leaderLabel.isHidden = true
                
                if memberFname.count == member.count && memberLname.count == member.count{
                    
                    cell.nameLabel.text = self.memberFname[indexPath.row - 2] + " " + self.memberLname[indexPath.row - 2]
                    self.downloadImage(id: self.memberShare[indexPath.row - 2], completion: { url in
                        cell.profileImage.image = nil
                        cell.profileImage.downloaded(from: url)
                        cell.profileImage.setRound()
                    })
                }
                return cell
            default:
                break
            }
        }else{
            switch indexPath.row{
            case 0:
                return headerCell!
            case 1 ..< parentGuest.count + 1:
                guestCell.nameLabel.text = guestName[indexPath.row - 1]
                guestCell.addedByLabel.text = "Added By: " + parentName[indexPath.row  - 1]
                guestCell.profileImage.image = UIImage(named: "guest")
                return guestCell
            default:
                break
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //Alerts
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        
        if page == 0{
            switch indexPath.row{
            case 1:
                self.checkifrated(id: leader, completion: { rated in
                    if self.leader == self.curUser{
                        self.selectedId = self.leader
                        self.selectedName = self.leaderFname + " " + self.leaderLname
                        
                        let dialogMessage = UIAlertController(title: nil, message: self.leaderFname + " " + self.leaderLname, preferredStyle: .actionSheet)
                        
                        
                        let view = UIAlertAction(title: "View Profile", style: .default, handler: { (action) -> Void in
                            
                            self.performSegue(withIdentifier: "profile", sender: self)
                        })
                        
                        dialogMessage.addAction(view)
                        dialogMessage.addAction(cancel)
                        
                        self.present(dialogMessage, animated: true, completion: nil)
                    }else if rated == 0{
                        let dialogMessage = UIAlertController(title: nil, message: self.leaderFname + " " + self.leaderLname, preferredStyle: .actionSheet)
                        
                        self.selectedId = self.leader
                        self.selectedName = self.leaderFname + " " + self.leaderLname
                        
                        let view = UIAlertAction(title: "View Profile", style: .default, handler: { (action) -> Void in
                            self.performSegue(withIdentifier: "profile", sender: self)
                        })
                        
                        let rate = UIAlertAction(title: "Rate Profile", style: .default, handler: { (action) -> Void in
                            self.performSegue(withIdentifier: "rate", sender: self)
                        })
                        
                        
                        dialogMessage.addAction(rate)
                        dialogMessage.addAction(view)
                        dialogMessage.addAction(cancel)
                        
                        self.present(dialogMessage, animated: true, completion: nil)
                    }else{
                        self.selectedId = self.leader
                        self.selectedName = self.leaderFname + " " + self.leaderLname
                        
                        let dialogMessage = UIAlertController(title: nil, message: self.leaderFname + " " + self.leaderLname, preferredStyle: .actionSheet)
                        
                        
                        let view = UIAlertAction(title: "View Profile", style: .default, handler: { (action) -> Void in
                            
                            self.performSegue(withIdentifier: "profile", sender: self)
                        })
                        
                        dialogMessage.addAction(view)
                        dialogMessage.addAction(cancel)
                        
                        self.present(dialogMessage, animated: true, completion: nil)
                    }
                    
                })
                
            case 2 ..< member.count+2:
                
                //let rated = self.checkifrated(id: memberShare[indexPath.row - 2])
                self.checkifrated(id: memberShare[indexPath.row - 2], completion: { rated in
                    if self.memberShare[indexPath.row - 2] == self.curUser{
                        let dialogMessage = UIAlertController(title: nil, message: self.memberFname[indexPath.row - 2] + " " + self.memberLname[indexPath.row - 2], preferredStyle: .actionSheet)
                        
                        self.selectedId = self.memberShare[indexPath.row - 2]
                        
                        let view = UIAlertAction(title: "View Profile", style: .default, handler: { (action) -> Void in
                            
                            self.performSegue(withIdentifier: "profile", sender: self)
                        })
                        
                        
                        dialogMessage.addAction(view)
                        dialogMessage.addAction(cancel)
                        
                        self.present(dialogMessage, animated: true, completion: nil)
                    }else if rated == 0{
                        
                        let dialogMessage = UIAlertController(title: nil, message:self.memberFname[indexPath.row - 2] + " " + self.memberLname[indexPath.row - 2], preferredStyle: .actionSheet)
                        
                        self.selectedId = self.memberShare[indexPath.row - 2]
                        self.selectedName =  self.memberFname[indexPath.row - 2] + " " + self.memberLname[indexPath.row - 2]
                        
                        let view = UIAlertAction(title: "View Profile", style: .default, handler: { (action) -> Void in
                            
                            self.performSegue(withIdentifier: "profile", sender: self)
                            
                        })
                        
                        let rate = UIAlertAction(title: "Rate Profile", style: .default, handler: { (action) -> Void in
                            self.performSegue(withIdentifier: "rate", sender: self)
                        })
                        
                        dialogMessage.addAction(rate)
                        dialogMessage.addAction(view)
                        dialogMessage.addAction(cancel)
                        
                        self.present(dialogMessage, animated: true, completion: nil)
                    }else{
                        let dialogMessage = UIAlertController(title: nil, message: self.memberFname[indexPath.row - 2] + " " + self.memberLname[indexPath.row - 2], preferredStyle: .actionSheet)
                        
                        self.selectedId = self.memberShare[indexPath.row - 2]
                        
                        let view = UIAlertAction(title: "View Profile", style: .default, handler: { (action) -> Void in
                            
                            self.performSegue(withIdentifier: "profile", sender: self)
                        })
                        
                        
                        dialogMessage.addAction(view)
                        dialogMessage.addAction(cancel)
                        
                        self.present(dialogMessage, animated: true, completion: nil)
                    }
                    
                })
                
                
                
                
                
            default:
                break
            }
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profile"{

            let profileVC = segue.destination as! SharerProfileViewController

            profileVC.id = selectedId

        }
        
        if segue.identifier == "rate"{
            let rateVC = segue.destination as! HistoryRateViewController
            
            
            rateVC.sharerID.append(self.selectedId)
            rateVC.sharerName.append(self.selectedName)
            rateVC.curRoom = roomId
        }
    }
    
    func downloadImage(id: String, completion: @escaping (_ url: URL) -> Void) {
        let storageRef = Storage.storage().reference().child("profile/\(id).jpg")
        
        storageRef.downloadURL { url, error in
            if let error = error {
                print(error)
            } else {
                completion(url!)
            }
        }
    }
    
    func checkifrated(id: String, completion: @escaping (_ rated: Int) -> Void) {
        
        var x = 0
        self.ref.child("travel").child(self.roomId).observeSingleEvent(of: .value, with: {(snapshot) in
            
            for child in snapshot.childSnapshot(forPath: "rated").children{
                
                let value = child as! DataSnapshot
                let key = value.key
                
                if key == id{
                    for userSnapshot in (child as AnyObject).children.allObjects as! [DataSnapshot] {
                        let userID = userSnapshot.childSnapshot(forPath: "UserId").value
                        print(userID)
                        //return 0 if not rated 1 if rated
                        if self.curUser == userID as? String{
                            x = 1
                            print(x)
                        }
                    }
                }
                
            }
            completion(x)
        })
        
       
    }
    
    
}


