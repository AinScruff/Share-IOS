//
//  ForgotPasswordViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 02/11/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailReset: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Dismiss Keyboard
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    
    
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    
    
    @IBAction func resetPassword(_ sender: UIButton) {
        
        self.DismissKeyboard()
        
        if emailReset.text!.count < 0{
            self.createAlert(title: "Error Reset Password", message: "Email is required")
        }else{
            Auth.auth().sendPasswordReset(withEmail: emailReset.text!, completion: {(error) in
                if error != nil{
                    self.createAlert(title: "Error Reset Password", message: error?.localizedDescription as Any as! String)
                    return
                }
                
                let alert = UIAlertController(title: "Sucess", message: "Please check your email to change password", preferredStyle: .alert)
                
                //Change leader or if no member destroy room
                let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }
                
                alert.addAction(dismiss)
                
                self.present(alert, animated: true, completion: nil)
            })
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func createAlert(title:String,message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(subButton)
        self.present(alert, animated: true, completion: nil)
    }

}
