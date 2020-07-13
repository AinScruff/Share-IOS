//
//  MyRoomViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 16/03/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import UserNotifications
import CoreLocation
class MyRoomViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var addGuestButton: UIBarButtonItem!
    @IBOutlet weak var myRoomTableView: UITableView!
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    
    
    //Section
    var sections = ["", "TRAVEL", "PREFERENCES", "PRIVACY"]
    
    
    //User Details
    var pin = NSNumber()
    var fname = ""
    var fullName = ""
    var guardianContact = ""
    
    
    //Travel Details
    var curRoom = "0"
    var originString = ""
    var destinationString = ""
    var estimatedTravelTime = NSNumber()
    var originLat = NSNumber()
    var originLong = NSNumber()
    var DestinationLat = NSNumber()
    var DestinationLong = NSNumber()
    var available = NSNumber()
    var travelURL: URL!
    var minFare = NSNumber()
    var maxFare = NSNumber()
    var numOfUser = NSNumber()
    
    //Time
    var departureTime = ""
    var hour = NSNumber()
    var minute = NSNumber()
    
    //Taxi
    var taxiOperator = ""
    var taxiPlate = ""
    var taxiNum = ""
    
    //Users
    var leader = ""
    var leaderName = ""
    
    var member1 = ""
    var member2 = ""
    var member3 = ""
    var member1Name = ""
    var member2Name = ""
    var member3Name = ""
    
    
    var guestParent = [String]()
    var guestName = [String]()

    
    var spinner = UIView()
    
    
    //Timer to do
    var timer = Timer()
    
    
    
    //Message Users
    var namesDictionary = [String : String]()
    
    var locationManager = CLLocationManager()
    var lat = 0.0
    var long = 0.0
    
    override func viewDidLoad() {
        
        myRoomTableView.tableFooterView = UIView()
        myRoomTableView.backgroundColor = UIColor(hex: "#151515")
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()

        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabItems = tabBarController?.tabBar.items {
        
            chatRead(id: curUser!, completion: { x in
                let tabItem = tabItems[1]
            
                if self.curRoom != "0"{
                    if x != 0{
                        tabItem.badgeValue = String(x)
                    }else{
                        tabItem.badgeValue = nil
                    }
                }else{
                    tabItem.badgeValue = nil
                }
                
                
                DispatchQueue.main.async {
                    self.myRoomTableView.reloadData()
                }
            })
            
            
        }
        
        myRoomTableView.isHidden = true
    
        self.spinner = UIViewController.displaySpinner(onView: self.view)
        self.navigationItem.rightBarButtonItems?[0].isEnabled = false
        if curRoom != "Requesting" && curRoom != "0"{
            myRoomTableView.isHidden = false
        }
        
        let backgroundQueue = DispatchQueue.global(qos: .background)
        
        backgroundQueue.async {
            self.getMyRoom()
            DispatchQueue.main.async {
                UIViewController.removeSpinner(spinner: self.spinner)
                self.myRoomTableView.reloadData()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.reset()
    }
    
    func chatRead(id: String, completion: @escaping (_ x: Int) -> Void){
        ref.child("users").child(curUser!).observe(.value, with: {(snapshot) in

            let value = snapshot.value as? NSDictionary

            //Get User

            let current = value?["CurRoom"] as! String
            let countread = value?["count_read"] as! NSNumber
            
            //count numberofID
            if current != "0" && current != "Requesting" && current != "Kicked"{
                if countread != 0{
                    self.ref.child("travel").child(current).child("messages").observe(.value, with: {(snapshot) in
                        completion(Int(snapshot.childrenCount) - countread.intValue)
                    })
                }
            }
        })
    }

  
    fileprivate func sendMSG() {
        let accountSID = "AC7f18475068710bc061de9206a00557c4"
        let authToken = "4a1950c51a6157041df51c7c1578236d"
            
        let url = "https://api.twilio.com/2010-04-01/Accounts/"+accountSID+"/Messages"
        let parameters = ["From": "+14805089792",
                        "To": "\(self.guardianContact)",
                        "Body": "SHARE: \(self.fullName) has entered an invalid Pin. Please make sure of his/her safety. Do not reply to this message."]
            
        Alamofire.request(url, method: .post, parameters: parameters, encoding:
            URLEncoding.default).authenticate(user: accountSID, password: authToken).responseString { response in
                switch response.result {
                case .success:
                    self.performSegue(withIdentifier: "rate", sender: self)
                case .failure(let error):
                    print(error)
                }
            }
        
    }
    
    func getMyRoom(){
        //check if room joined
        reset()
        
        ref.child("users").child(curUser!).observe(.value, with: {(snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            //Get User
            self.pin = value?["Pin"] as! NSNumber
            self.fname = value?["Fname"] as! String
            let lname = value?["Lname"] as! String
            
            self.fullName = self.fname + " " + lname
            self.guardianContact = value?["EmergencyContact"] as! String
            
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updatelatlong), userInfo: nil, repeats: true)
            
            self.curRoom = String(format: "%@", value?["CurRoom"] as! CVarArg)
            
                if String(format: "%@", value?["CurRoom"] as! CVarArg) != "0" && String(format: "%@", value?["CurRoom"] as! CVarArg) != "Requesting" && String(format: "%@", value?["CurRoom"] as! CVarArg) != "Kicked"{
                    self.myRoomTableView.isHidden = false
                    
                    self.navigationItem.rightBarButtonItems?[0].isEnabled = true
                    
                    self.ref.child("travel").child(self.curRoom).observe(.value, with: {(snapshot) in
                    
                    let roomValue = snapshot.value as? NSDictionary
    
                    if roomValue == nil{
                            self.reset()
                    }else{
                        //Completion block
                        self.available = roomValue?["Available"] as! NSNumber
                        self.originString = roomValue?["OriginString"] as! String
                        self.destinationString = roomValue?["DestinationString"] as! String
                        self.estimatedTravelTime = roomValue?["EstimatedTravelTime"] as! NSNumber
                        self.numOfUser = roomValue?["NoOfUsers"] as! NSNumber
                        
                        //Make available full
                        if self.numOfUser == 4 && self.available == 1{
                            self.ref.child("travel").child(self.curRoom).updateChildValues(["Available" : 3])
                        }
                        
                        //Get Origin Lat/Long
                        let dataOrigin = snapshot.childSnapshot(forPath: "Origin")
                        let originDict = dataOrigin.value as! [String: NSNumber?]
                        
                        self.originLat = originDict["latitude"] as! NSNumber
                        self.originLong = originDict["longitude"] as! NSNumber
                        
                        //Get Destination Lat/Long
                        let dataDestination = snapshot.childSnapshot(forPath: "Destination")
                        let Destinationdict = dataDestination.value as! [String: NSNumber?]
                        
                        self.DestinationLat = Destinationdict["latitude"] as! NSNumber
                        self.DestinationLong = Destinationdict["longitude"] as! NSNumber
                        
                        
                        //Get Fare
                        self.minFare = roomValue?["MinimumFare"] as! NSNumber
                        self.maxFare = roomValue?["MaximumFare"] as! NSNumber
                        
                        
                        //Get Time
                        let dict = snapshot.childSnapshot(forPath: "DepartureTime").value as! [String: Any?]
                        
                        self.hour = dict["DepartureHour"] as! NSNumber
                        self.minute = dict["DepartureMinute"] as! NSNumber
                        let time = self.hour.stringValue + ":" + self.minute.stringValue
                      
                        //Schedule the time
                    
                        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        self.scheduleLocal(title: "Time to go", body: "Time to start your Travel", category: "alarm", hour: self.hour.intValue, minute: self.minute.intValue)
                        
                        
                        
                        var newHour = 0
                        var newMinute = 0
                        
                        if self.hour.intValue == 1 && self.minute.intValue == 0{
                            newHour = 24
                            newMinute = 55
                        }else if self.minute.intValue == 0{
                            newHour = self.hour.intValue - 1
                            newMinute = 55
                        }else{
                            newHour = self.hour.intValue
                            newMinute = self.minute.intValue - 5
                        }
                        
                        self.scheduleLocal(title: "Almost Time to go", body: "It is almost time to go. Please be on the meeting point in 5 minutes", category: "fiveminutes", hour: newHour, minute: newMinute)
                        
                        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
                            
                            for request in requests {
                                if request.identifier == "alarm" {
                                    
                                    //Notification already exists. Do stuff.
                               
                                } else if request === requests.last {
                                    
                                }
                            }
                        })
                        
                
                        
                        
                        //Convert
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm"
                        
                        let date = dateFormatter.date(from: time)
                        dateFormatter.dateFormat = "h:mm a"
               
                        self.departureTime = dateFormatter.string(from: date!)
                        
                        //Get Taxi
                        if snapshot.hasChild("taxi"){
                            let dataTaxi = snapshot.childSnapshot(forPath: "taxi")
                            let taxiDict = dataTaxi.value as! [String: String?]
                            
                            self.taxiOperator = taxiDict["Operator"] as! String
                            self.taxiNum = taxiDict["TaxiNumber"] as! String
                            self.taxiPlate = taxiDict["PlateNumber"] as! String
                        }
                        
                        
                        //Get message users
                        for child in snapshot.childSnapshot(forPath: "messages").children{
                            
                                let child = child as! DataSnapshot
                                let dict = child.value! as! [String:Any]
                                
                                self.getmessageUsers(id: dict["MessageUser"] as! String)
                            
                        }
                        
                        //Get Users
                        let dataUsers = snapshot.childSnapshot(forPath: "users")
                        let userDict = dataUsers.value as! [String: String?]
                        
                        
                        //Leader
                        self.leader = userDict["Leader"] as! String
                        
                        DispatchQueue.main.async {
                            self.myRoomTableView.reloadData()
                        }
                        
                        if self.leader != self.curUser{
                            self.ref.child("users").child(self.leader).observeSingleEvent(of: .value, with: {(snapshot) in
                                let value = snapshot.value as? NSDictionary
                                let memNname = value?["Fname"] as! String
                                let memLname = value?["Lname"] as! String
                                
                                self.leaderName = memNname + " " + memLname
                            })
                        }

                    
                        //Member1
                        if dataUsers.hasChild("Member1"){
                            self.member1 = userDict["Member1"] as! String
                            
                            
                            if self.member1 != self.curUser{
                                self.ref.child("users").child(self.member1).observeSingleEvent(of: .value, with: {(snapshot) in
                                    let value = snapshot.value as? NSDictionary
                                    let memNname = value?["Fname"] as! String
                                    let memLname = value?["Lname"] as! String
                                    self.member1Name = memNname + " " + memLname
                                    
                                })
                            }
                        }
                        
                        //Member2
                        if dataUsers.hasChild("Member2"){
                            self.member2 = userDict["Member2"] as! String
                            
                            if self.member2 != self.curUser{
                                self.ref.child("users").child(self.member2).observeSingleEvent(of: .value, with: {(snapshot) in
                                    let value = snapshot.value as? NSDictionary
                                    let memNname = value?["Fname"] as! String
                                    let memLname = value?["Lname"] as! String
                                    
                                    
                                    self.member2Name = memNname + " " + memLname
                                })
                            }
                            
                        }
                        
                        
                        //Member3
                        if dataUsers.hasChild("Member3"){
                            self.member3 = userDict["Member3"] as! String
                            
                            if self.member3 != self.curUser{
                                self.ref.child("users").child(self.member3).observeSingleEvent(of: .value, with: {(snapshot) in
                                    let value = snapshot.value as? NSDictionary
                                    let memNname = value?["Fname"] as! String
                                    let memLname = value?["Lname"] as! String
                                    
                                    
                                    self.member3Name = memNname + " " + memLname
                                })
                            }
                        }
                        
                        if self.curUser == userDict["Leader"] as! String{
                            //Get Pending Users
                            
                            if self.numOfUser.intValue == 4 {
                                self.ref.child("travel").child(self.curRoom).child("pendingusers").removeValue()
                            }else if snapshot.hasChild("pendingusers"){
                                
                                //Pending (change to auto iD)
                                for child in snapshot.childSnapshot(forPath: "pendingusers").children{
                                    let child = child as! DataSnapshot
                                    let dict = child.value! as! [String:Any]

                                    let pendingUser = dict["UserId"] as! String
                                    let key = child.key
                                    
                                    self.getName(id: pendingUser, completion: { fname in
                                       
                                        if self.numOfUser.intValue != 4{
                                            let dialogMessage = UIAlertController(title: "\(fname) wants to join the group", message: nil, preferredStyle: .alert)
                                            
                                            let ok = UIAlertAction(title: "Accept", style: .default) { (action) -> Void in
                                                
                                                
                                                self.ref.child("travel").child(self.curRoom).child("pendingusers").child(key).removeValue()
                                                
                                                if self.member1 == ""{
                                                    
                                                    self.ref.child("travel").child(self.curRoom).child("users").updateChildValues(["Member1" : pendingUser])
                                                    self.ref.child("users").child(pendingUser).updateChildValues(["CurRoom" : self.curRoom])
                                                    self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : self.numOfUser.intValue + 1])
                                                    
                                                }else if self.member2 == ""{
                                                    self.ref.child("travel").child(self.curRoom).child("users").updateChildValues(["Member2" : pendingUser])
                                                    self.ref.child("users").child(pendingUser).updateChildValues(["CurRoom" : self.curRoom])
                                                    self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : self.numOfUser.intValue + 1])
                                                }else if self.member3 == ""{
                                                    self.ref.child("travel").child(self.curRoom).child("users").updateChildValues(["Member3" : pendingUser])
                                                    self.ref.child("users").child(pendingUser).updateChildValues(["CurRoom" : self.curRoom])
                                                    self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : self.numOfUser.intValue + 1])
                                                }
                                                
                                                
                                                let alert = UIAlertController(title: "Success", message: "\(fname) is added to the group", preferredStyle: .alert)
                                                
                                                
                                                let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                                                
                                                }
                                                
                                                alert.addAction(dismiss)
                                                self.present(alert, animated: true)
                                                
                                                DispatchQueue.main.async{
                                                    self.myRoomTableView.reloadData()
                                                }
                                                
                                            }
                                            
                                            let cancel = UIAlertAction(title: "Decline", style: .cancel) { (action) -> Void in
                                                
                                                
                                                
                                            self.ref.child("travel").child(self.curRoom).child("pendingusers").child(key).removeValue()
                                                self.ref.child("users").child(pendingUser).updateChildValues(["CurRoom" : 0])
                                                
                                                
                                                let alert = UIAlertController(title: "Success", message: "\(fname) is removed from pending members", preferredStyle: .alert)
                                                
                                                
                                                let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                                                    
                                                    DispatchQueue.main.async {
                                                        self.myRoomTableView.reloadData()
                                                    }
                                                    
                                                }
                                                
                                                alert.addAction(dismiss)
                                                self.present(alert, animated: true)
                                                DispatchQueue.main.async{
                                                    self.myRoomTableView.reloadData()
                                                }
                                            }
                                            
                                            cancel.setValue(UIColor.red, forKey: "titleTextColor")
                                            dialogMessage.addAction(ok)
                                            dialogMessage.addAction(cancel)
                                            
                                            self.present(dialogMessage, animated: true, completion: nil)
                                        }else{
                                           self.ref.child("users").child(pendingUser).updateChildValues(["CurRoom" : 0])
                                            self.ref.child("travel").child(self.curRoom).child("pendingusers").removeValue()
                                        }
                                        
                                    })
                                }
                            }
                        }
                        
                        
                        
                        self.guestParent.removeAll()
                        //Get Guest
                        for child in snapshot.childSnapshot(forPath: "Guests").children{
                            
                            let child = child as! DataSnapshot
                            let dict = child.value! as! [String:Any]
                            
                            self.guestParent.append(dict["CompanionId"] as! String)
                            self.guestName.append(dict["Name"] as! String)
                        }
                        
                        
                        //End Travel
                        if self.available == 2 && self.curRoom != "0"{
                            let alert = UIAlertController(title: "Travel End", message: "Please input your pin", preferredStyle: .alert)
                            
                            alert.addTextField { (textField) in
                                textField.delegate = self
                                textField.keyboardType = .numberPad
                                textField.isSecureTextEntry = true
                            }
     
                             if let tabItems = self.tabBarController?.tabBar.items {
                                
                            let tabItem = tabItems[1]
                             
                            tabItem.badgeValue = nil
                            let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alert] _ in
                                
                                let answer = alert.textFields![0].text
                                var i = NSNumber()
                                
                                if answer != ""{
                                    i = NSNumber(value: Int(answer!)!)
                                }else{
                                    i = NSNumber(value: 00000)
                                }
                                
                                
                                //First Error
                                if i != self.pin{
                                    let alert = UIAlertController(title: "Error Pin", message: "You have 2 more tries left", preferredStyle: .alert)
                                    
                                    alert.addTextField { (textField) in
                                        textField.delegate = self
                                        textField.keyboardType = .numberPad
                                        textField.isSecureTextEntry = true
                                    }
                                    
                                    let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alert] _ in
                                        
                                        alert.textFields![0].keyboardType = .numberPad
                                        let answer = alert.textFields![0].text
                                        
                                        if answer != ""{
                                            i = NSNumber(value: Int(answer!)!)
                                        }else{
                                            i = NSNumber(value: 00000)
                                        }
                                        
                                        //Second Error
                                        if i != self.pin{
                                            let alert = UIAlertController(title: "Error Pin", message: "You have 1 more try left", preferredStyle: .alert)
                                            
                                            alert.addTextField { (textField) in
                                                textField.delegate = self
                                                textField.keyboardType = .numberPad
                                                textField.isSecureTextEntry = true
                                            }
                                            
                                            let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alert] _ in
                                                
                                                
                                                alert.textFields![0].keyboardType = .numberPad
                                                let answer = alert.textFields![0].text
                                                
                                                if answer != ""{
                                                    i = NSNumber(value: Int(answer!)!)
                                                }else{
                                                    i = NSNumber(value: 00000)
                                                }
                                                
                                                //Third Error
                                                if i != self.pin{
                                                    let alert = UIAlertController(title: "Error Pin", message: "You have 0 tries left", preferredStyle: .alert)
                                                    
                                                    alert.addTextField { (textField) in
                                                        textField.delegate = self
                                                        textField.keyboardType = .numberPad
                                                        textField.isSecureTextEntry = true
                                                    }
                                                    
                                                    let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alert] _ in
                                                        
                                                        alert.textFields![0].keyboardType = .numberPad
                                                        let answer = alert.textFields![0].text
                                                        
                                                        if answer != ""{
                                                            i = NSNumber(value: Int(answer!)!)
                                                        }else{
                                                            i = NSNumber(value: 00000)
                                                        }
                                                        
                                                        if i != self.pin{
                                                            let alert = UIAlertController(title: "Error Pin", message: "Sending Text Message to Guardian", preferredStyle: .alert)
                                                            
                                                            
                                                            let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                                                                self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                                                                self.sendMSG()
                                                            }
                                                            alert.addAction(dismiss)
                                                            self.present(alert, animated: true)
                                                            
                                                        }else{
                                                            //CurRoom to 0
                                                        self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                                                            self.performSegue(withIdentifier: "rate", sender: self)
                                                        }
                                                        
                                                        
                                                    }
                                                    alert.addAction(submitAction)
                                                    self.present(alert, animated: true)
                                                    
                                                }else{
                                                    //CurRoom to 0
                                                    self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                                                    self.performSegue(withIdentifier: "rate", sender: self)
                                                }
                                            }
                                            alert.addAction(submitAction)
                                            self.present(alert, animated: true)
                                        }else{
                                            //CurRoom to 0
                                            self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                                            self.performSegue(withIdentifier: "rate", sender: self)
                                        }
                                    }
                                    alert.addAction(submitAction)
                                    self.present(alert, animated: true)
                                }else{
                                    //CurRoom to 0
                                    self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                                    self.performSegue(withIdentifier: "rate", sender: self)
                                }
                            }
                            alert.addAction(submitAction)
                            self.present(alert, animated: true)
                        }
                        }
                        //self.myRoomTableView.reloadData()
                    }
                    
                })
                    
                //Check image
                let storageRef = Storage.storage().reference().child("travel/"+self.curRoom+".jpg")
                    
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print(error)
                        } else {
                            self.travelURL = url!
                        }
                    }
                    
                }else if String(format: "%@", value?["CurRoom"] as! CVarArg) == "Requesting"{
                    self.timer.invalidate()
                    
                    self.navigationItem.rightBarButtonItems?[0].isEnabled = false
                    
                    if String(format: "%@", value?["CurRoom"] as! CVarArg) == "0" {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                    
                  self.roomLabel.text = "Pending Approval from the Leader"
    
                  self.myRoomTableView.isHidden = true
                }else if String(format: "%@", value?["CurRoom"] as! CVarArg) == "Kicked"{
                    self.timer.invalidate()
                    
                    self.navigationItem.rightBarButtonItems?[0].isEnabled = false
                
                    
                    self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                    
                    let dialogMessage = UIAlertController(title: "Kicked", message: "You have been kicked", preferredStyle: .alert)
                    
                    self.ref.child("users").child(self.curUser!).updateChildValues(["count_read" : 0])
                    
                    let cancel = UIAlertAction(title: "Dismiss", style: .cancel) { (action) -> Void in
                        self.reset()
                        DispatchQueue.main.async {
                            self.myRoomTableView.reloadData()
                        }
                    }
                    
                    dialogMessage.addAction(cancel)
                    
                    self.present(dialogMessage, animated: true, completion: nil)
                    
                    self.myRoomTableView.isHidden = true
                }else{
                    self.timer.invalidate()
                    
                    self.navigationItem.rightBarButtonItems?[0].isEnabled = false
                    
                    if String(format: "%@", value?["CurRoom"] as! CVarArg) == "0" {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                    
                    self.ref.child("users").child(self.curUser!).updateChildValues(["count_read" : 0])
                    
                    self.roomLabel.text = "No Room Joined"
                    self.myRoomTableView.isHidden = true
            }
        })
    }
    
    
    //Update Lat Long
    @objc func updatelatlong()
    {
   
        if curUser != nil{
            self.ref.child("users").child(curUser!).child("Location").updateChildValues(["Latitude" : lat, "Longitude": long])
            
            let location = CLLocation(latitude: lat, longitude: long)
            let endlocation = CLLocation(latitude: DestinationLat.doubleValue, longitude: DestinationLong.doubleValue)
            let distanceinMeters = location.distance(from: endlocation)
            let distancekilo = Double(distanceinMeters) / 1000
    
            if distancekilo <= 1.0{
                ref.child("travel").child(curRoom).updateChildValues(["Available" : 2])
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        let location = locations.last! as CLLocation
        

        lat = location.coordinate.latitude
        long = location.coordinate.longitude
    }
    
    //Full to Not Full Members
    func fullToNotFull(){
        if self.available == 3{
            self.ref.child("travel").child(self.curRoom).updateChildValues(["Available" : 1])
        }
    }
    
    //Leaving the room Success
    func leaveRoomSuccess(){
        
        let dialogMessage = UIAlertController(title: "Success", message: "Successfully left the room", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Dismiss", style: .cancel) { (action) -> Void in
            self.reset()
            DispatchQueue.main.async {
                self.myRoomTableView.reloadData()
            }
        }
        
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    //Kick Guest
    func kickGuest(member: String) -> Int{
        
        var x = 0
        
        if self.guestParent.count != 0{
            for i in 0 ..< self.guestParent.count{
                if self.guestParent[i] == member{
                    //Remove guest
                    self.ref.child("travel").child(self.curRoom).child("Guests").queryOrdered(byChild: "CompanionId:").queryEqual(toValue: member).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        snapshot.ref.removeValue(completionBlock: { (error, reference) in
                            if error != nil {
                                print("error")
                            }
                        })
                        
                    })
                    x += 1
                }
            }
            
        }
        return x
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chat"{
            let navVC = segue.destination as? UINavigationController
            
            let chatVC = navVC?.viewControllers.first as! ChatViewController
            
            timer.invalidate()
            chatVC.roomid = self.curRoom
            chatVC.displayName = self.fname
            chatVC.namesDictionary = self.namesDictionary
        }
        
        if segue.identifier == "travelDetails"{
            let travelDVC = segue.destination as! TravelDetailsViewController
            
            travelDVC.Orig = originString
            travelDVC.Destin = destinationString
            travelDVC.minFare = minFare.stringValue
            travelDVC.maxFare = maxFare.stringValue
            travelDVC.taxiOperator = taxiOperator
            travelDVC.taxiPlateNum = taxiPlate
            travelDVC.taxiNum = taxiNum
            travelDVC.departureTime = departureTime
            travelDVC.estimatedTime = estimatedTravelTime.stringValue
        }
        
        if segue.identifier == "route"{
            let routeVC = segue.destination as! RouteMapViewController
            
            routeVC.leader = leader
    
            //Member
            if member1 != ""{
                routeVC.member.append(member1)
            }
            
            if member2 != ""{
                routeVC.member.append(member2)
            }
            
            if member3 != ""{
                routeVC.member.append(member3)
            }
            routeVC.originString = originString
            routeVC.destinationString = destinationString
            routeVC.OriginLat = Double(truncating: originLat)
            routeVC.OriginLong = Double(truncating: originLong)
            routeVC.DestinLat = Double(truncating: DestinationLat)
            routeVC.DestinLong = Double(truncating: DestinationLong)
        }
        
        if segue.identifier == "sharer"{
            let shareVC = segue.destination as! SharerViewController
            
            shareVC.leader = leader
            shareVC.curRoom = curRoom
            shareVC.numOfUser = numOfUser.intValue
            shareVC.available = available.intValue
            
            //Member
            if member1 != ""{
                shareVC.member.append(member1)
            }
            
            if member2 != ""{
                shareVC.member.append(member2)
            }
            
            if member3 != ""{
                shareVC.member.append(member3)
            }
            
            shareVC.parentGuest = guestParent
            shareVC.guestName = guestName
            
        }
        
        if segue.identifier == "startTravel"{
            let navVC = segue.destination as? UINavigationController

            let startTravelVC = navVC?.viewControllers.first as! TravelCameraTableViewController
            startTravelVC.curRoom = curRoom
        }
        
        if segue.identifier == "rate"{
            let navVC = segue.destination as? UINavigationController
        
            let rateVC = navVC?.viewControllers.first as! RateSharerViewController
            
            rateVC.curRoom = self.curRoom
            if leader == curUser{
                if member1 != ""{
                   rateVC.sharerID.append(member1)
                   rateVC.sharerName.append(member1Name)
                }
                
                if member2 != ""{
                   rateVC.sharerID.append(member2)
                    rateVC.sharerName.append(member2Name)
                }
                
                if member3 != ""{
                  rateVC.sharerID.append(member3)
                    rateVC.sharerName.append(member3Name)
                }
            
            }else if member1 == curUser{
                if leader != ""{
                    rateVC.sharerID.append(leader)
                    rateVC.sharerName.append(leaderName)
                }
                
                if member2 != ""{
                    rateVC.sharerID.append(member2)
                    rateVC.sharerName.append(member2Name)
                }
                
                if member3 != ""{
                    rateVC.sharerID.append(member3)
                    rateVC.sharerName.append(member3Name)
                }

            }else if member2 == curUser{
                if leader != ""{
                    rateVC.sharerID.append(leader)
                    rateVC.sharerName.append(leaderName)
                }
                
                if member1 != ""{
                    rateVC.sharerID.append(member1)
                    rateVC.sharerName.append(member1Name)
                }
                
                if member3 != ""{
                    rateVC.sharerID.append(member3)
                    rateVC.sharerName.append(member3Name)
                }

            }else if member3 == curUser{
                if leader != ""{
                    rateVC.sharerID.append(leader)
                    rateVC.sharerName.append(leaderName)
                }
                
                if member2 != ""{
                    rateVC.sharerID.append(member2)
                    rateVC.sharerName.append(member2Name)
                }
                
                if member1 != ""{
                    rateVC.sharerID.append(member1)
                    rateVC.sharerName.append(member1Name)
                }
            }
            
        }
    }
    
    @IBAction func addGuest(_ sender: Any){
        
        if self.numOfUser == 4{
            let alert = UIAlertController(title: "Error Adding Guest", message: "Room is full", preferredStyle: .alert)
            let submitAction = UIAlertAction(title: "Dismiss", style: .default) { [unowned alert] _ in
                
            }
            alert.addAction(submitAction)
            self.present(alert, animated: true)
            
        }else if self.available == 0{
            let alert = UIAlertController(title: "Error Adding Guest", message: "Travel has already started", preferredStyle: .alert)
            let submitAction = UIAlertAction(title: "Dismiss", style: .default) { [unowned alert] _ in
                
            }
            alert.addAction(submitAction)
            self.present(alert, animated: true)
            
            
        }else{
            let alert = UIAlertController(title: "Enter Guest Name", message: nil, preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                
            }
            
            let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alert] _ in
                
                let answer = alert.textFields![0].text
                
                if answer == ""{
                    let alert = UIAlertController(title: "Error Adding Guest", message: "Please fill in the name of the guest", preferredStyle: .alert)
                    
                    
                    let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                        
                        DispatchQueue.main.async {
                            self.myRoomTableView.reloadData()
                        }
                        
                    }
                    
                    alert.addAction(dismiss)
                    self.present(alert, animated: true)
                }else{
                    self.ref.child("travel").child(self.curRoom).child("Guests").childByAutoId().setValue(["CompanionId" : self.curUser,"Name" : answer])
                    
                    self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : self.numOfUser.intValue + 1])
                    let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                    
                    
                    let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                        
                        DispatchQueue.main.async {
                            self.myRoomTableView.reloadData()
                        }
                        
                    }
                    
                    alert.addAction(dismiss)
                    self.present(alert, animated: true)
                }
            }
            
            let dismiss =  UIAlertAction(title: "Cancel", style: .default) { (action) -> Void in
                
            }
            alert.addAction(dismiss)
            alert.addAction(submitAction)
            self.present(alert, animated: true)
            
        }
        
        
    }
    
    //Schedule the alarm
    func scheduleLocal(title: String, body: String, category: String, hour: Int, minute: Int){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: category, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: {(error) in
            if let error = error {
                print("SOMETHING WENT WRONG")
            }
        })
    }
    
    func getName(id: String, completion: @escaping (_ fname: String) -> Void) {
        let reference = Database.database().reference().child("users").child(id)
        print(id)
        reference.observeSingleEvent(of: .value) { (snap) in
            
            if let dictionaryWithData = snap.value as? NSDictionary,
                let fname = dictionaryWithData["Fname"]
            {
                
                completion(fname as! String)
            } else {
                completion("error")
            }
        }
    }
    
    func getmessageUsers(id: String) {

        Database.database().reference().child("users").child(id).observeSingleEvent(of: .value) { (snap) in
            if let dictionaryWithData = snap.value as? NSDictionary,
                let fname = dictionaryWithData["Fname"]
            {
                if self.namesDictionary[id] != nil{
                    
                }else{
                    self.namesDictionary.updateValue(fname as! String, forKey: id)
                }
            }
        }
    }
    
}

extension MyRoomViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerFrame = tableView.frame
        
        let myLabel = UILabel()

        myLabel.frame = CGRect(x: 15, y: 20, width: headerFrame.size.width-20, height: 20)
        myLabel.font = UIFont.systemFont(ofSize: 12)
        myLabel.text = self.tableView(myRoomTableView, titleForHeaderInSection: section)
        myLabel.textColor = UIColor.lightGray
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: headerFrame.size.width, height: headerFrame.size.height))
        headerView.addSubview(myLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         if self.available == 0{
            self.sections[0] = "STATUS: TRAVEL ONGOING"
        }else if self.available == 2{
            self.sections[0] = "STATUS: TRAVEL ENDED"
        }
        
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = 0.0 as CGFloat
        
        if section != 0 {
            height = 50.0 as CGFloat
        }
        
        return height
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numRow = 2
        
        if section == 0{
            numRow = 1
        }else if section == 3 && leader != curUser{
            numRow = 1
        }
        
        if section == 3 && self.available == 0{
            numRow = 1
        }
    
        return numRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = self.myRoomTableView.dequeueReusableCell(withIdentifier: "cell") as! ContentMyRoomTableViewCell
        cell.noOfUserLabel.isHidden = true
        
        switch indexPath.section{
        case 0:
            let headerCell = self.myRoomTableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderMyRoomTableViewCell
            
            headerCell.imageDisplay.setRound()
            
            if let url = self.travelURL {
                headerCell.imageDisplay.downloaded(from: url)
                headerCell.isHidden = false
            }else{
                headerCell.isHidden = true
            }
            
            headerCell.isUserInteractionEnabled = false
            
            
            return headerCell
        case 1:
            switch indexPath.row{
            case 0:
                
                cell.contentLabel.text = "Travel Details"
                return cell
            case 1:
                cell.contentLabel.text = "Route"
                return cell
            default:
                break
            }
        case 2:
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "Chat"
    
                return cell
                
            case 1:
                cell.contentLabel.text = "See Sharers"
                cell.noOfUserLabel.isHidden = false
                cell.noOfUserLabel.text = self.numOfUser.stringValue + "/4" 
                return cell
            default:
                break
            }
        case 3:
            switch indexPath.row{
            case 0:
                
                cell.contentLabel.text = "Leave Group"
          
                return cell
            case 1:
                if self.available == 0 || self.available == 2{
                    cell.contentLabel.text = "End Travel"
                
                }else{
                    cell.contentLabel.text = "Start Travel"
             
                }
                
                return cell
            default:
                break
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight:CGFloat = 0.0
        
        if(indexPath.section == 0 && indexPath.row == 0){
            if self.travelURL != nil{
                rowHeight = 200.0
            }else{
                rowHeight = 0.0
            }
        }else{
            rowHeight = 50.0
        }
        
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        switch indexPath.section{
        case 1:
            switch indexPath.row{
            case 0:
                performSegue(withIdentifier: "travelDetails", sender: self)
            case 1:
                 performSegue(withIdentifier: "route", sender: self)
            default:
                break
            }
        case 2:
            switch indexPath.row{
            case 0:
                performSegue(withIdentifier: "chat", sender: self)
            case 1:
                 performSegue(withIdentifier: "sharer", sender: self)
            default:
                break
            }
        case 3:
            switch indexPath.row{
            case 0:
                leaveGroup()
            case 1:
                let date = Date()
           
                let calendar = Calendar.current
                
                let hour = calendar.component(.hour, from: date)
                let minutes = calendar.component(.minute, from: date)
                
                if hour >= self.hour.intValue && minutes >= self.minute.intValue{
                    if self.member1 != "" || self.member2 != "" || self.member3 != ""{
                       startTravel()
                    }else{
                        let alert = UIAlertController(title: "Error Starting Travel", message: "You need atleast 1 member", preferredStyle: .alert)
                        
                        let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                            
                        }
                        
                        alert.addAction(dismiss)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    let alert = UIAlertController(title: "Error Starting Travel", message: "It is still not time for departure", preferredStyle: .alert)
                    

                    let no = UIAlertAction(title: "Dismiss", style: .cancel) { (action) -> Void in
                        
                    }
                    
                    alert.addAction(no)
                    self.present(alert, animated: true, completion: nil)
                }
                
            default:
                break
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func leaveGroup(){
        
        //UPDATE NUMBER OF USERS WHEN LEAVING
        
        if self.available == 0{
            let alert = UIAlertController(title: "Error Leaving Group", message: "You are already traveling", preferredStyle: .alert)
            
            let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
            }
            alert.addAction(dismiss)
            
            
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Leave Group", message: "Are you sure you want to leave the group?", preferredStyle: .alert)
            
  
            let yes = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
                self.navigationItem.rightBarButtonItems?[0].isEnabled = false
                if(self.leader == self.curUser){
                    //Leave Guest and number of guest of a kicked person
                    let countOfLeave = self.kickGuest(member: self.curUser!)
                    
                    self.ref.child("travel").child(self.curRoom).observeSingleEvent(of: .value, with: {(snapshot) in
                        let dataUsers = snapshot.childSnapshot(forPath: "users")
                        let userDict = dataUsers.value as! [String: String?]
                        
                        if dataUsers.hasChild("Member1"){
                            let newLeader = userDict["Member1"] as! String
                            let newNumOfUser = self.numOfUser.intValue - (countOfLeave + 1)
                            
                            print(newNumOfUser)
                            self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : newNumOfUser])
                            
                            //Remove the member that will become the leader
                            self.ref.child("travel").child(self.curRoom).child("users").updateChildValues(["Leader": newLeader])
                            
                            //Change Leader
                            self.ref.child("travel").child(self.curRoom).child("users").child("Member1").removeValue()
                            
                            //Update from full to not full
                            self.fullToNotFull()
                            
                            //Update Current Room to 0
                            self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                            
                            self.leaveRoomSuccess()
                            
                        }else if dataUsers.hasChild("Member2"){
                            let newLeader = userDict["Member2"] as! String
                            let newNumOfUser = self.numOfUser.intValue - (countOfLeave + 1)
                            
                            self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : newNumOfUser])
                            
                            
                            //Remove the member that will become the leader
                            self.ref.child("travel").child(self.curRoom).child("users").updateChildValues(["Leader": newLeader])
                            
                            //Change Leader
                            self.ref.child("travel").child(self.curRoom).child("users").child("Member2").removeValue()
                            
                            //Update from full to not full
                            self.fullToNotFull()
                            
                            //Update Current Room to 0
                            self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                            
                            self.leaveRoomSuccess()
                            
                        }else if dataUsers.hasChild("Member3"){
                            let newLeader = userDict["Member3"] as! String
                            let newNumOfUser = self.numOfUser.intValue - (countOfLeave + 1)
                            
                            self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : newNumOfUser])
                            
                            
                            //Remove the member that will become the leader
                            self.ref.child("travel").child(self.curRoom).child("users").updateChildValues(["Leader": newLeader])
                            
                            //Change Leader
                            self.ref.child("travel").child(self.curRoom).child("users").child("Member3").removeValue()
                            
                            
                            //Update from full to not full
                            self.fullToNotFull()
                            
                            //Update Current Room to 0
                            self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                            
                            self.leaveRoomSuccess()
                        }else{
                            //No member aside from leader
                            self.ref.child("travel").child(self.curRoom).removeValue()
                            
                            //Update Current Room to 0
                            self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                            
                            self.leaveRoomSuccess()
                        }
                    })
                
                }else{
                    
                    //Leave Guest and number of guest of a kicked person
                    let countOfLeave = self.kickGuest(member: self.curUser!)
                    
                    
                    self.ref.child("travel").child(self.curRoom).observeSingleEvent(of: .value, with: {(snapshot) in
                        
                        let dataUsers = snapshot.childSnapshot(forPath: "users")
                        let userDict = dataUsers.value as! [String: String?]
                        
                        //if Member Chosen == Member1/Member2/Member3
                        if dataUsers.hasChild("Member1") && userDict["Member1"] == self.curUser{
                            
                            self.ref.child("travel").child(self.curRoom).child("users").child("Member1").removeValue()
                            
                            let newNumOfUser = self.numOfUser.intValue - (countOfLeave + 1)
                            
                            self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : newNumOfUser])
                            
                            //Update from full to not full
                            self.fullToNotFull()
                            
                            //Update Current Room to 0
                            self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                            
                            self.leaveRoomSuccess()
                        }else if dataUsers.hasChild("Member2") && userDict["Member2"] == self.curUser{
                            self.ref.child("travel").child(self.curRoom).child("users").child("Member2").removeValue()
                            
                            let newNumOfUser = self.numOfUser.intValue - (countOfLeave + 1)
                            
                            self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : newNumOfUser])
                            
                            //Update from full to not full
                            self.fullToNotFull()
                            
                            //Update Current Room to 0
                            self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                            
                            self.leaveRoomSuccess()
                            
                        }else if dataUsers.hasChild("Member3") && userDict["Member3"] == self.curUser{
                            
                            self.ref.child("travel").child(self.curRoom).child("users").child("Member3").removeValue()
                            
                            let newNumOfUser = self.numOfUser.intValue - (countOfLeave + 1)
                            
                            self.ref.child("travel").child(self.curRoom).updateChildValues(["NoOfUsers" : newNumOfUser])
                            
                            //Update from full to not full
                            self.fullToNotFull()
                            
                            //Update Current Room to 0
                            self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "0"])
                            
                            
                            self.leaveRoomSuccess()
                        }
                    })
                }
                
            }
            
            let no = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
                
            }
            
            alert.addAction(no)
            alert.addAction(yes)
            
            self.present(alert, animated: true, completion: nil)
            
           
        }
    }
    
    func startTravel(){
    
        if self.available == 0{
            
            //End Travel then put function above alert with textfield input pin show 3 times
            let alert = UIAlertController(title: "End Travel", message: "Are you sure you want to end traveling?", preferredStyle: .alert)
            
            let yes = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
                self.endTravel()
            }
            
            let no = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
                
            }
            
            alert.addAction(no)
            alert.addAction(yes)
            
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Start Travel", message: "Are you sure you want to start traveling?", preferredStyle: .alert)
            
            let yes = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
                self.performSegue(withIdentifier: "startTravel", sender: self)
            }
            
            let no = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
                
            }
            
            alert.addAction(no)
            alert.addAction(yes)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func endTravel(){
        ref.child("travel").child(curRoom).updateChildValues(["Available" : 2])
        self.myRoomTableView.reloadData()
    }
    
    
    
    //Limit number of text in textfield
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 4
    }

    
//REMOVE ALL VARIABLES THAT ARE ASSIGNED WITH A VALUE WHEN LEAVING THE ROOM
    func reset(){
        ref.removeAllObservers()
        
        self.curRoom = "0"
        self.originString = ""
        self.destinationString = ""
        self.estimatedTravelTime = 0
        self.originLat = 0
        self.originLong = 0
        self.DestinationLat = 0
        self.DestinationLong = 0
        self.available = 0
        self.travelURL = nil
        self.guestParent.removeAll()
        self.guestName.removeAll()
        self.numOfUser = 0
        self.departureTime = ""
        
        //Users
        self.leader = ""
        self.leaderName = ""
        self.member1 = ""
        self.member2 = ""
        self.member3 = ""
        
        //Taxi
        self.taxiOperator = ""
        self.taxiNum = ""
        self.taxiPlate = ""
    }
}

