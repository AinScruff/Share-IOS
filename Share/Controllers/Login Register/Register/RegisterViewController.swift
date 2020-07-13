//
//  RegisterViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 03/11/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit
import Firebase
import Photos

class RegisterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var fNameTxtField: UITextField!
    @IBOutlet weak var lNameTxtField: UITextField!
    @IBOutlet weak var contactNumberTxtField: UITextField!
    @IBOutlet weak var genderTxtField: UITextField!
    @IBOutlet weak var emergencyContactTxtField: UITextField!
    @IBOutlet weak var imageDisplay: UIImageView!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var genderPicker: UIPickerView!
    

    let thePicker = UIPickerView()
    
    let genderPick = ["Male","Female"]
    
    //--------------------------------------Gender Picker-------------------------------------------
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderPick.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderPick[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        genderTxtField.text = genderPick[row]
    }
    
    //--------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        
        genderTxtField.inputAccessoryView = toolbar
        
        genderTxtField.inputView = thePicker
        thePicker.delegate = self

        super.viewDidLoad()
        
        emailTxtField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passwordTxtField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        fNameTxtField.attributedPlaceholder = NSAttributedString(string: "First Name",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        lNameTxtField.attributedPlaceholder = NSAttributedString(string: "Last Name",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        contactNumberTxtField.attributedPlaceholder = NSAttributedString(string: "Contact Number",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        emergencyContactTxtField.attributedPlaceholder = NSAttributedString(string: "Emergency Contact Number",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        genderTxtField.attributedPlaceholder = NSAttributedString(string: "Gender",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        confirmPassword.attributedPlaceholder = NSAttributedString(string: "Confirm Password",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        contactNumberTxtField.delegate = self
        emergencyContactTxtField.delegate = self
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
        
    }
    
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc func donedatePicker(){
        
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        view.endEditing(true)
    }
    
    
    

    
    @IBAction func uploadImageAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            PHPhotoLibrary.requestAuthorization{ (status) in
                switch status {
                case .authorized:
                    let myPickerController = UIImagePickerController()
                    myPickerController.delegate = self
                    myPickerController.allowsEditing = true
                    myPickerController.sourceType = .photoLibrary
                    self.present(myPickerController, animated: true)
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization({
                        (newStatus) in
                        print("status is \(newStatus)")
                        if newStatus ==  PHAuthorizationStatus.authorized {
                            print("success")
                        }
                    })
                    print("It is not determined until now")
                case .restricted:
                    print("User do not have access to photo album.")
                case .denied:
                    print("User has denied the permission.")
                default:
                    break
                }

            }
        }

    }


    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        var selectedImageFromPicker: UIImage?

        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker{
            var selectImage : [UIImage] = [selectedImage]

             imageDisplay.image! = selectImage[0]
             imageDisplay.setRound()
        }
        self.dismiss(animated: true, completion: nil)
    }

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

    @IBAction func RegisterControl(_ sender: UIButton)
    {
        guard let email = emailTxtField.text, let password = passwordTxtField.text, let Fname = fNameTxtField.text, let Lname = lNameTxtField.text, let Gender = genderTxtField.text ,let Contact = contactNumberTxtField.text, let EmergencyContact = emergencyContactTxtField.text, let confirmPassword = confirmPassword.text
            else{
                print("Form invalid!")
                return
        }

        //--------------------------Validation for fields--------------------------------------------
        if Fname.count == 0 {
            self.createAlert(title: "No First Name", message: "Please enter First Name")
        }else if isValidName(name: Fname) == false{
            self.createAlert(title: "Invalid First Name", message: "Bad First Name format")
        }else if Lname.count == 0 {
            self.createAlert(title: "No Last Name", message: "Please enter Last Name")
        }else if isValidName(name: Fname) == false{
            self.createAlert(title: "Invalid Last Name", message: "Bad Last Name format")
        }else if Gender.count == 0{
            self.createAlert(title: "No Gender", message: "Please input Gender")
        }else if Contact.count == 0{
            self.createAlert(title: "No Contact Number", message: "Please input Contact Number")
        }else if EmergencyContact.count == 0{
            self.createAlert(title: "No Emergency Contact Number", message: "Please input Emergency Contact Number")
        }else if Contact.count != 13{
            self.createAlert(title: "Invalid Contact Number", message: "Please input the international format for contact number: '+63...'")
        }else if EmergencyContact.count != 13{
            self.createAlert(title: "Invalid Emergency Contact Number", message: "Please input the international format for contact number: '+63...'")
        }else if Contact.prefix(3) != "+63" {
            self.createAlert(title: "Invalid Contact Number", message: "Please input the international format for contact number: '+63...'")
        }else if EmergencyContact.prefix(3) != "+63"{
            self.createAlert(title: "Invalid Emergency Contact Number", message: "Please input the international format for contact number: '+63...'")
            
        }else if email.count == 0 {
            self.createAlert(title: "No email", message: "Please enter email")
        }else if isValidEmail(email: email) == false {
            self.createAlert(title: "Invalid Email", message: "Wrong email format")
        }else if password.count < 6 {
            self.createAlert(title: "Password too short",message: "Password must be atleast 6 characters long")
        }else if confirmPassword.count < 6{
            self.createAlert(title: "Confirm Password too short",message: "Confirm Password must be atleast 6 characters long")
        }else if password != confirmPassword{
            self.createAlert(title: "Password Error",message: "Passwords does not match")
        }else{
            self.performSegue(withIdentifier: "registerPin", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registerPin"{
            let pinVC = segue.destination as! RegisterPinViewController
            
            pinVC.profileImage = imageDisplay.image!
            pinVC.email = emailTxtField.text!
            pinVC.password = passwordTxtField.text!
            pinVC.fname = fNameTxtField.text!
            pinVC.lname = lNameTxtField.text!
            pinVC.gender = genderTxtField.text!
            pinVC.contactNumber = contactNumberTxtField.text!
            pinVC.econtactNumber = emergencyContactTxtField.text!
            
        }
    }
    
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion:  nil)
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAlert(title:String,message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(subButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(email:String)->Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isValidNumber(contact:Int)->Bool
    {
        let contactRegEx = "^((\\+)|(00))[0-9]{6,14}$"
        let contactTest = NSPredicate(format:"SELF MATCHES %@", contactRegEx)
        return contactTest.evaluate(with:contact)
    }
    
    func isValidName(name: String)->Bool
    {
        let characterset = CharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        if name.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }else{
            return true
        }
    }
    
    
    //Limit number of text in textfield
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 13
    }
}


