//
//  ChangePinViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 16/11/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit
import Firebase
class ChangePinViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var oldPin: UITextField!
    @IBOutlet weak var newPin: UITextField!
    @IBOutlet weak var confirmPin: UITextField!
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    
    var pin = NSNumber()

    override func viewDidLoad() {
        
        let myColor = UIColor.white
        
        oldPin.layer.borderColor = myColor.cgColor
        oldPin.layer.borderWidth = 1.0
        oldPin.layer.cornerRadius = 5.0
        
        newPin.layer.borderColor = myColor.cgColor
        newPin.layer.borderWidth = 1.0
        newPin.layer.cornerRadius = 5.0
        
        confirmPin.layer.borderColor = myColor.cgColor
        confirmPin.layer.borderWidth = 1.0
        confirmPin.layer.cornerRadius = 5.0
        
        
        oldPin.attributedPlaceholder = NSAttributedString(string: "Old Pin", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        oldPin.delegate = self
        
        newPin.attributedPlaceholder = NSAttributedString(string: "New Pin", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        newPin.delegate = self
        confirmPin.attributedPlaceholder = NSAttributedString(string: "Confirm Pin", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        confirmPin.delegate = self
        
        super.viewDidLoad()
        
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        
        view.addGestureRecognizer(Tap)
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        ref.child("users").child(curUser!).observe(.value, with: {(snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            //Get User
            self.pin = value?["Pin"] as! NSNumber
        })
    }
    
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }

    
    @IBAction func changePin(_ sender: Any) {
        
        if oldPin.text == ""{
            self.createAlert(title: "Error Changing Pin", message: "Old Pin is required")
        }else if oldPin.text!.count < 4{
            self.createAlert(title: "Error Changing Pin", message: "Old Pin must be 4 digits")
        }else if newPin.text == ""{
            self.createAlert(title: "Error Changing Pin", message: "New Pin is required")
        }else if newPin.text!.count < 4{
            self.createAlert(title: "Error Changing Pin", message: "New Pin must be 4 digits")
        }else if confirmPin.text == ""{
            self.createAlert(title: "Error Changing Pin", message: "Confirm Pin is required")
        }else if confirmPin.text!.count < 4{
            self.createAlert(title: "Error Changing Pin", message: "Confirm Pin must be 4 digits")
        }else if newPin.text != confirmPin.text{
            self.createAlert(title: "Error Changing Pin", message: "New Pin does not match to Confirm Pin ")
        }else if oldPin.text != self.pin.stringValue {
            self.createAlert(title: "Error Changing Pin", message: "Incorrect Old Pin")
           
        }else{
            let alert = UIAlertController(title: "Success", message: "Successfully changed pin", preferredStyle: .alert)
            
            let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                let pin = NSNumber(value: Int(self.confirmPin.text!)!)
                self.ref.child("users").child(self.curUser!).updateChildValues(["Pin" : pin])
                _ = self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(dismiss)
            
            
            self.present(alert, animated: true, completion: nil)
        }
   
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 4
    }
    
    
    func createAlert(title: String,message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(subButton)
        self.present(alert, animated: true, completion: nil)
        
    }
}
