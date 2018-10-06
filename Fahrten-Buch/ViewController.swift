//
//  ViewController.swift
//  Fahrten-Buch
//
//  Created by Alex on 04.10.18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RainbowSwift

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // initialize Properties
    var locationManager: CLLocationManager!
    var previousLocation : CLLocation!
    var locationHistoryDict : Dictionary<String, Any>!
    var coordinateArray: [CLLocationCoordinate2D] = []
    
    
    // initial Outlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var getHistoryBtn : UIButton!
    @IBOutlet var clearHistoryBtn : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\n----------------------------------------------")
        print("Initialize App properties:")
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.delegate = self;
            
            // user activated automatic authorization info mode
            let status = CLLocationManager.authorizationStatus()
            if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
                locationManager.requestAlwaysAuthorization()
            }
            print(" - Starting locationmanager..".green)
            locationManager.startUpdatingLocation()
        }
        else{
            print("No location service activated..")
        }
        
        if mapView != nil {
            //mapview setup to show user location
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.mapType = MKMapType(rawValue: 0)!
            mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
            
            print(" - initial MKMap..".green)
        }
        
        // get old coordinates
        if loadCoordinates() != nil {
             coordinateArray = loadCoordinates()!
        }
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Store an array of CLLocationCoordinate2D
    func storeCoordinates(_ coordinates: [CLLocationCoordinate2D]) {
        let locations = coordinates.map { coordinate -> CLLocation in
            return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        let archived = try! NSKeyedArchiver.archivedData(withRootObject: locations, requiringSecureCoding: true)
        UserDefaults.standard.set(archived, forKey: "coordinates")
        UserDefaults.standard.synchronize()
    }
    
    // Return an array of CLLocationCoordinate2D
    func loadCoordinates() -> [CLLocationCoordinate2D]? {
        guard let archived = UserDefaults.standard.object(forKey: "coordinates") as? Data,
            let locations = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archived) as? [CLLocation] else{
                return nil
        }
        
        let coordinates = locations.map { location -> CLLocationCoordinate2D in
            return location.coordinate
        }
        
        return coordinates
    }
    
    // Did Update Locations?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        //calculation for location selection and pointing annotation
        if let previousLocationNew = previousLocation as CLLocation?{
            //case if previous location exists
            if previousLocation.distance(from: location!) > 200 {
                
                // transforme cllocation to cllocationcoordinate
                let coordinate: CLLocationCoordinate2D = location!.coordinate
                
                // Add Annotation to map
                let annotationNode = MKPlacemark(coordinate: coordinate)
                mapView.addAnnotation(annotationNode)
                
                // Get old Coordinates
                if loadCoordinates() != nil{
                    coordinateArray = loadCoordinates()!
                }
                coordinateArray.append(coordinate)
                
                // Save Coordinates
                storeCoordinates(coordinateArray)
                previousLocation = location
                
                
                print("New Loacation: \(String(describing: coordinate.latitude)) \(String(describing: coordinate.longitude))")
            }
        }
        else{
            //in case previous location doesn't exist
            //addAnnotationsOnMap(location)
            previousLocation = location
        }
    }
    
    // Calculate from annotations
    func calculateRoute(){
        
        // Get old Coordinates
        if loadCoordinates() != nil{
            coordinateArray = loadCoordinates()!
        
            // init array of points
            var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        
            for coordinate in coordinateArray{
                points.append(coordinate)
            }
            
            // Draw Route
            let polyline = MKPolyline(coordinates: points, count: points.count)
            mapView.addOverlay(polyline)
        }
    }
    
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return nil
    }
    
    // get location history
    @IBAction func getHistory(){
        let locationHistory = loadCoordinates()
        if locationHistory != nil{
            print("\nLocation History: ")
            for location in locationHistory!{
                
                print(" - \(location)")
            }
        }
    }
    
    // clear location history
    @IBAction func clearHistory(){
        coordinateArray.removeAll()
        storeCoordinates(coordinateArray)
    }
    
    // Draw Route throug all our annotations
    @IBAction func drawLine(){
        calculateRoute()
    }
}
