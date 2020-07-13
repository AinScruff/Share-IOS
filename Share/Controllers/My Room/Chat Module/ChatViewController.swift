//
//  ChatViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 26/10/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    
    var roomid = ""
    var displayName = ""
    var name = ""
    
    
    var namesDictionary = [String : String]()
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    
    override func viewDidLoad() {
        
        
        senderId = curUser
        senderDisplayName = displayName
        
        
        super.viewDidLoad()
        
        inputToolbar.contentView.leftBarButtonItem = nil
        
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        
        _ = self.ref.child("travel").child(self.roomid).child("messages").queryLimited(toLast: 15).observe(.childAdded, with: { snapshot in
            
            if  let data        = snapshot.value as? [String: String],
                let userId      = data["MessageUser"],
                let text        = data["MessageText"]
            {
                if self.namesDictionary[userId] != nil{
                    
                    if let message = JSQMessage(senderId: userId, displayName: self.namesDictionary[userId], text: text)
                    {
                        self.messages.append(message)
                        self.finishReceivingMessage()
                    }
                }
                
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.ref.removeAllObservers()
        self.ref.child("travel").child(roomid).child("messages").observeSingleEvent(of: .value, with: { (snapshot) in
            self.ref.child("users").child(self.curUser!).updateChildValues(["count_read": snapshot.childrenCount])
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!{
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        // messages to show
        let msg = messages[indexPath.row]
        
        if !msg.isMediaMessage {
            if msg.senderId! == senderId {
                cell.textView.textColor = UIColor.white
            }else{
                cell.textView.textColor = UIColor.black
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!{
        
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!{
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!{
        
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat{
        
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!){
        
        
        let ref = Database.database().reference().child("travel").child(roomid).child("messages").childByAutoId()
        
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm:ss a"
        let time = timeFormatter.string(from: Date())
        
        let message = ["MessageUser": senderId, "MessageText": text, "Date": dateString, "Time": time]
        
        ref.setValue(message)
        
        finishSendingMessage()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion:  nil)
    }
    
    
    //Get First Name of Sender
    func getName(id: String) {
        print("id:", id)
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
