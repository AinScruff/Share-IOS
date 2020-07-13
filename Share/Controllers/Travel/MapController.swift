//
//  MapController.swift
//  Share
//
//  Created by Caryl Rabanos on 22/10/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

var ExtraMembers = 1
enum Location{
    case startLocation
    case destinationLocation
}

class MapController: UIViewController, MGLMapViewDelegate, GMSMapViewDelegate, CLLocationManagerDelegate{
    
    
    @IBOutlet var mapView: NavigationMapView!
    @IBOutlet weak var startLocButton: UIButton!
    @IBOutlet weak var destLocButton: UIButton!
    
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let currentId = Auth.auth().currentUser?.uid
    

    
    var action = "Create"
    
    
    var Origin = ""
    var Destination = ""
    var originlat = 0.0
    var originlong = 0.0
  
    var Destlat = 0.0
    var Destlong = 0.0
    
    var distancekm = 0
    var startloc = CLLocation()
    
    var navigateButton: UIButton!
    var directionsRoute: Route?
    var directionsRoute2: Route?
    var directionsRoute3: Route?
    var current = CLLocation()
    var dest = [String]()
    var orig = [String]()
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    
    @IBOutlet weak var OriginButton: UIButton!
    @IBOutlet weak var DestinationButton: UIButton!
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    
    var curRoom = "gib room"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myColor = UIColor.white
        
        startLocButton.layer.borderColor = myColor.cgColor
        startLocButton.layer.borderWidth = 1.0
        
        
        destLocButton.layer.borderColor = myColor.cgColor
        destLocButton.layer.borderWidth = 1.0
        
        var orig2d = CLLocationCoordinate2D(latitude: originlat, longitude: originlong)
        var Dest2d = CLLocationCoordinate2D(latitude: Destlat, longitude: Destlong)
        
        self.DestinationButton.isEnabled = false
        
        //
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        current = CLLocation(latitude: (mapView.userLocation?.coordinate.latitude)!, longitude: (mapView.userLocation?.coordinate.longitude)!)
        mapView.setUserTrackingMode(.follow, animated: true)
        if currentId != nil {
            ref.child("users").child(currentId!).observe(.value, with: {(snapshot) in
                let value = snapshot.value as? NSDictionary
                self.curRoom = value!["CurRoom"] as! String
                
                if(self.curRoom != "0" && self.curRoom != "Requesting" && self.curRoom != "Kicked"){
                    self.navigationItem.rightBarButtonItems?[0].isEnabled = false
                    self.OriginButton.isEnabled = false
                    self.ref.child("travel").child(self.curRoom).observeSingleEvent(of: .value, with: {(snapshot) in
                        let RouteValue = snapshot.value as? NSDictionary
                        self.destLocButton.setTitle(RouteValue!["DestinationString"] as? String, for: .normal)
                        self.startLocButton.setTitle(RouteValue!["OriginString"] as? String, for: .normal)
                        self.ref.child("travel").child(self.curRoom).child("Destination").observeSingleEvent(of: .value, with: {(DestSnap) in
                            let DestinationValue = DestSnap.value as? NSDictionary
                            self.Destlat = DestinationValue!["latitude"] as! Double
                            self.Destlong = DestinationValue!["longitude"] as! Double
                             Dest2d = CLLocationCoordinate2D(latitude: self.Destlat, longitude: self.Destlong)
                            self.ref.child("travel").child(self.curRoom).child("Origin").observeSingleEvent(of: .value, with: {(OriginSnap) in
                                let OriginValue = OriginSnap.value as? NSDictionary
                                self.originlong = (OriginValue!["longitude"] as? Double)!
                                self.originlat = (OriginValue!["latitude"] as? Double)!
                                orig2d = CLLocationCoordinate2D(latitude: self.originlat, longitude: self.originlong)
                                self.navigateRoute()
                            })
                        })
                        
                    })
                }
            })
        } else {
            self.OriginButton.isEnabled = true
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.rightBarButtonItem!.isEnabled = false
        if Origin != "" && Destination != ""{
//            if directionsRoute != nil && directionsRoute2 != nil && directionsRoute3 != nil {
//            self.mapView.removeAnnotation(directionsRoute as! MGLAnnotation)
//            self.mapView.removeAnnotation(directionsRoute2 as! MGLAnnotation)
//            self.mapView.removeAnnotation(directionsRoute3 as! MGLAnnotation)
//          }
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigateRoute()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //selecting start location
    @IBAction func openStartLocation(_ sender: UIButton) {
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        //Selected Location
        locationSelected = .startLocation
        
        //Change Text Color
        UISearchBar.appearance().setTextColor(color: UIColor.red)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
        
    }
    
    //selecting destination
    @IBAction func openDestinationLocation(_ sender: UIButton){
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        //Selected location
        locationSelected = .destinationLocation
        
        //Change Text Color
        UISearchBar.appearance().setTextColor(color: UIColor.red)
        self.locationManager.stopUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    
    
    func navigateRoute(){
        mapView.setUserTrackingMode(.follow, animated: true)
        let orig2d = CLLocationCoordinate2D(latitude: originlat, longitude: originlong)
        let Dest2d = CLLocationCoordinate2D(latitude: Destlat, longitude: Destlong)
        calculateRoute(from: orig2d, to: Dest2d) { (route, error) in
            if error != nil{
                print("error routing")
            }
        }
    }
    
    func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping(Route?,Error?)-> Void){
        
        let Origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "start")
        let Destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "finish")
        
        
        let options = NavigationRouteOptions(waypoints: [Origin,Destination], profileIdentifier: .automobileAvoidingTraffic)
        _ = Directions.shared.calculate(options, completionHandler: { (waypoints, routes, error) in
            let size = routes?.count
            if(size == 1){
                self.directionsRoute = routes?[0]
                if (self.directionsRoute?.coordinateCount)! > 0{
                    let routeCoordinates = self.directionsRoute?.coordinates
                    let routeLine = MGLPolyline(coordinates: routeCoordinates!, count: (self.directionsRoute?.coordinateCount)!)
                    self.mapView.addAnnotation(routeLine)
                    self.mapView.setVisibleCoordinates(routeCoordinates!, count: (self.directionsRoute?.coordinateCount)!, edgePadding: .zero, animated: true)
                }
            }else if(size == 2){
                self.directionsRoute = routes?[0]
                self.directionsRoute2 = routes?[1]
                if (self.directionsRoute?.coordinateCount)! > 0{
                    let routeCoordinates = self.directionsRoute?.coordinates
                    let routeCoordinates2 = self.directionsRoute2?.coordinates
                    let routeLine = MGLPolyline(coordinates: routeCoordinates!, count: (self.directionsRoute?.coordinateCount)!)
                    let routeLine2 = MGLPolyline(coordinates: routeCoordinates2!, count: (self.directionsRoute2?.coordinateCount)!)
                    self.mapView.addAnnotation(routeLine)
                    self.mapView.addAnnotation(routeLine2)
                    self.mapView.setVisibleCoordinates(routeCoordinates!, count: (self.directionsRoute?.coordinateCount)!, edgePadding: .zero, animated: true)
                }
            }else if(size! <= 3){
                self.directionsRoute = routes?[0]
                self.directionsRoute2 = routes?[1]
                self.directionsRoute3 = routes?[2]
                if (self.directionsRoute?.coordinateCount)! > 0{
                    let routeCoordinates = self.directionsRoute?.coordinates
                    let routeCoordinates2 = self.directionsRoute2?.coordinates
                    let routeCoordinates3 = self.directionsRoute3?.coordinates
                    let routeLine = MGLPolyline(coordinates: routeCoordinates!, count: (self.directionsRoute?.coordinateCount)!)
                    let routeLine2 = MGLPolyline(coordinates: routeCoordinates2!, count: (self.directionsRoute2?.coordinateCount)!)
                    let routeLine3 = MGLPolyline(coordinates: routeCoordinates3!, count: (self.directionsRoute3?.coordinateCount)!)
                    self.mapView.addAnnotation(routeLine)
                    self.mapView.addAnnotation(routeLine2)
                    self.mapView.addAnnotation(routeLine3)
                    self.mapView.setVisibleCoordinates(routeCoordinates!, count: (self.directionsRoute?.coordinateCount)!, edgePadding: .zero, animated: true)
                }
                
            }
            
            let coordinateBounds = MGLCoordinateBoundsMake(destination, origin)
            let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
            let routeCam = self.mapView.cameraThatFitsCoordinateBounds(coordinateBounds, edgePadding: insets)
            let DestMarker = MGLPointAnnotation()
            let OriginMarker = MGLPointAnnotation()
            DestMarker.coordinate = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
            OriginMarker.coordinate = CLLocationCoordinate2D(latitude: origin.latitude, longitude: origin.longitude)
            DestMarker.title = "Destination"
            OriginMarker.title = "Origin"
            let distance = self.locationEnd.distance(from: self.locationStart)
            self.startloc = self.locationStart
            self.distancekm = Int(distance) / 1000
            self.mapView.setCamera(routeCam, animated: true)
            self.mapView.addAnnotation(DestMarker)
            self.mapView.addAnnotation(OriginMarker)
        })
    }
    
    
    func drawRoute(route:Route){
        guard route.coordinateCount > 0 else{return}
        var routeCoordinates = route.coordinates!
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource{
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source",features: [polyline], options: nil)
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: UIColor.blue)
            lineStyle.lineCap = NSExpression(forConstantValue: "round")
            lineStyle.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'exponential', 1.5, %@)",
                                               [14: 2,
                                                18: 20])
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
        }
    }
    
    
    func drawRoute2(route: Route) {
        
        var routeCoordinates = route.coordinates!
        
        let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        mapView.addAnnotation(routeLine)
        
        mapView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: .zero, animated: true);
        
        mapView.add(routeLine)
        
    }
    
    func createAlert(title:String,message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(subButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func TransferSearchRoom(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "SearchRoom", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchRoom" {
            let SearchRoom = segue.destination  as! SearchRoomViewController
            
            
            SearchRoom.Destinasion = Destination
            SearchRoom.Oragen = Origin
            SearchRoom.Destlat = Destlat
            SearchRoom.Destlong = Destlong
            SearchRoom.originlong = originlong
            SearchRoom.originlat = originlat
            SearchRoom.id = currentId!
            SearchRoom.distancekm = distancekm
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.ref.removeAllObservers()
    }
    
}

extension MapController: GMSAutocompleteViewControllerDelegate{
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //Set Coordinate to Text
        if locationSelected == .startLocation{
            startLocButton.setTitle("  \(place.name)", for: .normal)
            originlat = place.coordinate.latitude
            originlong = place.coordinate.longitude
            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            Origin = place.name
            self.DestinationButton.isEnabled = true
        }else{
            destLocButton.setTitle("  \(place.name)", for: .normal)
            Destlat = place.coordinate.latitude
            Destlong = place.coordinate.longitude
            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            Destination = place.name
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

public extension UISearchBar{
    
    public func setTextColor(color: UIColor){
        
        let svs = subviews.flatMap { $0.subviews}
        guard let tf = (svs.filter {$0 is UITextField }).first as? UITextField else { return }
        
        tf.textColor = color
        
    }
}



