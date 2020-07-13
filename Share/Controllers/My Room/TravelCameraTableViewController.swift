//
//  TravelCameraTableViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 06/04/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit
import Firebase

class TravelCameraTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var curRoom = ""
    var sections = ["Travel Photo", "Taxi Details", "Proceed"]
    var travelImage : UIImage? = nil
    
    var imagePicker = UIImagePickerController()
    
    
    //Travel Option (Taxi or PrivateCar)
    var travelOption = ""
    
    //Taxi Details
    var taxiOperator = ""
    var taxiNumber = ""
    var taxiPlateNumber = ""
    
  var spinner = UIView()
    override func viewDidLoad() {
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(hex: "#151515")
        super.viewDidLoad()
        
        //Dismiss Keyboard
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
    }

    
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //If Ride option is private car hide taxi details
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerFrame = tableView.frame
        
        let myLabel = UILabel()
        
        myLabel.frame = CGRect(x: 15, y: 20, width: headerFrame.size.width-20, height: 20)
        myLabel.font = UIFont.systemFont(ofSize: 12)
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        myLabel.textColor = UIColor.lightGray
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: headerFrame.size.width, height: headerFrame.size.height))
        headerView.addSubview(myLabel)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 3
        }else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height:CGFloat = 0.0
        
        
        //if travel option is private car set section 2 to 0.0
        if indexPath.section == 0{
            height = 200.0
        }else if indexPath.section == 1{
            height = 45.0
        }else{
            height = 60
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderMyRoomTableViewCell
        
        let travelCell = tableView.dequeueReusableCell(withIdentifier: "taxiCell") as! TravelCameraTableViewCell
        let proceedCell = tableView.dequeueReusableCell(withIdentifier: "proceedCell") as! TravelCameraTableViewCell
  
        var taxiLabel = ["Operator", "Taxi Number", "Taxi Plate Number"]
        travelCell.selectionStyle = .none
        
        switch indexPath.section{
        case 0:
            headerCell.uploadImage.addTarget(self, action: #selector(TravelCameraTableViewController.uploadImageAction(_:)), for: .touchUpInside)
        case 1:
            //Hide this if travel option is private car
            switch indexPath.row{
            case 0 ..< taxiLabel.count:
                travelCell.travelCameraLabel.text = taxiLabel[indexPath.row] + ":"
            return travelCell
            default:
                break
            }
        case 2:
            proceedCell.proceedButton.addTarget(self, action: #selector(TravelCameraTableViewController.startTravel(_:)), for: .touchUpInside)
            return proceedCell
        default:
            break
        }
        
        return headerCell
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadImageAction(_ sender: Any){
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selectedImage = info[.originalImage] as? UIImage
        
        let indexpath = IndexPath(row: 0, section: 0)
        
        (tableView.cellForRow(at: indexpath) as! HeaderMyRoomTableViewCell).imageDisplay.image = selectedImage
        (tableView.cellForRow(at: indexpath) as! HeaderMyRoomTableViewCell).imageDisplay.setRound()
        dismiss(animated:true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func startTravel(_ sender: Any){
        
        let imageIndex = IndexPath(row: 0, section: 0)
        let imageCell = tableView.cellForRow(at: imageIndex) as! HeaderMyRoomTableViewCell
        
        travelImage = imageCell.imageDisplay.image
        
        for indexRow in 0 ..< 3{
            let index = IndexPath(row: indexRow, section: 1)
            let travelCell = tableView.cellForRow(at: index) as! TravelCameraTableViewCell
            
            let myColor = UIColor.white
    
            travelCell.travelCameraTextField.layer.borderColor = myColor.cgColor
            travelCell.travelCameraTextField.layer.borderWidth = 1.0
            travelCell.travelCameraTextField.layer.cornerRadius = 5.0
            
            switch index.row{
                case 0:
                    taxiOperator = travelCell.travelCameraTextField.text!
                case 1:
                    taxiNumber = travelCell.travelCameraTextField.text!
                case 2:
                    taxiPlateNumber = travelCell.travelCameraTextField.text!
                default:
                    break
            }
        }
        
        //IF taxiOption != taxi exclude below
        
        if taxiOperator == ""{
                let alert = UIAlertController(title: "Taxi Operator Field is Empty", message: "Please fill out the field", preferredStyle: .alert)
                let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(subButton)
                self.present(alert, animated: true, completion: nil)
        }else if taxiNumber == ""{
                let alert = UIAlertController(title: "Taxi Number Field is Empty", message: "Please fill out the field", preferredStyle: .alert)
                let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(subButton)
                self.present(alert, animated: true, completion: nil)
        }else if taxiPlateNumber == ""{
                let alert = UIAlertController(title: "Taxi Number Field is Empty", message: "Please fill out the field", preferredStyle: .alert)
                let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(subButton)
                self.present(alert, animated: true, completion: nil)
        }else if travelImage == nil{
                let alert = UIAlertController(title: "Error Starting Travel", message: "Please take a picture first", preferredStyle: .alert)
                let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(subButton)
                self.present(alert, animated: true, completion: nil)
        }else{
           setAvailable()
        }
    }
    
    //Start travel set available to 0
    func setAvailable(){
        
        let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
        
        ///chagne availble to 0
        let taxi = ref.child("travel").child(curRoom).child("taxi")
        
        ref.child("travel").child(curRoom).updateChildValues(["Available" : 0])
        taxi.setValue(["Operator" : taxiOperator, "PlateNumber" : taxiPlateNumber, "TaxiNumber" : taxiNumber])
        
        self.uploadImage(travelImage!) { url in
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.photoURL
        }
        
        
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping ((_ url: URL?) ->())){
        
        let storageRef = Storage.storage().reference().child("travel/"+curRoom+".jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.30) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
      
    
        self.spinner = UIViewController.displaySpinner(onView: self.view)
        self.navigationItem.leftBarButtonItems?[0].isEnabled = false
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                
                storageRef.downloadURL { url, error in
                    completion(url)
                    UIViewController.removeSpinner(spinner: self.spinner)
                    self.navigationItem.leftBarButtonItems?[0].isEnabled = true
                    self.dismiss(animated: true, completion: nil)  // success!
                }
            } else {
                // failed
                completion(nil)
            }
            completion(nil)
        }
    }
    
}
