
//
//  HistoryViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 23/03/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit
import Firebase

class HistoryViewController: UIViewController {

    @IBOutlet weak var historyTableView: UITableView!
   
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    
    
    //Selected Row
    var selectedId = ""
  
    //History
    var historyRoomId : [Any] = []
    var spinner = UIView()
    var userIDs = [String]()

    //Travel Details
    var origin = [String]()
    var destination = [String]()
    var departureTime = [String]()
    var fare = [String]()
    
    override func viewDidLoad() {
        historyTableView.tableFooterView = UIView()
        historyTableView.backgroundColor = UIColor(hex: "#151515")
        super.viewDidLoad()
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if historyRoomId.isEmpty == true{
            historyTableView.isHidden = true
        }else{
            historyTableView.isHidden = false
        }
        
        self.spinner = UIViewController.displaySpinner(onView: self.view)

        let backgroundQueue = DispatchQueue.global(qos: .background)
        
        backgroundQueue.async {
            self.getHistoryRoom()
            DispatchQueue.main.async {
                UIViewController.removeSpinner(spinner: self.spinner)
                self.historyTableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.historyTableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.historyRoomId.removeAll()
        self.origin.removeAll()
        self.destination.removeAll()
        self.departureTime.removeAll()
        self.fare.removeAll()
        
        ref.removeAllObservers()
    }   
    
    func getHistoryRoom(){
        
        ref.child("travel").queryOrdered(byChild: "Available").queryEqual(toValue: 2).observeSingleEvent(of: .value, with: {(snapshot) in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
               
                let dict = snap.value as! [String: Any]
                
                //Check if user is in the room
                let userSnap = snap.childSnapshot(forPath: "users")
                
                for ratingSnap in userSnap.children.allObjects as! [DataSnapshot] {
                    self.userIDs.append(ratingSnap.value as! String)
                    
                    for i in 0 ..< self.userIDs.count{
                        if(self.userIDs[i] == self.curUser){
                            self.historyRoomId.append(snap.key)
                            self.origin.append(dict["OriginString"] as! String)
                            self.destination.append(dict["DestinationString"] as! String)
                            let minFare = dict["MinimumFare"] as! NSNumber
                            let maxFare = dict["MaximumFare"] as! NSNumber
                            
                            
                            let dict = snap.childSnapshot(forPath: "DepartureTime").value as! [String: Any?]
                            
                            let hour = dict["DepartureHour"] as! NSNumber
                                let minute = dict["DepartureMinute"] as! NSNumber
                                let time = hour.stringValue + ":" + minute.stringValue
                                
                                //Convert
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "HH:mm"
                                
                                let date = dateFormatter.date(from: time)
                                dateFormatter.dateFormat = "h:mm a"
                            
                                print(time)
                                self.departureTime.append(dateFormatter.string(from: date!))
                                
                            
                            self.fare.append(minFare.stringValue + "-" + maxFare.stringValue)
                            self.userIDs.removeAll()
                            self.historyTableView.isHidden = false
                        }else{
                            self.userIDs.removeAll()
                        }
                        
                        DispatchQueue.main.async {
                            self.historyTableView.reloadData()
                        }
                    }
                }
            }
        })
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "room"{
            let roomVC = segue.destination as! HistoryRoomViewController
            
            roomVC.roomId = selectedId
        }
    }
    
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return historyRoomId.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "roomCell") as! HistoryTableViewCell
        
        if origin.isEmpty == false && destination.isEmpty == false && fare.isEmpty == false && departureTime.isEmpty == false{
            switch indexPath.row{
            case 0 ..< historyRoomId.count:
                cell.originLabel.text = "Starting Address: " + self.origin[indexPath.row]
                cell.destinationLabel.text = "Destination Address: " +  self.destination[indexPath.row]
                cell.fareLabel.text = "Fare: ₱" + self.fare[indexPath.row]
                cell.timeLabel.text = "Departure Time: " + self.departureTime[indexPath.row]
            default:
                break
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row{
        case 0 ..< historyRoomId.count:
            self.selectedId = historyRoomId[indexPath.row] as! String
            self.performSegue(withIdentifier: "room", sender: self)
        default:
            break
        }
    }
    
}
