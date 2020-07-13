//
//  HistoryRoomViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 03/05/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit
import Firebase

class HistoryRoomViewController: UIViewController {
    
    @IBOutlet weak var myRoomTableView: UITableView!
    
    //Section
    var sections = ["", "TRAVEL", "PREFERENCES"]
    
    var roomId = ""
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    
    //User Details
    var pin = NSNumber()
    var fname = ""
    var fullName = ""
    var guardianContact = ""
    
    
    //Travel Details
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
    var departureTime = ""
    
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
    var memberNames = [String]()
    
    var guestParent = [String]()
    var guestName = [String]()
    
    override func viewDidLoad() {
        myRoomTableView.tableFooterView = UIView()
        myRoomTableView.backgroundColor = UIColor(hex: "#151515")

        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMyRoom()
    }
    override func viewDidDisappear(_ animated: Bool) {
        reset()
        ref.removeAllObservers()
    }
    
    func getMyRoom(){
        
        self.ref.child("travel").child(self.roomId).observeSingleEvent(of: .value, with: {(snapshot) in
                    
            let roomValue = snapshot.value as? NSDictionary
            
            self.originString = roomValue?["OriginString"] as! String
            self.destinationString = roomValue?["DestinationString"] as! String
            self.estimatedTravelTime = roomValue?["EstimatedTravelTime"] as! NSNumber
                    
                    
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
            
            let hour = dict["DepartureHour"] as! NSNumber
            let minute = dict["DepartureMinute"] as! NSNumber
            let time = hour.stringValue + ":" + minute.stringValue
            
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
                    
                //Get Users
                let dataUsers = snapshot.childSnapshot(forPath: "users")
                let userDict = dataUsers.value as! [String: String?]
       
                self.leader = userDict["Leader"] as! String
                    
                self.ref.child("users").child(self.leader).observeSingleEvent(of: .value, with: {(snapshot) in
                            let value = snapshot.value as? NSDictionary
                            let memNname = value?["Fname"] as! String
                            let memLname = value?["Lname"] as! String
                            
                            
                            self.memberNames.append(memNname + " " + memLname)
                })
            
                    
                    
            if dataUsers.hasChild("Member1"){
                    self.member1 = userDict["Member1"] as! String
                        
                    self.ref.child("users").child(self.member1).observeSingleEvent(of: .value, with: {(snapshot) in
                                let value = snapshot.value as? NSDictionary
                                let memNname = value?["Fname"] as! String
                                let memLname = value?["Lname"] as! String
                                
                                
                                self.memberNames.append(memNname + " " + memLname)
                    })
                        
                }
            
                if dataUsers.hasChild("Member2"){
                    print("true")
                    self.member2 = userDict["Member2"] as! String
                    
                    self.ref.child("users").child(self.member2).observeSingleEvent(of: .value, with: {(snapshot) in
                                let value = snapshot.value as? NSDictionary
                                let memNname = value?["Fname"] as! String
                                let memLname = value?["Lname"] as! String
                        
                                self.memberNames.append(memNname + " " + memLname)
                    })
                 }
            
            
                if dataUsers.hasChild("Member3"){
                    print("true")
                    self.member3 = userDict["Member3"] as! String
                        
                    self.ref.child("users").child(self.member3).observeSingleEvent(of: .value, with: {(snapshot) in
                                let value = snapshot.value as? NSDictionary
                                let memNname = value?["Fname"] as! String
                                let memLname = value?["Lname"] as! String
                                self.memberNames.append(memNname + " " + memLname)
                    })
                    
                        
                }
                    
                    //Get Guest
                    
                    for child in snapshot.childSnapshot(forPath: "Guests").children{
                        
                        let child = child as! DataSnapshot
                        let dict = child.value! as! [String:Any]
                        
                        self.guestParent.append(dict["CompanionId"] as! String)
                        self.guestName.append(dict["Name"] as! String)
                        
                        
                    }
            
                    //self.myRoomTableView.reloadData()
                })
                
                //Check image
                let storageRef = Storage.storage().reference().child("travel/"+self.roomId+".jpg")
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print(error)
                    } else {
                        self.travelURL = url!
                        DispatchQueue.main.async{
                            self.myRoomTableView.reloadData()
                        }
                    }
                }
        DispatchQueue.main.async{
            self.myRoomTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "travelDetails"{
            let travelDVC = segue.destination as! TravelDetailsViewController
            
            travelDVC.Orig = originString
            travelDVC.Destin = destinationString
            travelDVC.minFare = minFare.stringValue
            travelDVC.maxFare = maxFare.stringValue
            travelDVC.taxiOperator = taxiOperator
            travelDVC.taxiPlateNum = taxiPlate
            travelDVC.taxiNum = taxiNum
            travelDVC.estimatedTime = estimatedTravelTime.stringValue
            travelDVC.departureTime = departureTime
        }
        
        if segue.identifier == "route"{
            let routeVC = segue.destination as! HistoryRouteViewController
            
            routeVC.originString = originString
            routeVC.destinationString = destinationString
            routeVC.OriginLat = Double(truncating: originLat)
            routeVC.OriginLong = Double(truncating: originLong)
            routeVC.DestinLat = Double(truncating: DestinationLat)
            routeVC.DestinLong = Double(truncating: DestinationLong)
        }
        
        if segue.identifier == "sharer"{
            let shareVC = segue.destination as! HistorySharerViewController
            
            shareVC.leader = leader
            shareVC.roomId = roomId
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
    }
}

extension HistoryRoomViewController: UITableViewDelegate, UITableViewDataSource
{
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
        if section == 2 || section == 0{
            return 1
        }else{
            return 2
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.myRoomTableView.dequeueReusableCell(withIdentifier: "cell") as! ContentMyRoomTableViewCell
        
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
                cell.contentLabel.text = "See Sharers"
                
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
            rowHeight = 200.0
            
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
                performSegue(withIdentifier: "sharer", sender: self)
            default:
                break
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //REMOVE ALL VARIABLES THAT ARE ASSIGNED WITH A VALUE WHEN LEAVING THE ROOM
    func reset(){
        
        self.originString = ""
        self.destinationString = ""
        self.estimatedTravelTime = 0
        self.originLat = 0
        self.originLong = 0
        self.DestinationLat = 0
        self.DestinationLong = 0
        self.travelURL = nil
        self.memberNames.removeAll()
        self.guestParent.removeAll()
        self.guestName.removeAll()
        
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
