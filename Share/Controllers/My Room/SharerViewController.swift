//
//  SharerViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 30/03/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit
import Firebase

class SharerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    var curRoom = ""
    var numOfUser = 0
    var available = 0
    //BUG PLEASE FIX NUMBER OF SHARERS
    
    var leader = ""
    var member = [String]()
    
    var leaderURL = [URL]()
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
 
    override func viewDidLoad() {
        super.viewDidLoad()
        page = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(hex: "#151515")
    }

    @IBAction func changeMemberGuest(_ sender: UISegmentedControl) {
        page = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        parentName.removeAll()
//        member.removeAll()
        memberFname.removeAll()
        memberLname.removeAll()
        memberShare.removeAll()
//        parentGuest.removeAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        query()
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
                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
            })
        
            //self.tableView.reloadData()
        }
    }
    
    //Kick Guest
    func kickGuest(member: String) -> Int{
        
        var x = 0
        
        if self.parentGuest.count != 0{
            for i in 0 ..< self.parentGuest.count{
                print(parentGuest.count, i)
                if self.parentGuest[i] == member{
                    //Remove guest
                    self.ref.child("travel").child(self.curRoom).child("Guests").queryOrdered(byChild: "CompanionId:").queryEqual(toValue: member).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        snapshot.ref.removeValue(completionBlock: { (error, reference) in
                            if error != nil {
                                print("error")
                            }
                        })
                        
                    })
                    
                    //self.parentGuest.remove(at: i)
                    //self.guestName.remove(at: i)
                    
                    x += 1
                }
            }
            
        }
        
        return x
    }
    
    //Full to Not Full Available
    func fullToNotFull(){
        if self.available == 3{
            self.ref.child("travel").child(self.curRoom).updateChildValues(["Available" : 1])
        }
    }
    
    //Leaving the room Success
    func leaveRoomSuccess(){
        
        let dialogMessage = UIAlertController(title: "Success", message: "Successfully left the room", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Dismiss", style: .cancel) { (action) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    
    //Kicking the room Success
    func kickRoomSuccess(){
        
        let dialogMessage = UIAlertController(title: "Success", message: "Successfully kicked the person", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Dismiss", style: .cancel) { (action) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
}

extension SharerViewController : UITableViewDelegate, UITableViewDataSource{
    
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
        
                if leaderFname != ""{
                    self.downloadImage(id: self.leader, completion: { url in
                        cell.profileImage.image = nil
                        cell.profileImage.downloaded(from: url)
                        cell.profileImage.setRound()
                    })
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
                guestCell.addedByLabel.text = "Added By: " +    parentName[indexPath.row  - 1]
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
                if leader == curUser{
                    let dialogMessage = UIAlertController(title: nil, message: leaderFname + " " + leaderLname, preferredStyle: .actionSheet)
                    //Promote Someone to Leader
                    let leave = UIAlertAction(title: "Leave Group", style: .default, handler: { (action) -> Void in
            
                    })
                    
                    leave.setValue(UIColor.red, forKey: "titleTextColor")
                    
                    dialogMessage.addAction(leave)
                    dialogMessage.addAction(cancel)
                    
                    self.present(dialogMessage, animated: true, completion: nil)
                }else{
                    let dialogMessage = UIAlertController(title: nil, message: leaderFname + " " + leaderLname, preferredStyle: .actionSheet)
                    
                    self.selectedId = leader
                    let view = UIAlertAction(title: "View Profile", style: .default, handler: { (action) -> Void in
                        self.performSegue(withIdentifier: "profile", sender: self)
                    })
                    
                    dialogMessage.addAction(view)
                    dialogMessage.addAction(cancel)
                    
                    self.present(dialogMessage, animated: true, completion: nil)
                }
            case 2 ..< member.count+2:
                
                //IF CURRENT USER IS A LEADER
                if leader == curUser{
                    let dialogMessage = UIAlertController(title: nil, message: memberFname[indexPath.row - 2] + " " + memberLname[indexPath.row - 2], preferredStyle: .actionSheet)
                    
                    let kick = UIAlertAction(title: "Remove from Group", style: .default, handler: { (action) -> Void in
                        
            
                    let dialogMessage = UIAlertController(title: nil, message: "Are you sure you want to kick this person?", preferredStyle: .alert)
                        
                    let ok = UIAlertAction(title: "Kick", style: .default, handler: { (action) -> Void in
                        
                        //Check if travel is on going
                        if self.available == 0 || self.available == 2{
                                let dialogMessage = UIAlertController(title: "Error Kicking", message: "Travel has Already Started!", preferredStyle: .alert)
                                
                                let cancel = UIAlertAction(title: "Dismiss", style: .cancel) { (action) -> Void in
                                }
                                
                                dialogMessage.addAction(cancel)
                                
                                self.present(dialogMessage, animated: true, completion: nil)
                        }else{
                            //Counter for number of people to be kicked
                            var countOfKicked = 0
                            
                            //Kick Guest and number of guest of a kicked person
                            countOfKicked = self.kickGuest(member: self.memberShare[indexPath.row - 2])
                            
                            self.ref.child("travel").child(self.curRoom).observeSingleEvent(of: .value, with: {(snapshot) in
                                        
                                        let dataUsers = snapshot.childSnapshot(forPath: "users")
                                        let userDict = dataUsers.value as! [String: String?]
                                
                                //if Member Chosen == Member1/Member2/Member3
                                if dataUsers.hasChild("Member1") && userDict["Member1"] == self.memberShare[indexPath.row - 2]{
                                    self.ref.child("travel").child(self.curRoom).child("users").child("Member1").removeValue()
                                    
                                    //Update Current Room to 0
                                    self.ref.child("users").child(self.memberShare[indexPath.row - 2]).updateChildValues(["CurRoom" : "Kicked"])
                                            
                                            let newNumOfUser = self.numOfUser - (countOfKicked + 1)
                                            
                                            self.numOfUser = newNumOfUser
                                            
                                            self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : self.numOfUser])
                                            
                                            self.member.remove(at: indexPath.row - 2)
                                            
                                            //Update from full to not full
                                            self.fullToNotFull()
                                            
                                    //Pop view controller
                                    self.kickRoomSuccess()
                                }else if dataUsers.hasChild("Member2") && userDict["Member2"] == self.memberShare[indexPath.row - 2]{
                                        self.ref.child("travel").child(self.curRoom).child("users").child("Member2").removeValue()
                                            
                                            let newNumOfUser = self.numOfUser - (countOfKicked + 1)
                                            
                                            self.numOfUser = newNumOfUser
                                    
                                    //Update Current Room to 0
                                    self.ref.child("users").child(self.memberShare[indexPath.row - 2]).updateChildValues(["CurRoom" : "Kicked"])
                                    
                                            self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : self.numOfUser])
                                            self.member.remove(at: indexPath.row - 2)
                                            
                                            self.fullToNotFull()
                                    //Pop view controller
                                    self.kickRoomSuccess()
                                }else if dataUsers.hasChild("Member3") && userDict["Member3"] == self.memberShare[indexPath.row - 2]{
                                
                                self.ref.child("travel").child(self.curRoom).child("users").child("Member3").removeValue()
                                            
                                            let newNumOfUser = self.numOfUser - (countOfKicked + 1)
                                            
                                            self.numOfUser = newNumOfUser
                                    
                                    //Update Current Room to 0
                                    self.ref.child("users").child(self.memberShare[indexPath.row - 2]).updateChildValues(["CurRoom" : "Kicked"])
                                    
                                            self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : self.numOfUser])
                                            self.member.remove(at: indexPath.row - 2)
                                            
                                            self.fullToNotFull()
                                            //Pop view controller
                                            self.kickRoomSuccess()
                                    }
                                })
                            }
                            
                            
                        })
                        
                        ok.setValue(UIColor.red, forKey: "titleTextColor")
                        
                        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                        }
                        
                        dialogMessage.addAction(ok)
                        dialogMessage.addAction(cancel)
                        
                        self.present(dialogMessage, animated: true, completion: nil)
                    })
                    
                    kick.setValue(UIColor.red, forKey: "titleTextColor")
                    
                    self.selectedId = memberShare[indexPath.row - 2]
                    
                    let view = UIAlertAction(title: "View Profile", style: .default, handler: { (action) -> Void in
                        
                        self.performSegue(withIdentifier: "profile", sender: self)
                    })
                    
                    dialogMessage.addAction(view)
                    
                    
                    dialogMessage.addAction(kick)
                    dialogMessage.addAction(cancel)
                    
                    self.present(dialogMessage, animated: true, completion: nil)
                    
                //CURRENT USER IS NOT A LEADER
                }else if memberShare[indexPath.row - 2] == curUser{
                    let dialogMessage = UIAlertController(title: nil, message: memberFname[indexPath.row - 2] + " " + memberLname[indexPath.row - 2], preferredStyle: .actionSheet)
                    
                    let leave = UIAlertAction(title: "Leave Group", style: .default, handler: { (action) -> Void in
                        
                        let dialogMessage = UIAlertController(title: nil, message: "Are you sure you want to leave the group?", preferredStyle: .alert)
                        
                        let ok = UIAlertAction(title: "Leave", style: .default, handler: { (action) -> Void in
                      
                            //Check if Travel is on going
                            if self.available == 0 || self.available == 2{
                                let dialogMessage = UIAlertController(title: "Error Leaving", message: "Travel has Already Started!", preferredStyle: .alert)
                                
                                let cancel = UIAlertAction(title: "Dismiss", style: .cancel) { (action) -> Void in
                                    
                                }
                                
                                dialogMessage.addAction(cancel)
                                
                                self.present(dialogMessage, animated: true, completion: nil)
                                
                                //LEAVE GROUP
                            }else{
                                
                                //Counter for number of people to leave
                                var countOfLeave = 0
                                
                                //Leave Guest and number of guest of a kicked person
                                countOfLeave = self.kickGuest(member: self.memberShare[indexPath.row - 2])
                                
                                self.ref.child("travel").child(self.curRoom).observeSingleEvent(of: .value, with: {(snapshot) in
                                    
                                    let dataUsers = snapshot.childSnapshot(forPath: "users")
                                    let userDict = dataUsers.value as! [String: String?]
                                    
                                    //if Member Chosen == Member1/Member2/Member3
                                    if dataUsers.hasChild("Member1") && userDict["Member1"] == self.memberShare[indexPath.row - 2]{
                                        self.ref.child("travel").child(self.curRoom).child("users").child("Member1").removeValue()
                                        
                                        let newNumOfUser = self.numOfUser - (countOfLeave + 1)
                                        
                                        self.numOfUser = newNumOfUser
                                        
                                        self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : self.numOfUser])
                                        
                                        self.member.remove(at: indexPath.row - 2)
                                        
                                        //Update from full to not full
                                        self.fullToNotFull()
                                        
                                        //Update Current Room to 0
                                        self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                                        
                                        
                                        //Pop view controller
                                        self.leaveRoomSuccess()
                                        
                                    }else if dataUsers.hasChild("Member2") && userDict["Member2"] == self.memberShare[indexPath.row - 2]{
                                        self.ref.child("travel").child(self.curRoom).child("users").child("Member2").removeValue()
                                        
                                        let newNumOfUser = self.numOfUser - (countOfLeave + 1)
                                        
                                        self.numOfUser = newNumOfUser
                                        
                                        self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : self.numOfUser])
                                        self.member.remove(at: indexPath.row - 2)
                                        
                                        self.fullToNotFull()
                                        
                                        //Update Current Room to 0
                                        self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                                        
                                        //Pop view controller
                                        self.leaveRoomSuccess()
                                        
                                    }else if dataUsers.hasChild("Member3") && userDict["Member3"] == self.memberShare[indexPath.row - 2]{
                                        
                                        self.ref.child("travel").child(self.curRoom).child("users").child("Member3").removeValue()
                                        
                                        let newNumOfUser = self.numOfUser - (countOfLeave + 1)
                                        
                                        self.numOfUser = newNumOfUser
                                        
                                        self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : self.numOfUser])
                                        
                                        self.member.remove(at: indexPath.row - 2)
                                        
                                        self.fullToNotFull()
                                        
                                        //Update Current Room to 0
                                        self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                                        
                                        
                                        //Pop view controller
                                        self.leaveRoomSuccess()
                                    }
                                })
                            }
                            
                        })
                        
                        ok.setValue(UIColor.red, forKey: "titleTextColor")
                        
                        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                        }
                        
                        dialogMessage.addAction(ok)
                        dialogMessage.addAction(cancel)
                        self.present(dialogMessage, animated: true, completion: nil)
                    })
                    
                    leave.setValue(UIColor.red, forKey: "titleTextColor")
                    
                    dialogMessage.addAction(leave)
                    dialogMessage.addAction(cancel)
                    
                    self.present(dialogMessage, animated: true, completion: nil)
                }else{
                    let dialogMessage = UIAlertController(title: nil, message: memberFname[indexPath.row - 2] + " " + memberLname[indexPath.row - 2], preferredStyle: .actionSheet)
                    
                    self.selectedId = memberShare[indexPath.row - 2]
                    
                    let view = UIAlertAction(title: "View Profile", style: .default, handler: { (action) -> Void in
                        
                        self.performSegue(withIdentifier: "profile", sender: self)
                    })
                    
                    
                    dialogMessage.addAction(view)
                    dialogMessage.addAction(cancel)
                    
                    self.present(dialogMessage, animated: true, completion: nil)
                }
                
                
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
    

    
   
    
}


