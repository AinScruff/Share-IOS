//
//  ChangePasswordViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 16/11/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var ReTypeTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
  
    override func viewDidLoad() {
        
        let myColor = UIColor.white
        currentPasswordTextField.layer.borderColor = myColor.cgColor
        currentPasswordTextField.layer.borderWidth = 1.0
        currentPasswordTextField.layer.cornerRadius = 5.0
        
        newPasswordTextField.layer.borderColor = myColor.cgColor
        newPasswordTextField.layer.borderWidth = 1.0
        newPasswordTextField.layer.cornerRadius = 5.0
        
        ReTypeTextField.layer.borderColor = myColor.cgColor
        ReTypeTextField.layer.borderWidth = 1.0
        ReTypeTextField.layer.cornerRadius = 5.0
        
        currentPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Current Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        newPasswordTextField.attributedPlaceholder = NSAttributedString(string: "New Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        ReTypeTextField.attributedPlaceholder = NSAttributedString(string: "Re-type New Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        super.viewDidLoad()
        
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        
        view.addGestureRecognizer(Tap)
        
    
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveNewPassword(_ sender: Any) {
        
        self.DismissKeyboard()
    
        if(currentPasswordTextField.text!.count == 0){
            createAlert(title: "Change Password Error", message: "Current Password is empty.")
        }else if currentPasswordTextField.text!.count < 6{
            createAlert(title: "Change Password Error", message: "Current Password must be atleast 6 characters long")
        }else if(newPasswordTextField.text!.count == 0){
            createAlert(title: "Change Password Error", message: "New Password is empty.")
        }else if newPasswordTextField.text!.count < 6 {
            createAlert(title: "Change Password Error", message: "New Password must be atleast 6 characters long")
        }else if(ReTypeTextField.text!.count == 0){
            createAlert(title: "Change Password Error", message: "Re-type Password is empty.")
        }else if ReTypeTextField.text!.count < 6{
            createAlert(title: "Change Password Error", message: "Re-type Password must be atleast 6 characters long")
        }else if newPasswordTextField.text != ReTypeTextField.text {
                createAlert(title: "Change Password Error", message: "Passwords do not match.")
        }else{
            
            let user = Auth.auth().currentUser
            
            let credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: currentPasswordTextField.text!)
            
            Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (error) in
                if error == nil {
                    let alert = UIAlertController(title: "Success", message: "Successfully changed password", preferredStyle: .alert)
                    
                    let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                        user!.updatePassword(to: self.newPasswordTextField.text!)
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(dismiss)
                    
                    
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    let alert = UIAlertController(title: "Change Password Error", message: "Incorrect Current Password", preferredStyle: .alert)
                    
                    let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                    }
                    alert.addAction(dismiss)
                    
                    
                    self.present(alert, animated: true, completion: nil)
                }
            })
            
            
            
        }
        
    }
    
    func createAlert(title: String,message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(subButton)
        self.present(alert, animated: true, completion: nil)
 
    }
    
}
