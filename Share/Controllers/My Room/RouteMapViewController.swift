//
//  RouteMapViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 30/03/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Firebase

class RouteMapViewController: UIViewController, MGLMapViewDelegate, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    
    let ref = Database.database().reference(fromURL: "https://share-a8ca4.firebaseio.com/")
    let curUser = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var mapView: MGLMapView!
    

    
    var timer = Timer()
    var OriginLat = 0.0
    var OriginLong = 0.0
    var DestinLat = 0.0
    var DestinLong = 0.0
    var originString = ""
    var destinationString = ""
    
    var directionsRoute: Route?
    var directionsRoute2: Route?
    var directionsRoute3: Route?
    
    var current = CLLocation()

    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    
    var member = [String]()
    var leader = ""
    var leaderFname = ""
    var leaderLname = ""

    //Markers
    var leaderMarker = MGLPointAnnotation()
    var memberMarker = [MGLPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        query()
        //Do something every second
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.sayHello), userInfo: nil, repeats: true)
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        current = CLLocation(latitude: (mapView.userLocation?.coordinate.latitude)!, longitude: (mapView.userLocation?.coordinate.longitude)!)
        mapView.setUserTrackingMode(.follow, animated: true)
        
        navigateRoute()
    }
    
    func query(){
        
        if self.leader != curUser{
            self.ref.child("users").child(self.leader).observe(.value, with: {(snapshot) in
                
                let value = snapshot.value as? NSDictionary
                
                self.leaderFname = value?["Fname"] as! String
                self.leaderLname = value?["Lname"] as! String
                
                if snapshot.hasChild("Location"){
                    
                        let locationSnap = snapshot.childSnapshot(forPath: "Location")
                    
                        let dict = locationSnap.value as! [String: Any?]
                    
                        let lat = dict["Latitude"] as! NSNumber
                        let long = dict["Longitude"] as! NSNumber
                    
                    
                        let marker = MGLPointAnnotation()
                        
                        marker.coordinate = CLLocationCoordinate2D(latitude: Double(exactly: lat)!, longitude: Double(exactly: long)!)
                    
                        marker.title = "Leader"
                        marker.subtitle = self.leaderFname + " " + self.leaderLname
                    
                        self.mapView.removeAnnotation(self.leaderMarker)
                    

                        self.leaderMarker = marker
                    
                }
                
            })
        }
        
        for i in 0 ..< member.count{
            if curUser == self.leader{
                self.ref.child("users").child(member[i]).observe(.value, with: {(snapshot) in
                    
                    let value = snapshot.value as? NSDictionary
                    
                    if snapshot.hasChild("Location"){
                        
                        let fname = value?["Fname"] as! String
                        let lname = value?["Lname"] as! String
                        
                        let locationSnap = snapshot.childSnapshot(forPath: "Location")
                        
                        let dict = locationSnap.value as! [String: Any?]
                        
                        let lat = dict["Latitude"] as! NSNumber
                        let long = dict["Longitude"] as! NSNumber
                        
                        let marker = MGLPointAnnotation()
                        
                        if self.memberMarker.isEmpty == false && self.memberMarker.count == self.member.count{
                            print(self.memberMarker[i])
                            print(self.memberMarker.count)
                            self.mapView.removeAnnotation(self.memberMarker[i])
                            marker.coordinate = CLLocationCoordinate2D(latitude: Double(exactly: lat)!, longitude: Double(exactly: long)!)
                            
                            marker.title = "Member"
                            marker.subtitle = fname + " " + lname
                            self.memberMarker[i] = marker
                            print(self.memberMarker[i])
                        }else{
                            print(self.member.count)
                            print(self.memberMarker.count)
                            marker.coordinate = CLLocationCoordinate2D(latitude: Double(exactly: lat)!, longitude: Double(exactly: long)!)
                            
                            marker.title = "Member"
                            marker.subtitle = fname + " " + lname
                            self.memberMarker.append(marker)
                        }
                        
                        
                    }
                    
                })
            }else if curUser != member[i]{
                self.ref.child("users").child(member[i]).observe(.value, with: {(snapshot) in
                    
                    let value = snapshot.value as? NSDictionary
                    
                    if snapshot.hasChild("Location"){
                        
                        let fname = value?["Fname"] as! String
                        let lname = value?["Lname"] as! String
                        
                        let locationSnap = snapshot.childSnapshot(forPath: "Location")
                        
                        let dict = locationSnap.value as! [String: Any?]
                        
                        let lat = dict["Latitude"] as! NSNumber
                        let long = dict["Longitude"] as! NSNumber
                        
                        let marker = MGLPointAnnotation()
                        
                        if self.memberMarker.isEmpty == false && self.memberMarker.count == self.member.count - 1{
                            self.mapView.removeAnnotation(self.memberMarker[i - 1])
                            marker.coordinate = CLLocationCoordinate2D(latitude: Double(exactly: lat)!, longitude: Double(exactly: long)!)
                            
                            marker.title = "Member"
                            marker.subtitle = fname + " " + lname
                            self.memberMarker[i - 1] = marker
                        }else{
                            marker.coordinate = CLLocationCoordinate2D(latitude: Double(exactly: lat)!, longitude: Double(exactly: long)!)
                            
                            marker.title = "Member"
                            marker.subtitle = fname + " " + lname
                            self.memberMarker.append(marker)
                        }
                        

                    }
                    
                })
            }
        }
    }
    
    
    //terminate timer function
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    
    //function to do every second
    @objc func sayHello()
    {
        if self.leader != curUser{
            self.mapView.addAnnotation(leaderMarker)
        }
        
     
        if memberMarker.isEmpty == false{
            for i in 0 ..< memberMarker.count{
                self.mapView.addAnnotation(memberMarker[i])
            }
        }
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func navigateRoute(){
        
        let origin2d = CLLocationCoordinate2D(latitude: OriginLat, longitude: OriginLong)
        let destin2d = CLLocationCoordinate2D(latitude: DestinLat, longitude: DestinLong)
        
        mapView.setUserTrackingMode(.none, animated: true)
        
        calculateRoute(from: origin2d, to: destin2d) { (route, error) in
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
                print(1)
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
            
            
            let DestMarker = MGLPointAnnotation()
            let OriginMarker = MGLPointAnnotation()
       
            DestMarker.coordinate = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
            OriginMarker.coordinate = CLLocationCoordinate2D(latitude: origin.latitude, longitude: origin.longitude)
            
            let routeCam = self.mapView.cameraThatFitsCoordinateBounds(coordinateBounds, edgePadding: insets)
            self.mapView.setCamera(routeCam, animated: true)
            
            DestMarker.title = "Destination"
            DestMarker.subtitle = self.destinationString
            OriginMarker.title = "Origin"
            OriginMarker.subtitle = self.originString
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
            lineStyle.lineColor = NSExpression(forConstantValue: UIColor.red)
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
        mapView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: .zero, animated: true); mapView.add(routeLine)
        
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool{
        return true
    }
    
//    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
//  
//        var member = mapView.dequeueReusableAnnotationImage(withIdentifier: "memberMarker")
//        var destMarker = mapView.dequeueReusableAnnotationView(withIdentifier: "DestMarker")
//        
//        if member == nil {
//            
//            var image = UIImage(named: "icons8-contacts-filled-25")!
//            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
//            
//            member = MGLAnnotationImage(image: image, reuseIdentifier: "memberMarker")
//        }
//        
//        return member
//    }
    
    func createAlert(title:String,message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let subButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(subButton)
        self.present(alert, animated: true, completion: nil)
    }
}
