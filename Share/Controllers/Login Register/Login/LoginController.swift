//
//  LoginController.swift
//  Share
//
//  Created by Caryl Rabanos on 06/09/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit
import Firebase


class LoginController: UIViewController {
    
    @IBOutlet weak var EmailTxtField: UITextField!
    @IBOutlet weak var PasswordTxtField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //User
    
    var profileImage = UIImage()
    var fname = ""
    var lname = ""
    var gender = ""
    var contactNumber = ""
    var EcontactNumber = ""
    var pin = ""
    var curUser = ""
    var curRoom = ""
    
    override func viewDidLoad() {
        
        self.activityIndicator.isHidden = true
        
        //CHANGE COLOR OF PLACEHOLDER
        EmailTxtField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        PasswordTxtField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
//        EmailTxtField.leftViewMode = UITextField.ViewMode.always
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
//        let image = UIImage(named: "phflag")
//        imageView.image = image
//        EmailTxtField.leftView = imageView
        super.viewDidLoad()

        //Dismiss Keyboard
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    
    
    
    @IBAction func loginAction(_ sender: Any) {
        
        
        self.DismissKeyboard()
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        self.activityIndicator.startAnimating()
        
        self.PasswordTxtField.layer.borderColor = UIColor.white.cgColor
        
        guard let email = EmailTxtField.text, let password = PasswordTxtField.text
            else{
            UIViewController.removeSpinner(spinner: sv)
            self.activityIndicator.stopAnimating()
            print("form invalid")
            return
        }
        
        if email.count == 0{
            self.createAlert(title: "Error Logging in", message: "Email is required.")
            UIViewController.removeSpinner(spinner: sv)
            self.activityIndicator.stopAnimating()
        }else if password.count == 0{
            self.createAlert(title: "Error Logging in", message: "Password is required.")
            UIViewController.removeSpinner(spinner: sv)
            self.activityIndicator.stopAnimating()
        }else{
            Auth.auth().signIn(withEmail: email, password: password, completion: {(user,error) in
                let user = Auth.auth().currentUser
                
                if error != nil{
                    UIViewController.removeSpinner(spinner: sv)
                    self.activityIndicator.stopAnimating()
                    self.createAlert(title: "Error", message: error?.localizedDescription as Any as! String)
                    return
                    
                }else if(user?.isEmailVerified)!{
                    let userId = Auth.auth().currentUser?.uid
                    self.putData(id: userId!, sv: sv)
                }else{
                    UIViewController.removeSpinner(spinner: sv)
                    self.activityIndicator.stopAnimating()
                    self.createAlert(title: "Email not verified", message: "Please check your email")
                }
            })
        }
        
        
    }
    
    
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion:  nil)
    }
    
    func createAlert(title:String,message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(subButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func putData(id: String, sv: UIView){
        
        let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
        
        if activityIndicator.isAnimating == true {
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            ref.child("users").child(id).observeSingleEvent(of: .value, with: {(snapshot) in
                
                let value = snapshot.value as? NSDictionary
                
                self.curUser = id
                self.fname = value?["Fname"] as! String
                self.lname = value?["Lname"] as! String
                self.gender = value?["Gender"] as! String
                self.contactNumber = value?["ContactNumber"] as! String
                self.EcontactNumber = value?["EmergencyContact"] as! String
                self.curRoom = String(format: "%@", value?["CurRoom"] as! CVarArg)
                
                
                UIViewController.removeSpinner(spinner: sv)
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.EmailTxtField.text = ""
                self.PasswordTxtField.text = ""
                self.performSegue(withIdentifier: "MainTabViewSegue", sender: self)
//                let storageRef = Storage.storage().reference().child("profile/" + id + ".jpg")
//
//                storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
//
//                    self.profileImage = UIImage(data: data!)!
//
//                    
//                }
                
            }){(error) in
                print(error.localizedDescription)
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MainTabViewSegue"{
            let tabBar = segue.destination as! UITabBarController
            let navController = tabBar.viewControllers![3] as! UINavigationController
            let accountVc = navController.topViewController as! AccountTabViewController
                //accountVc.profileImage = self.profileImage
        }
    }
    
}
