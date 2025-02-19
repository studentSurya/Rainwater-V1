//
//  LocationManager.swift
//  Rainwater
//
//  Created by Surya Swaminathan on 10/17/24.
//  Built using: https://www.youtube.com/watch?v=HfPTp3Qdyog

import Foundation
import MapKit

@MainActor

class LocationManager : NSObject, ObservableObject {
    
    @Published var location: CLLocation?
    
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() //Update Info.plist!
        locationManager.delegate = self
    }
}

extension LocationManager : CLLocationManagerDelegate {
    func locationManager(_ _manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        self.location = location
    }
    
}
