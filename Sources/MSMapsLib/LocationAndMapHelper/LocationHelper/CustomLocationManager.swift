//
//  LocationManager.swift
//  Learn no core
//
//  Created by Corptia 02 on 21/05/2023.
//

import Foundation
import MapKit

@MainActor
public class CustomLocationManager : NSObject , ObservableObject {
    @Published public var location : CLLocation?
    @Published public var isInsideRegion : Bool = false {
        didSet {
            if(isInsideRegion){
                if let entered = onEnter {
                    entered()
                }
            } else {
                if let exit = onExit {
                    exit()
                }
            }
        }
    }
    
    private var geofenceRegion = CLCircularRegion()
    private let locationManager = CLLocationManager()
    
    @Published private(set) var authorizationStatus: UNAuthorizationStatus?
    
    public func getLocation()->CLLocation? {
        var myLocation = locationManager.location
        
//        if(shouldCheckForRegion){
            if(!geofenceRegion.identifier.isEmpty){
                if(myLocation != nil){
                    let distance = getDistanceInMeters(lat1: (myLocation!.coordinate.latitude), lng1: (myLocation!.coordinate.longitude), lat2: self.geofenceRegion.center.latitude, lon2: self.geofenceRegion.center.longitude)
                    self.isInsideRegion = distance * 1000 <= self.geofenceRegion.radius.magnitude
                    if(self.isInsideRegion) {
                        shouldCheckForRegion = false
                    }
                }
            }
//        }
        
        return myLocation
    }
    
    private var onEnter : (()->Void)! = nil
    private var onExit : (()->Void)! = nil
    private var onDeniedLocationPermission : (()->Void)! = nil
    private var enableLocation : (()->Void)! = nil
    private var alwaysNeeded : Bool = false
    
    public var afterPermChanged:(()->Void)!
    
    public init(_ justStart:Bool = false , alwaysNeeded : Bool = false , onEnter:@escaping ()->Void , onExit:@escaping ()->Void) {
        super.init()
        self.alwaysNeeded = alwaysNeeded
        self.onEnter = onEnter
        self.onExit = onExit
        
        if(justStart) {
            startLocationMonitoring()
        } else {
            checkLocationEnabled()
        }
    }
    
    public init(_ noBackground:Bool = true) {
        super.init()
        self.alwaysNeeded = false
        self.onEnter = {}
        self.onExit = {}
        self.noBackground = noBackground
        checkLocationEnabled()
    }
    var noBackground = false
    public func setOnDeniedLocPermission(_ onDeniedLocationPermission:@escaping ()->Void){
        self.onDeniedLocationPermission = onDeniedLocationPermission
    }
    
    public func setEnableLocation(_ enableLocation:@escaping ()->Void){
        self.enableLocation = enableLocation
    }
    
    public func setRegion(lat:Double , lng:Double , distance:Double , id:String = "Work" , onEnter:@escaping ()->Void , onExit:@escaping ()-> Void){
        self.onExit = onExit
        self.onEnter = onEnter
        geofenceRegion = .init(
            center: .init(latitude: lat, longitude: lng),
            radius: CLLocationDistance(distance),
            identifier: id)
        locationManager.startMonitoring(for: geofenceRegion)
    }
    
    public func stopMonitoring(id:String = "Work"){
        if(geofenceRegion.identifier == id){
            locationManager.stopMonitoring(for: geofenceRegion)
            geofenceRegion = .init()
        }
    }
    
    public func stopLocationUpdate(){
        locationManager.stopUpdatingLocation()
        stopMonitoring()
    }
    private var shouldCheckForRegion : Bool = true
}

//Check permissions and location enabled
extension CustomLocationManager {
    func checkLocationEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuth()
        } else{
            if let enableLoc = enableLocation {
                enableLoc()
            }
        }
    }
    
    public func startLocationMonitoring(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        if(!noBackground) {
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.showsBackgroundLocationIndicator = true
        }
    }
    
    // Check if user authorized location
    private func checkLocationAuth() {
        switch locationManager.authorizationStatus{
        case .notDetermined:
            if(alwaysNeeded){
                locationManager.requestAlwaysAuthorization()
                print("PERMISSION CHECK requestAlwaysAuthorization")
            } else {
                locationManager.requestWhenInUseAuthorization()
                print("PERMISSION CHECK requestWhenInUseAuthorization")
            }
        case .restricted:
            if let onDeniedPerm = onDeniedLocationPermission {
                onDeniedPerm()
            }
            print("PERMISSION CHECK User location access is restricted")
        case .denied:
            if let onDeniedPerm = onDeniedLocationPermission {
                onDeniedPerm()
            }
            print("PERMISSION CHECK User denied location access")
        case .authorizedWhenInUse:
            if(!alwaysNeeded) {
                startLocationMonitoring()
                if(geofenceRegion.identifier == "Work"){
                    locationManager.startMonitoring(for: geofenceRegion)
                }
            }
        case .authorizedAlways:
            startLocationMonitoring()
            if(geofenceRegion.identifier == "Work"){
                locationManager.startMonitoring(for: geofenceRegion)
            }
        @unknown default:
            break
        }
    }
    
    public func checkMyAuthIsAlways(isAlwaysAction:@escaping ()->Void , isNotAlways :@escaping ()->Void){
        switch locationManager.authorizationStatus{
        case .authorizedAlways:
            isAlwaysAction()
        default:
            isNotAlways()
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { isGranted, _ in
            DispatchQueue.main.async {
                self.authorizationStatus = isGranted ? .authorized : .denied
            }
        }
    }
}

extension CustomLocationManager : CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        self.location = location
        if(shouldCheckForRegion){
            if(!geofenceRegion.identifier.isEmpty){
                let distance = getDistanceInMeters(lat1: (self.location?.coordinate.latitude)!, lng1: (self.location?.coordinate.longitude)!, lat2: self.geofenceRegion.center.latitude, lon2: self.geofenceRegion.center.latitude)
                self.isInsideRegion = distance * 1000 <= self.geofenceRegion.radius.magnitude
                if(self.isInsideRegion) {
                    shouldCheckForRegion = false
                }
            }
        }
    }
    
    // Check if user changed location after first time
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //check for location authorization
        checkLocationAuth()
        // request for notification access
        requestAuthorization()
        if let afterChanged  = afterPermChanged {
            afterChanged()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("I AM HERE \(isInsideRegion)")
        if(region.identifier == "Work") {
            isInsideRegion = true
        }
        print("I AM HERE \(isInsideRegion)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("I AM HERE \(isInsideRegion)")
        if(region.identifier == "Work") {
            isInsideRegion = false
        }
        print("I AM HERE \(isInsideRegion)")
    }
}
