//
//  ResultsRoomTableViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 09/02/2019.
//  Copyright © 2019 Caryl Rabanos. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class ResultsRoomTableViewController: UIViewController {
    
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    
    var Userid = ""
    var Destination = ""
    var Origin = ""
    var Destlat = 0.0
    var DestLong = 0.0
    var OriginLat = 0.0
    var Originlong = 0.0
    
    //Time
    var Hour = 0
    var Minute = 0
    
    //Results
    var dest = [String]()
    var orig = [String]()
    var numOfUser = [Int]()
    var MinFare = [Int]()
    var MaxFare = [Int]()
    var hours = [Int]()
    var minutes = [Int]()
    var roomId = [String]()
    var Dest = ""
    var Ori = ""
    var forDestlat = ""
    var forDestlong = ""
    var forOriglat = ""
    var forOriglong = ""
    var timepicked = 0
    var members = 0
    
    @IBOutlet weak var NoRoom: UILabel!
    
    
    //Create Room
    var minFare = 0
    var maxFare = 0
    var estimatedTravelTime = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        resultsTableView.tableFooterView = UIView()
        resultsTableView.backgroundColor = UIColor(hex: "#151515")
        
        //Lat Long first 2 digits only
        let numberFormat = NumberFormatter()
        numberFormat.maximumFractionDigits = 2
        forDestlat = numberFormat.string(for: Destlat)!
        forDestlong = numberFormat.string(for: DestLong)!
        forOriglat = numberFormat.string(for: OriginLat)!
        forOriglong = numberFormat.string(for: Originlong)!
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        let backgroundQueue = DispatchQueue.global(qos: .background)
        
        backgroundQueue.async {
            self.getRooms()
            DispatchQueue.main.async {
                self.resultsTableView.reloadData()
            }
        }
        
    }
    
    
    
    
    
    func getRooms(){
        let numberFormat = NumberFormatter()
        numberFormat.maximumFractionDigits = 2
        ref.child("travel").queryOrdered(byChild: "Available").queryEqual(toValue: 1).observe( .value, with: {(snapshot) in
            self.dest.removeAll()
            self.orig.removeAll()
            self.numOfUser.removeAll()
            self.roomId.removeAll()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let roomid = snap.key
                let dict = snap.value as! [String: Any]
                let destination = dict["DestinationString"] as! String
                let origin = dict["OriginString"] as! String
                let minimumFare = dict["MinimumFare"] as! Int
                let maximumFare = dict["MaximumFare"] as! Int
                let num = dict["NoOfUsers"] as! Int
                if num + self.members <= 4 {
                    self.ref.child("travel").child(roomid).child("Destination").observeSingleEvent(of: .value, with: {(snapshot) in
                        let val = snapshot.value as! [String: Any]
                        let DestCoordinateLat = val["latitude"] as? Double
                        let DestCoordinateLong = val["longitude"] as? Double
                        let DestCLat = numberFormat.string(for: DestCoordinateLat)
                        let DestCLong = numberFormat.string(for: DestCoordinateLong)
                        
                        
                        if DestCLat == self.forDestlat && DestCLong == self.forDestlong{
                            self.ref.child("travel").child(roomid).child("Origin").observeSingleEvent(of: .value, with: {(snapshot) in
                                let val = snapshot.value as! [String: Any]
                                let OriginCoordinateLat = val["latitude"] as? Double
                                let OriginCoordinateLong = val["longitude"] as? Double
                                let OrigCLat = numberFormat.string(for: OriginCoordinateLat)
                                let OrigCLong = numberFormat.string(for: OriginCoordinateLong)
                                if OrigCLat == self.forOriglat && OrigCLong == self.forOriglong {
                                    self.ref.child("travel").child(roomid).child("DepartureTime").observeSingleEvent(of: .value, with: {(TimeSnap) in
                                        let Timeval = TimeSnap.value as! NSDictionary
                                        let TravHour = Timeval["DepartureHour"] as! Int
                                        let TravMinute = Timeval["DepartureMinute"] as! Int
                                        if self.timepicked == 1 {
                                            if self.Hour == TravHour {
                                                if self.Minute >= TravMinute - 5 && self.Minute <= TravMinute + 5 {
                                                    self.dest.append(destination)
                                                    self.orig.append(origin)
                                                    self.numOfUser.append(num)
                                                    self.minutes.append(TravMinute)
                                                    self.hours.append(TravHour)
                                                    self.MinFare.append(minimumFare)
                                                    self.MaxFare.append(maximumFare)
                                                    self.roomId.append(roomid)
                                                    DispatchQueue.main.async {
                                                        self.resultsTableView.reloadData()
                                                    }
                                                }
                                            }
                                        } else {
                                            self.dest.append(destination)
                                            self.orig.append(origin)
                                            self.numOfUser.append(num)
                                            self.minutes.append(TravMinute)
                                            self.hours.append(TravHour)
                                            self.MinFare.append(minimumFare)
                                            self.MaxFare.append(maximumFare)
                                            self.roomId.append(roomid)
                                            DispatchQueue.main.async {
                                                self.resultsTableView.reloadData()
                                            }
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            }
        })
    }
    
    
    //Schedule the alarm
    func scheduleLocal(title: String, body: String, category: String, hour: Int, minute: Int){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = category
        content.sound = UNNotificationSound.default
        
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: {(error) in
            if let error = error {
                print("SOMETHING WENT WRONG")
            }
        })
    }
    
    @IBAction func CreateRoom(_ sender: Any) {
        let alert = UIAlertController(title: "Create Room", message: "Are you sure you want to create room?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
            
            //Check if there is time or not
            if self.timepicked == 1{
                let newroom = self.ref.child("travel").childByAutoId()
                let roomid = newroom.key
                
                newroom.setValue(["Available" : 1, "DestinationString" : self.Destination,"EstimatedTravelTime" : self.estimatedTravelTime,"MaximumFare" : self.maxFare, "MinimumFare" : self.minFare, "NoOfUsers": self.members,"OriginString" : self.Origin])
                self.ref.child("travel").child(roomid!).child("Destination").setValue(["latitude" : self.Destlat,"longitude" : self.DestLong])
                self.ref.child("travel").child(roomid!).child("Origin").setValue(["latitude" : self.OriginLat, "longitude" : self.Originlong])
                self.ref.child("travel").child(roomid!).child("DepartureTime").setValue(["DepartureHour" : self.Hour,"DepartureMinute" : self.Minute])
                self.ref.child("travel").child(roomid!).child("users").setValue(["Leader" : self.curUser])
                
                self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : roomid])
                
                
                
                let alert = UIAlertController(title: "Success", message: "Please proceed to My Room", preferredStyle: .alert)
                
                let dismiss = UIAlertAction(title: "Dismiss", style: .cancel) { (action) -> Void in
                    self.dismiss(animated: true, completion: nil)
                }
                
                alert.addAction(dismiss)
                
                self.present(alert, animated: true, completion: nil)
                
                
            }else{
                self.performSegue(withIdentifier: "inputTime", sender: self)
            }
            
        }
        let no = UIAlertAction(title: "No", style: .default) { (action) -> Void in
            
        }
        
        alert.addAction(no)
        alert.addAction(yes)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.ref.removeAllObservers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        if segue.identifier == "travelStart" {
        //
        //            let MapVC = segue.destination as! RouteMapViewController
        //            MapVC.OriginLong = OriginLong
        //            MapVC.OriginLat = OriginLat
        //            MapVC.DestinLat = DestinationLat
        //            MapVC.DestinLong = DestinationLong
        //            MapVC.mode = 1
        //        }
        if segue.identifier == "inputTime" {
            
            let TimePickVC = segue.destination as! EnterTimeViewController
            TimePickVC.DestLat = Destlat
            TimePickVC.DestLong = DestLong
            TimePickVC.Dest = Destination
            TimePickVC.OriginLong = Originlong
            TimePickVC.OriginLat = OriginLat
            TimePickVC.Orig = Origin
            TimePickVC.minFare = minFare
            TimePickVC.maxFare = maxFare
            TimePickVC.Traveltime = estimatedTravelTime
        }
    }
    
}


extension ResultsRoomTableViewController: UITableViewDataSource, UITableViewDelegate{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(dest.count)
        if dest.isEmpty == true{
            self.NoRoom.isHidden = false
        }else{
            self.NoRoom.isHidden = true
        }
        return dest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchRoomTableViewCell
        
        print("cellllls")
        print(orig[indexPath.row])
        cell.startLabel.text = "Start Location: " + orig[indexPath.row]
        cell.destLabel.text = "Destination: " + dest[indexPath.row]
        cell.numOfUserLabel.text = String(numOfUser[indexPath.row])+"/4"
        cell.FareLabel.text = "Fare: ₱" + String(MinFare[indexPath.row]) + "-" + String(MaxFare[indexPath.row])
        if hours[indexPath.row] > 12 {
            cell.departureTime.text = "Departure Time: " + String(hours[indexPath.row] - 12) + ":" + String(minutes[indexPath.row])
        } else {
            cell.departureTime.text = "Departure Time: " + String(hours[indexPath.row]) + ":" + String(minutes[indexPath.row])
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let Roomid = roomId[indexPath.row]
        
        
        //Alert
        let alert = UIAlertController(title: "Join Group", message: "Are you sure you want to join the group?", preferredStyle: .alert)
        
        
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
//            self.ref.child("travel").child(Roomid).child("users").observeSingleEvent(of: .value, with: {(snapshot) in
//
//
//                let member1 = snapshot.hasChild("Member1")
//                let member2 = snapshot.hasChild("Member2")
//
//                if member1 != true {
//                    self.ref.child("travel").child(Roomid).child("users").updateChildValues(["Member1" : self.Userid])
//
//                }else if member2 != true{
//                    self.ref.child("travel").child(Roomid).child("users").updateChildValues(["Member2" : self.Userid])
//                }else{
//
//                    self.ref.child("travel").child(Roomid).child("users").updateChildValues(["Member3" : self.Userid])
//                }
//
//                self.ref.child("users").child(self.Userid).updateChildValues(["CurRoom" : Roomid])
//
//
//                self.ref.child("travel").child(Roomid).updateChildValues(["NoOfUsers": self.numOfUser[indexPath.row] + 1])
//
//                self.ref.child("travel").child(Roomid).observeSingleEvent(of: .value, with: {(snapshot) in
//                    let value = snapshot.value as? NSDictionary
//                    let numUsers = value?["NoOfUsers"] as! NSNumber
//
//                    if numUsers == 4{
//                        self.ref.child("travel").child(Roomid).updateChildValues(["Available": 3])
//                    }
//
//                    //Schedule Time
//
//                    let dict = snapshot.childSnapshot(forPath: "DepartureTime").value as! [String: Any?]
//
//                    let hour = dict["DepartureHour"] as! NSNumber
//                    let minute = dict["DepartureMinute"] as! NSNumber
//                })
//
//
//
//            })
            self.ref.child("travel").child(Roomid).child("pendingusers").childByAutoId().setValue(["UserId" : self.Userid])
            self.ref.child("users").child(self.curUser!).updateChildValues(["CurRoom" : "Requesting"])
            
            let alert = UIAlertController(title: "Success", message: "Please proceed to My Room", preferredStyle: .alert)
            
            let dismiss = UIAlertAction(title: "Dismiss", style: .cancel) { (action) -> Void in
                self.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(dismiss)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let no = UIAlertAction(title: "No", style: .default) { (action) -> Void in
            
        }
        
        alert.addAction(no)
        alert.addAction(yes)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func minus(_ lhs: DateComponents, _ rhs: DateComponents) -> DateComponents {
        return combineComponents(lhs, rhs, multiplier: -1)
    }
    
    func combineComponents(_ lhs: DateComponents,
                           _ rhs: DateComponents,
                           multiplier: Int = 1)
        -> DateComponents {
            var result = DateComponents()
            result.second     = (lhs.second     ?? 0) + (rhs.second     ?? 0) * multiplier
            result.minute     = (lhs.minute     ?? 0) + (rhs.minute     ?? 0) * multiplier
            result.hour       = (lhs.hour       ?? 0) + (rhs.hour       ?? 0) * multiplier
            result.day        = (lhs.day        ?? 0) + (rhs.day        ?? 0) * multiplier
            result.weekOfYear = (lhs.weekOfYear ?? 0) + (rhs.weekOfYear ?? 0) * multiplier
            result.month      = (lhs.month      ?? 0) + (rhs.month      ?? 0) * multiplier
            result.year       = (lhs.year       ?? 0) + (rhs.year       ?? 0) * multiplier
            return result
    }
    
    
}
