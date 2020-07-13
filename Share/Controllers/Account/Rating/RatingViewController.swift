//
//  RatingViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 19/10/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class RatingViewController: UIViewController {
    
    @IBOutlet weak var ratingTableView: UITableView!
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    

    //Data of sharer
    var rating = [Double]()
    var userRatingID = [String]()
    var userRatingName = [String]()
    var comment = [String]()
    var memberShare = [String]()
    
    var spinner = UIView()
    
    override func viewDidLoad() {
        self.query()
        super.viewDidLoad()
        ratingTableView.tableFooterView = UIView()
        ratingTableView.backgroundColor = UIColor(hex: "#151515")
        ratingTableView.delegate = self
        ratingTableView.dataSource = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ref.removeAllObservers()
    }
    
    
    func query() {
        ref.child("users").child(curUser!).observeSingleEvent(of: .value, with: {(snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            if snapshot.hasChild("Rating"){
                
                for child in snapshot.childSnapshot(forPath: "Rating").children{
                    
                    self.ratingTableView.isHidden = false
                    let child = child as! DataSnapshot
                    let dict = child.value! as! [String:Any]
                    
                    self.userRatingID.append(dict["User"] as! String)
                    
                    
                    let rating = dict["Rating"] as! NSNumber
                    self.rating.append(rating.doubleValue)
                    
                    
                    if child.hasChild("Comment"){
                        let comment = dict["Comment"] as! String
                        self.comment.append(comment)
                    }else{
                        self.comment.append(" ")
                    }
                    
                    DispatchQueue.main.async {
                        self.ratingTableView.reloadData()
                    }
                    
                }
                
            }else{
                self.ratingTableView.isHidden = true
                DispatchQueue.main.async {
                    self.ratingTableView.reloadData()
                }
            }
        
            
            if self.userRatingID.isEmpty == false{
                self.ratingTableView.isHidden = false
                
                //Get Data image
                for i in 0 ..< self.userRatingID.count{
                    
                    self.getName(id:self.userRatingID[i], completion: { completename in
                        
                        DispatchQueue.main.async {
                            self.ratingTableView.reloadData()
                        }
                        
                    })
                }
                
                
                
            }else{
                self.ratingTableView.isHidden = true
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

extension RatingViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRatingID.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commentCell = ratingTableView.dequeueReusableCell(withIdentifier: "commentCell") as! RatingTableViewCell
    
        commentCell.selectionStyle = .none
        
        commentCell.reviewStar.isUserInteractionEnabled = false
        
        if self.rating.isEmpty == true{
            self.ratingTableView.isHidden = true
        }else{
            self.ratingTableView.isHidden = false
            if userRatingID.count == memberShare.count && comment.isEmpty == false{
                self.downloadImage(id: self.memberShare[indexPath.row], completion: { url in
                    commentCell.profileImage.image = nil
                    commentCell.profileImage.downloaded(from: url)
                    commentCell.profileImage.setRound()
                })
                commentCell.nameLabel.text = userRatingName[indexPath.row]
                commentCell.reviewStar.rating = Double(exactly: rating[indexPath.row])!
                commentCell.reviewStar.isUserInteractionEnabled = false
                if comment[indexPath.row] != " "{
                    commentCell.commentText.text = "Comment:" + " " + comment[indexPath.row]
                    commentCell.commentText.isUserInteractionEnabled = false
                }else{
                    commentCell.commentText.isHidden = true
                }
            }
            
        }
        return commentCell
    }
}
