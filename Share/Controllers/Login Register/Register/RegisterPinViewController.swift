//
//  RegisterPinViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 04/05/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit
import Firebase

class RegisterPinViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    //User
    var profileImage = UIImage()
    var fname = ""
    var lname = ""
    var contactNumber = ""
    var econtactNumber = ""
    var gender = ""
    var email = ""
    var password = ""
    
    
    override func viewDidLoad() {
        
        //CHANGE COLOR OF PLACEHOLDER
        pinTextField.attributedPlaceholder = NSAttributedString(string: "Pin",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        confirmTextField.attributedPlaceholder = NSAttributedString(string: "Confirm Pin",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        pinTextField.delegate = self
        confirmTextField.delegate = self
        //Dismiss Keyboard
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
        
        super.viewDidLoad()
        
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    }
  

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func register(_ sender: Any) {
        let pin = pinTextField.text
        let confirmPin = confirmTextField.text
        
        if pin!.count == 0{
            self.createAlert(title: "Pin Error",message: "Pin is required")
        }else if pin!.count < 4{
             self.createAlert(title: "Pin Error",message: "Pin must be 4 characters")
        }else if confirmPin!.count < 4{
            self.createAlert(title: "Pin Error",message: "Pin must be 4 characters")
        }else if pin != confirmPin{
            self.createAlert(title: "Pin Error",message: "Pin does not match")
        }else{
           
            let sv = UIViewController.displaySpinner(onView: self.view)
            
            Auth.auth().createUser(withEmail: email, password: password, completion: {(user,error) in
                if error != nil{
                    self.createAlert(title: "Email already in use", message: error?.localizedDescription as Any as! String)
                    UIViewController.removeSpinner(spinner: sv)
                        return
            }
                
            let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
            
            let values = ["Fname": self.fname, "Lname": self.lname, "Gender": self.gender, "ContactNumber": self.contactNumber, "EmergencyContact": self.econtactNumber, "CurRoom": "0","Pin": Int(pin!)!] as [String : Any]
            
            let uid = Auth.auth().currentUser?.uid
            
            self.uploadImage(self.profileImage) { url in
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.photoURL = url
            }

            Auth.auth().currentUser?.sendEmailVerification(completion: {(error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                        return
                }
                
                ref.child("users").child(uid!).setValue(values, withCompletionBlock: {(err,ref) in
                    if err != nil{
                        print(err?.localizedDescription as Any)
                        return
                    }
                ref.child("Location").setValue(["Latitude": 0.0, "Longitude" : 0.0] as [String: Any])
                    
                
                        
                    UIViewController.removeSpinner(spinner: sv)
                    let alert = UIAlertController(title: "Register Success", message: "Please confirm your email address to log in", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(ok)
                    
                    
                    self.present(alert, animated: true, completion: nil)
                })
            })
            })
            
        }
        //self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func createAlert(title:String,message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(subButton)
        self.present(alert, animated: true, completion: nil)
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

    
    //Upload image
    func uploadImage(_ image: UIImage, completion: @escaping ((_ url: URL?) ->())){
        let curUser = Auth.auth().currentUser?.uid
        let storageRef = Storage.storage().reference().child("profile/"+curUser!+".jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                
                storageRef.downloadURL { url, error in
                    completion(url)
                    // success!
                }
            } else {
                // failed
                completion(nil)
            }
            
            completion(nil)
        }
    }
    
    
}
