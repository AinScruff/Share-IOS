//
//  SearchRoomViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 09/02/2019.
//  Copyright © 2019 Caryl Rabanos. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import CoreLocation

class SearchRoomViewController: UIViewController, GMSMapViewDelegate , CLLocationManagerDelegate {
    @IBOutlet weak var startLocButton: UIButton!
    @IBOutlet weak var destLocButton: UIButton!
    
    @IBOutlet weak var numGuest: UILabel!
    @IBOutlet weak var timeText: UITextField!
    
    let curUser = Auth.auth().currentUser?.uid
    
    var Destinasion = ""
    var Oragen = ""
    
    var hour : Int = 0
    var minute : Int = 0
    
    var travel : Int = 0
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    var Origin = ""
    var Destination = ""
    var originlat = 0.0
    var originlong = 0.0
    
    var Destlat = 0.0
    var Destlong = 0.0
    
    var distancekm = 0
    var startloc = CLLocation()
    var id = ""
    var route : Route?
    
    enum Location{
        case startLocation
        case destinationLocation
    }
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var maxFare = 0
    var minFare = 0
    @IBOutlet weak var searchButton: UIButton!
    
    //checker if there is time
    var timepicked = 0
    
    
    //Users
    var leader = ""
    var members = [String]()
    
    var ExtraMembers = 0
    
    //Picker
    var datePicker  = UIDatePicker()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let orig2d = CLLocationCoordinate2D(latitude: originlat, longitude: originlong)
        let Dest2d = CLLocationCoordinate2D(latitude: Destlat, longitude: Destlong)
        destLocButton.setTitle("  Destination Location", for: .normal)
        startLocButton.setTitle("  " + Oragen, for: .normal)
        ExtraMembers = 1
        
        
        showDatePicker()
        
        if Oragen != ""{
            startLocButton.setTitle("  " + Oragen, for: .normal)
        }else{
            startLocButton.setTitle("  Starting Location", for: .normal)
        }
        
        if Destinasion != "" {
            destLocButton.setTitle("  " + Destinasion, for: .normal)
        }else{
            destLocButton.setTitle("  Destination Location", for: .normal)
        }
        
        
        
        compute()
        timeText.layer.borderColor = UIColor.white.cgColor
        timeText.layer.borderWidth = 1.0
        timeText.layer.cornerRadius = 5.0
        
        timeText.attributedPlaceholder = NSAttributedString(string: "Time of Departure: ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        //Dismiss Keyboard
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
        
        
    }
    
    func compute(){
        let orig2d = CLLocationCoordinate2D(latitude: originlat, longitude: originlong)
        let Dest2d = CLLocationCoordinate2D(latitude: Destlat, longitude: Destlong)
        
        let Originway = Waypoint(coordinate: orig2d, coordinateAccuracy: -1, name: "start")
        let Destinationway = Waypoint(coordinate: Dest2d, coordinateAccuracy: -1, name: "finish")
        let options = NavigationRouteOptions(waypoints: [Originway,Destinationway], profileIdentifier: .automobile)
        _ = Directions.shared.calculate(options, completionHandler: { (waypoints, routes, error) in
            self.route = routes?.first
            self.travel = Int((self.route?.expectedTravelTime)! / 60)
            let price = 40 + (2*self.travel) + (14 * self.distancekm)
            self.minFare = price-20
            if self.minFare < 40 {
                self.minFare = 45
            }
            self.maxFare = price+20
        })
        
    }
    
    
    func showDatePicker(){
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 5
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        
        timeText.inputAccessoryView = toolbar
        timeText.inputView = datePicker
    }
    
    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timeText.text = "Time of Departure: " + formatter.string(from: datePicker.date)
        hour = Calendar.current.component(.hour, from: datePicker.date)
        minute = Calendar.current.component(.minute, from: datePicker.date)
        timepicked = 1
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        view.endEditing(true)
    }
    
    
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ref.child("users").child(curUser!).observeSingleEvent(of: .value, with: {(snapshot) in
            let val = snapshot.value as! [String:Any]
            let UserhasRoom = val["CurRoom"] as! String
            if UserhasRoom == "0"{
                self.searchButton.isEnabled = true
            }else{
                self.searchButton.isEnabled = false
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ref.removeAllObservers()
    }
    
    @IBAction func openStartLocation(_ sender: Any) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        //Selected Location
        locationSelected = .startLocation
        
        //Change Text Color
        UISearchBar.appearance().setTextColor(color: UIColor.red)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    
    @IBAction func openDestinationLocation(_ sender: Any) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        //Selected Location
        locationSelected = .destinationLocation
        
        //Change Text Color
        UISearchBar.appearance().setTextColor(color: UIColor.red)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func getDistance(_ sender: UIButton) {
        let distance = locationEnd.distance(from: locationStart)
        startloc = locationStart
        distancekm = Int(distance) / 1000
    }
    
    @IBAction func minusGuest(_ sender: Any) {
        
        self.DismissKeyboard()
        
        if numGuest.text == "2"{
            numGuest.text = "1"
            ExtraMembers = 2
        }else if numGuest.text == "1"{
            numGuest.text = "0"
            ExtraMembers = 1
        }
    }
    
    @IBAction func addGuest(_ sender: Any) {
        
        self.DismissKeyboard()
        
        if numGuest.text == "0"{
            numGuest.text = "1"
            ExtraMembers = 2
        }else if numGuest.text == "1"{
            numGuest.text = "2"
            ExtraMembers = 3
        }
    }
    
    @IBAction func timeChoose(_ sender: UIDatePicker) {
        timeText.text = "\(sender.date.getTime().Time)"
        hour = sender.date.getTime().hour
        minute = sender.date.getTime().minute
    }
    
    
    @IBAction func Search(_ sender: Any) {
        if Oragen != "" && Destinasion != ""{
            compute()
            self.performSegue(withIdentifier: "RoomResultSegue", sender: self)
        }else if Oragen == ""{
            self.createAlert(title: "Error Searching Room", message: "Please input Starting Location")
        }else if Destinasion == ""{
            self.createAlert(title: "Error Searching Room", message: "Please input Destination")
        }
        
    }
    
    func createAlert(title:String,message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(subButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "RoomResultSegue" {
            
            let navVC = segue.destination as? UINavigationController
            
            let ResultRoom = navVC?.viewControllers.first as! ResultsRoomTableViewController
            ResultRoom.Destination = Destinasion
            ResultRoom.Origin = Oragen
            ResultRoom.DestLong = Destlong
            ResultRoom.Destlat = Destlat
            ResultRoom.OriginLat = originlat
            ResultRoom.Originlong = originlong
            ResultRoom.Hour = hour
            ResultRoom.Minute = minute
            ResultRoom.Userid = id
            ResultRoom.minFare = minFare
            ResultRoom.maxFare = maxFare
            ResultRoom.estimatedTravelTime = travel
            ResultRoom.timepicked = timepicked
            ResultRoom.members = ExtraMembers
        }
    }
    
}

extension SearchRoomViewController: GMSAutocompleteViewControllerDelegate{
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //Set Coordinate to Text
        if locationSelected == .startLocation{
            startLocButton.setTitle(" \(place.name)", for: .normal)
            originlat = place.coordinate.latitude
            originlong = place.coordinate.longitude
            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            Oragen = place.name
        }else{
            destLocButton.setTitle(" \(place.name)", for: .normal)
            Destlat = place.coordinate.latitude
            Destlong = place.coordinate.longitude
            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            Destinasion = place.name
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
        let filter = GMSAutocompleteFilter()
        filter.country = "PH"
        viewController.autocompleteFilter = filter
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
        let filter = GMSAutocompleteFilter()
        filter.country = "PH"
        viewController.autocompleteFilter = filter
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
}

