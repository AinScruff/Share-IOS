//
//  EditProfileViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 19/10/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import Photos
import UIKit
import Firebase

class EditProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
 
    
    var tableItems = ["First Name", "Last Name", "Gender", "Contact Number", "Guardian Contact Number"
    ]
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    //User
    
    var profileImage = UIImage()
    var fname = ""
    var lname = ""
    var gender = ""
    var contactNumber = ""
    var EcontactNumber = ""
    
    
    let genderPick = [String](arrayLiteral: "Male", "Female")
    
    @IBOutlet weak var Done: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let thePicker = UIPickerView()
    
    override func viewDidLoad() {
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(hex: "#151515")
        super.viewDidLoad()
        thePicker.delegate = self
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        
        
       
        
        view.addGestureRecognizer(Tap)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    
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
        
        let indexpath = IndexPath(row: 3, section: 0)
    
        let cell = tableView.cellForRow(at: indexpath) as! EditProfileTableViewCell
       
        cell.infoLabel.text = genderPick[row]
        self.gender = cell.infoLabel.text!
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableItems.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderMyRoomTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellItems", for: indexPath) as! EditProfileTableViewCell
        
        let myColor = UIColor.white
        cell.infoLabel.layer.borderColor = myColor.cgColor
        cell.infoLabel.layer.borderWidth = 1.0
        cell.infoLabel.layer.cornerRadius = 5.0
        
        headerCell.selectionStyle = .none
        cell.selectionStyle = .none
        
        if(indexPath.row == 0){
        
            headerCell.imageDisplay.image = profileImage
            headerCell.imageDisplay.setRound()
            
            headerCell.uploadImage.addTarget(self, action: #selector(EditProfileViewController.uploadImageAction(_:)), for: .touchUpInside)
            
            return headerCell
            
        }
        
        switch indexPath.row{
        case 1:
            cell.titleLabel.text = tableItems[indexPath.row - 1]
            cell.infoLabel.text = fname
            return cell
        case 2:
            cell.titleLabel.text = tableItems[indexPath.row - 1]
            cell.infoLabel.text = lname
            return cell
        case 3:
            cell.titleLabel.text = tableItems[indexPath.row - 1]
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.donedatePicker))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
            
            toolbar.setItems([cancelButton, spaceButton, doneButton], animated: true)
            
            cell.infoLabel.inputAccessoryView = toolbar
            
            cell.infoLabel.inputView = thePicker
            
            cell.infoLabel.text = gender
            return cell
        case 4:
            cell.titleLabel.text = tableItems[indexPath.row - 1]
            cell.infoLabel.text = contactNumber
            cell.infoLabel.delegate = self
            cell.infoLabel.keyboardType = .phonePad
            
            return cell
        case 5:
            cell.titleLabel.text = tableItems[indexPath.row - 1]
            cell.infoLabel.text = EcontactNumber
            cell.infoLabel.delegate = self
            cell.infoLabel.keyboardType = .phonePad
            return cell
        default:
            break
        }
        
        return cell
    }
    
    @objc func donedatePicker(){
        
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        view.endEditing(true)
    }
    
    
    @IBAction func uploadImageAction(_ sender: Any){
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
            
            let indexpath = IndexPath(row: 0, section: 0)
            
            var selectImage : [UIImage] = [selectedImage]
        
            (tableView.cellForRow(at: indexpath) as!  HeaderMyRoomTableViewCell).imageDisplay.image! = selectImage[0]
                
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    

    
    
    @IBAction func EditDone(_ sender: Any) {
        
       
        //Fix nil cell TEXTFIELD WHEN ACCESSING
        
        for row in 0 ... 5{
            
            let indexpath = IndexPath(row: row, section: 0)
            
            switch row{
            case 0:
                let headerCell = tableView.cellForRow(at: indexpath) as! HeaderMyRoomTableViewCell
                self.profileImage = headerCell.imageDisplay.image!
            case 1:
                print(indexpath)
                let cell = tableView.cellForRow(at: indexpath) as! EditProfileTableViewCell
                self.fname = cell.infoLabel.text!
            case 2:
                let cell = tableView.cellForRow(at: indexpath) as! EditProfileTableViewCell
                self.lname = cell.infoLabel.text!
            case 3:
                let cell = tableView.cellForRow(at: indexpath) as! EditProfileTableViewCell
                self.gender = cell.infoLabel.text!
            case 4:
                let cell = tableView.cellForRow(at: indexpath) as! EditProfileTableViewCell
                self.contactNumber = cell.infoLabel.text!
            case 5:
                let cell = tableView.cellForRow(at: indexpath) as! EditProfileTableViewCell
                self.EcontactNumber = cell.infoLabel.text!
            default:
                break
            }

        }

        self.editAction(Fname: self.fname, Lname: self.lname, Gender: self.gender, ContactNumber: self.contactNumber, EmergencyContact: self.EcontactNumber, Image: self.profileImage)
        
    }
    
    
    func uploadImage(_ image: UIImage, completion: @escaping ((_ url: URL?) ->())){
        
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
    
    func editAction(Fname: String, Lname: String, Gender: String, ContactNumber: String, EmergencyContact: String, Image: UIImage) {
    
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
        }else if ContactNumber.count == 0{
            self.createAlert(title: "No Contact Number", message: "Please input Contact Number")
        }else if EmergencyContact.count == 0{
            self.createAlert(title: "No Emergency Contact Number", message: "Please input Emergency Contact Number")
        }else if ContactNumber.count != 13{
            self.createAlert(title: "Invalid Contact Number", message: "Please input the international format for contact number: '+63...'")
        }else if EmergencyContact.count != 13{
            self.createAlert(title: "Invalid Emergency Contact Number", message: "Please input the international format for contact number: '+63...'")
        }else if ContactNumber.prefix(3) != "+63" {
            self.createAlert(title: "Invalid Contact Number", message: "Please input the international format for contact number: '+63...'")
        }else if EmergencyContact.prefix(3) != "+63"{
            self.createAlert(title: "Invalid Emergency Contact Number", message: "Please input the international format for contact number: '+63...'")
            
        }else{
            let values = ["Fname": Fname, "Lname": Lname, "Gender": Gender, "ContactNumber": ContactNumber,"EmergencyContact": EmergencyContact] as [String : String]
            
            ref.child("users").child(curUser!).updateChildValues(values)
            
            self.uploadImage(Image) { url in
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.photoURL = url
            }
            
            let alert = UIAlertController(title: "Success", message: "Successfully changed your profile details", preferredStyle: .alert)
            
            let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) -> Void in
                 _ = self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(dismiss)
            
            
            self.present(alert, animated: true, completion: nil)
           
        }
        
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
    
    func createAlert(title:String,message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(subButton)
        self.present(alert, animated: true, completion: nil)
    }
    
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
