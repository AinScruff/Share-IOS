//
//  HistoryRateViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 26/05/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class HistoryRateViewController: UIViewController{
    
  
    @IBOutlet weak var rateTableView: UITableView!
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    
    var curRoom = ""
    
    var sharerID = [String]()
    var sharerName = [String]()
    
    var comment = [String]()
    var ratingStorage = [Double]()
    
    override func viewDidLoad() {
        rateTableView.tableFooterView = UIView()
        rateTableView.backgroundColor = UIColor(hex: "#151515")
        rateTableView.delegate = self
        rateTableView.dataSource = self
        super.viewDidLoad()
        
        ratingStorage = [Double](repeating: 0, count: self.sharerID.count)
        
        //Dismiss Keyboard
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
        
    }
    
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sharerID.removeAll()
        self.sharerName.removeAll()
    }
    
    @IBAction func rateDone(_ sender: Any) {
        let alert = UIAlertController(title: "Rating Done", message: "Are you sure that you are done rating?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
            
            for indexSection in 0 ..< self.sharerID.count{
                let index = IndexPath(row: 1, section: indexSection)
                let commentcell = self.rateTableView.cellForRow(at: index) as! RateSharerTableViewCell
                
                //if comment not empty insert comment
                if commentcell.commentText.text.count > 0{
                    
                    //If star is 0 dont put value in comment
                    if self.ratingStorage[indexSection] != 0.0{
                        self.ref.child("users").child(self.sharerID[indexSection]).child("Rating").childByAutoId().setValue(["Comment": commentcell.commentText.text!, "Rating" : self.ratingStorage[indexSection], "User" : self.curUser!])
                        print(self.sharerID[indexSection])
                    self.ref.child("travel").child(self.curRoom).child("rated").child(self.sharerID[indexSection]).childByAutoId().setValue(["UserId" : self.curUser])
                        
                        
                        let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                        
                        let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                             _ = self.navigationController?.popViewController(animated: true)
                        }
                        
                        alert.addAction(dismiss)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                        
                        let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                             _ = self.navigationController?.popViewController(animated: true)
                        }
                        
                        alert.addAction(dismiss)
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    
                    //If star is 0 dont put value in comment
                    if self.ratingStorage[indexSection] != 0.0{
                        self.ref.child("users").child(self.sharerID[indexSection]).child("Rating").childByAutoId().setValue(["Rating" : self.ratingStorage[indexSection], "User" : self.curUser!])
                        self.ref.child("travel").child(self.curRoom).child("rated").child(self.sharerID[indexSection]).childByAutoId().setValue(["UserId" : self.curUser])
                        
                        let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                        
                        let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                             _ = self.navigationController?.popViewController(animated: true)
                        }
                        
                        alert.addAction(dismiss)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                        
                        let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                             _ = self.navigationController?.popViewController(animated: true)
                        }
                        
                        alert.addAction(dismiss)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                
            }
            
        }
        
        let no = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
        }
        
        alert.addAction(no)
        alert.addAction(yes)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension HistoryRateViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1{
            return 125.0
        }else{
            return 65.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rateCell =  rateTableView.dequeueReusableCell(withIdentifier: "rateCell") as! RateSharerTableViewCell
        let commentCell = rateTableView.dequeueReusableCell(withIdentifier: "commentCell") as! RateSharerTableViewCell
        
        
        switch indexPath.section{
        case 0 ..< sharerID.count:
            switch indexPath.row{
            case 0:
                // Get the rating for the star
                let rating = ratingStorage[indexPath.row]
                // Update star's rating
                rateCell.update(rating)
                // Store the star's rating when user lifts her finger
                rateCell.starView.didFinishTouchingCosmos = { [weak self] rating in
                    self?.ratingStorage[indexPath.section] = rating
                }
                return rateCell
            case 1:
                return commentCell
            default:
                break
            }
        default:
            break
        }
        
        return commentCell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sharerID.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerFrame = tableView.frame
        
        let myLabel = UILabel()
        
        myLabel.frame = CGRect(x: 15, y: 20, width: headerFrame.size.width-20, height: 20)
        myLabel.font = UIFont.systemFont(ofSize: 12)
        myLabel.text = self.tableView(rateTableView, titleForHeaderInSection: section)
        myLabel.textColor = UIColor.lightGray
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: headerFrame.size.width, height: headerFrame.size.height))
        headerView.addSubview(myLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sharerName[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
}

