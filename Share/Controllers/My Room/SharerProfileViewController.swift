//
//  SharerProfileViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 02/05/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class SharerProfileViewController: UIViewController {

    @IBOutlet weak var ratersTableView: UITableView!
    @IBOutlet weak var profileSharer: UIImageView!
    @IBOutlet weak var starsView: CosmosView!
    @IBOutlet weak var nameLabel: UILabel!

    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    
    var id = ""
    var imageUrl: URL!
    
    var profileImage = UIImage()
    
    //Data of sharer
    var rating = [Double]()
    var userRatingID = [String]()
    var userRatingName = [String]()
    var comment = [String]()
    var memberShare = [String]()
    var totalrating = [Double]()
    
    override func viewDidLoad() {
        starsView.isHidden = true
        starsView.isUserInteractionEnabled = false
        profileSharer.setRound()
        query()
        super.viewDidLoad()
        ratersTableView.delegate = self
        ratersTableView.dataSource = self
        ratersTableView.tableFooterView = UIView()
        ratersTableView.backgroundColor = UIColor(hex: "#151515")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        totalStars()
    }
    
 
    func query() {
        
        ref.child("users").child(id).observeSingleEvent(of: .value, with: {(snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            //Get User
            let fname  = value?["Fname"] as! String
            let lname = value?["Lname"] as! String
            
            self.nameLabel.text = fname + " " + lname
            
            let storageRef = Storage.storage().reference().child("profile/"+self.id+".jpg")
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print(error)
                } else {
                    self.profileSharer.downloaded(from: url!)
                }
            }
            
            DispatchQueue.main.async {
                self.ratersTableView.reloadData()
            }
                
            
            if snapshot.hasChild("Rating"){
                
                for child in snapshot.childSnapshot(forPath: "Rating").children{
                    
                    self.starsView.isHidden = false
                    let child = child as! DataSnapshot
                    let dict = child.value! as! [String:Any]
                    
                    self.userRatingID.append(dict["User"] as! String)
                    
                    self.getName(id: dict["User"] as! String, completion: { completename in
                        
                        let rating = dict["Rating"] as! NSNumber
                        self.rating.append(rating.doubleValue)
                        
                        if child.hasChild("Comment"){
                            let comment = dict["Comment"] as! String
                            self.comment.append(comment)
                        }else{
                            self.comment.append(" ")
                        }
                        
                        DispatchQueue.main.async {
                            self.ratersTableView.reloadData()
                        }
                   
                        
                    })
                    
                    DispatchQueue.main.async {
                        self.ratersTableView.reloadData()
                    }
                
                }
    
            }else{
                self.starsView.isHidden = true
                self.ratersTableView.isHidden = true
                DispatchQueue.main.async {
                    self.ratersTableView.reloadData()
                }
            }
            
            
        })
        
        
    }
    
    func totalStars(){
        ref.child("users").child(id).observeSingleEvent(of: .value, with: {(snapshot) in
            
            
            if snapshot.hasChild("Rating"){
                
                for child in snapshot.childSnapshot(forPath: "Rating").children{
                    
                    self.ratersTableView.isHidden = false
                    let child = child as! DataSnapshot
                    let dict = child.value! as! [String:Any]
                
                    let rating = dict["Rating"] as! NSNumber
                    self.totalrating.append(rating.doubleValue)
                    
                    DispatchQueue.main.async {
                        self.ratersTableView.reloadData()
                    }
                }
                
            }

            
            if self.totalrating.isEmpty == false{
                let sumArray = self.totalrating.reduce(0, +)
                
                self.starsView.rating = Double(sumArray) / Double(self.totalrating.count)
                
                print(sumArray)
            }

        })
    }
    
    func getName(id: String, completion: @escaping (_ completename: String) -> Void) {
        let reference = Database.database().reference().child("users").child(id)
        reference.observeSingleEvent(of: .value) { (snap) in
            
            if let dictionaryWithData = snap.value as? NSDictionary,
                let fname = dictionaryWithData["Fname"],
                let lname = dictionaryWithData["Lname"]
            {
                
                let fname = fname as! String
                let lname = lname as! String
                let completename = fname + " " + lname
                self.memberShare.append(id)
                self.userRatingName.append(completename)
                completion(completename)
            } else {
                completion("error")
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ref.removeAllObservers()
    
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

extension SharerProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userRatingID.isEmpty == true{
            return 0
        }else{
            return userRatingID.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 140.0
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ratersTableView.dequeueReusableCell(withIdentifier: "cell") as! RatingTableViewCell
        let commentCell = ratersTableView.dequeueReusableCell(withIdentifier: "commentCell") as! RatingTableViewCell
        
        cell.selectionStyle = .none
        commentCell.selectionStyle = .none
        
        commentCell.reviewStar.isUserInteractionEnabled = false
        
        if self.rating.isEmpty == true{
            self.ratersTableView.isHidden = true
        }else{
            self.ratersTableView.isHidden = false
            print(userRatingID.count, memberShare.count)
            if userRatingID.count == memberShare.count && comment.isEmpty == false{
                self.downloadImage(id: self.memberShare[indexPath.row], completion: { url in
                    commentCell.profileImage.image = nil
                    commentCell.profileImage.downloaded(from: url)
                    commentCell.profileImage.setRound()
                })
                print(self.memberShare[indexPath.row], self.comment[indexPath.row])
                commentCell.nameLabel.text = userRatingName[indexPath.row]
                commentCell.reviewStar.rating = Double(exactly: rating[indexPath.row])!
                commentCell.reviewStar.isUserInteractionEnabled = false
                if comment[indexPath.row] != " "{
                    commentCell.commentText.text = "Comment:" + " " + comment[indexPath.row]
                    commentCell.commentText.isUserInteractionEnabled = false
                }else{
                    commentCell.commentText.isHidden = true
                }
                
                
                return commentCell
            }
            
        }
        
        
        return cell
    }
}
